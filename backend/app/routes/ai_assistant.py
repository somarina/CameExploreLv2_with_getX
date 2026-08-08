import base64
import json
import math
import os
import re
from typing import Optional
from urllib.parse import quote_plus

import httpx
from dotenv import load_dotenv
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile

from app.data.provinces import PROVINCES
from app.db.daatabase import db
from app.schemas.ai_schemas import AiChatSchema
from app.utils.auth_dependency import get_current_user_optional

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-3.6-flash")
GEMINI_URL = (
    f"https://generativelanguage.googleapis.com/v1beta/models/"
    f"{GEMINI_MODEL}:generateContent"
)

router = APIRouter(prefix="/api/ai", tags=["AI Assistant"])

places_collection = db["places"]


# ── response helpers (same style as auth.py / auth_dashboard.py) ────────────

def ok(message: str, data=None):
    return {"result": True, "message": message, "data": data if data is not None else {}}


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={"result": False, "message": message, "data": {}},
    )


SYSTEM_INSTRUCTION = (
    "You are the CamExplore AI Travel Assistant, built into the CamExplore app "
    "(a Cambodia tourism booking platform covering tourist places, hotels, and "
    "travel packages). You help users plan trips inside Cambodia: attractions, "
    "provinces, itineraries, food, culture, transport, budgeting, and best times "
    "to visit. Keep answers friendly, concise, and practical (short paragraphs "
    "or bullet points, no heavy markdown). If real places from the CamExplore "
    "database are given to you as context below, prefer recommending those by "
    "name over generic knowledge. If a question is unrelated to Cambodia travel, "
    "gently steer the conversation back to trip planning. Never invent prices, "
    "opening hours, or booking details you were not given. Always reply in the "
    "same language the user just wrote in (English or Khmer)."
)

STOPWORDS = {
    "the", "a", "an", "is", "are", "was", "were", "to", "for", "in", "on", "at",
    "of", "and", "or", "with", "i", "me", "my", "you", "your", "please", "can",
    "what", "where", "when", "how", "which", "best", "good", "some", "any",
    "want", "like", "about", "trip", "travel", "visit", "cambodia", "place",
    "places", "recommend", "suggest", "tell",
}


def extract_keywords(text: str, limit: int = 5) -> list[str]:
    words = re.findall(r"[a-zA-Z]+", text.lower())
    seen: list[str] = []
    for w in words:
        if len(w) > 2 and w not in STOPWORDS and w not in seen:
            seen.append(w)
    return seen[:limit]


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dlambda / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


def nearest_province(lat: float, lng: float) -> Optional[dict]:
    if not PROVINCES:
        return None
    return min(
        PROVINCES,
        key=lambda p: haversine_km(lat, lng, p["latitude"], p["longitude"]),
    )


def serialize_place_brief(place: dict) -> dict:
    return {
        "id": str(place["_id"]),
        "name_en": place.get("name_en") or place.get("name", ""),
        "name_km": place.get("name_km", ""),
        "province": place.get("province"),
        "category": place.get("category"),
        "image_url": place.get("image_url"),
        "rating": place.get("rating", 0),
    }


async def find_grounding_places(
    message: str,
    limit: int = 5,
    lat: Optional[float] = None,
    lng: Optional[float] = None,
) -> list[dict]:
    keywords = extract_keywords(message, limit=6)
    if not keywords:
        return []

    fields = ["name_en", "name_km", "description_en", "province", "category", "tags"]
    query = {
        "$and": [
            {"status": "approved"},
            {"$or": [{f: {"$regex": kw, "$options": "i"}} for kw in keywords for f in fields]},
        ]
    }

    cursor = places_collection.find(query).sort("rating", -1).limit(limit * 3 if lat is not None else limit)
    places = [p async for p in cursor]

    if lat is not None and lng is not None:
        def distance(p: dict) -> float:
            if p.get("latitude") is None or p.get("longitude") is None:
                return float("inf")
            return haversine_km(lat, lng, p["latitude"], p["longitude"])

        places.sort(key=distance)

    return places[:limit]


def build_gemini_contents(payload: AiChatSchema) -> list[dict]:
    contents = []
    if payload.history:
        for turn in payload.history:
            contents.append({"role": turn.role, "parts": [{"text": turn.text}]})
    contents.append({"role": "user", "parts": [{"text": payload.message}]})
    return contents


@router.post("/chat")
async def ai_chat(payload: AiChatSchema, user: Optional[dict] = Depends(get_current_user_optional)):
    if not GEMINI_API_KEY:
        err("AI assistant is not configured yet", 503)

    grounding_places = await find_grounding_places(
        payload.message, lat=payload.latitude, lng=payload.longitude
    )

    system_text = SYSTEM_INSTRUCTION
    if payload.latitude is not None and payload.longitude is not None:
        province = nearest_province(payload.latitude, payload.longitude)
        if province:
            system_text += (
                f"\n\nThe user's device reports they are currently near "
                f"{province['name']} province, Cambodia (based on GPS coordinates). "
                f"If they ask about their 'current location' or 'nearby' places, "
                f"assume they mean {province['name']} unless they say otherwise."
            )
    if grounding_places:
        lines = [
            f"- {p.get('name_en') or p.get('name', '')} "
            f"({p.get('province', 'Cambodia')}, {p.get('category', 'attraction')})"
            for p in grounding_places
        ]
        system_text += "\n\nReal places from the CamExplore database that may be relevant:\n" + "\n".join(lines)

    body = {
        "system_instruction": {"parts": [{"text": system_text}]},
        "contents": build_gemini_contents(payload),
        "generationConfig": {"temperature": 0.7, "maxOutputTokens": 512},
    }

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                GEMINI_URL,
                headers={
                    "Content-Type": "application/json",
                    "x-goog-api-key": GEMINI_API_KEY,
                },
                json=body,
            )
    except httpx.RequestError:
        err("Could not reach the AI service, please try again", 502)

    if response.status_code != 200:
        print(f"[ai_chat] Gemini error {response.status_code}: {response.text}")
        err(f"AI service error ({response.status_code}): {response.text[:300]}", 502)

    data = response.json()
    try:
        reply_text = data["candidates"][0]["content"]["parts"][0]["text"]
    except (KeyError, IndexError):
        err("AI service returned an empty response", 502)

    return ok(
        "AI response",
        {
            "reply": reply_text,
            "suggested_places": [serialize_place_brief(p) for p in grounding_places],
        },
    )


# ── image landmark identification ────────────────────────────────────────

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp", "image/heic", "image/heif"}
MAX_IMAGE_BYTES = 8 * 1024 * 1024  # 8MB

IMAGE_SYSTEM_INSTRUCTION = (
    "You are the CamExplore AI Travel Assistant's landmark recognition feature. "
    "The user has uploaded a photo, most likely of a place in or near Cambodia "
    "(temples, pagodas, monuments, natural sites, cities, statues). Identify the "
    "specific place shown if you recognize it. Respond with ONLY a raw JSON object "
    "(no markdown, no code fences, no extra text) in exactly this shape:\n"
    '{"recognized": true or false, "place_name": "string or empty", '
    '"province": "string or empty", "confidence": "high", "medium", or "low", '
    '"description": "2-4 friendly sentences about the place: what it is, its '
    'history, and why it matters", "latitude": number or null, '
    '"longitude": number or null}\n'
    "Only set recognized to true and fill place_name if you are genuinely confident "
    "about the exact landmark. Only include latitude/longitude if you are confident "
    "about that exact landmark's real-world coordinates, otherwise use null - never "
    "guess coordinates. If you cannot confidently identify the exact place, set "
    "recognized to false, leave place_name and province empty, and use description "
    "to give a brief, honest best guess of the general style or type of place it "
    "looks like. Never invent a specific name you are not confident about."
)


def build_google_maps_url(query_name: str, lat: Optional[float], lng: Optional[float]) -> str:
    if lat is not None and lng is not None:
        return f"https://www.google.com/maps/search/?api=1&query={lat},{lng}"
    query = quote_plus(query_name)
    return f"https://www.google.com/maps/search/?api=1&query={query}"


def parse_gemini_json(raw_text: str) -> Optional[dict]:
    cleaned = raw_text.strip()
    if cleaned.startswith("```"):
        cleaned = re.sub(r"^```(json)?", "", cleaned, flags=re.IGNORECASE).strip()
        if cleaned.endswith("```"):
            cleaned = cleaned[: -3].strip()
    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        return None


@router.post("/identify-image")
async def ai_identify_image(
    image: UploadFile = File(...),
    message: Optional[str] = Form(None),
    latitude: Optional[float] = Form(None),
    longitude: Optional[float] = Form(None),
    user: Optional[dict] = Depends(get_current_user_optional),
):
    if not GEMINI_API_KEY:
        err("AI assistant is not configured yet", 503)

    if image.content_type not in ALLOWED_IMAGE_TYPES:
        err("Please upload a JPG, PNG, WEBP, or HEIC image", 400)

    image_bytes = await image.read()
    if not image_bytes:
        err("The uploaded image is empty", 400)
    if len(image_bytes) > MAX_IMAGE_BYTES:
        err("Image is too large (max 8MB)", 400)

    b64_data = base64.b64encode(image_bytes).decode("utf-8")
    user_prompt = (message or "").strip() or "What place is this? Tell me about it."

    contents = [
        {
            "role": "user",
            "parts": [
                {"text": user_prompt},
                {"inline_data": {"mime_type": image.content_type, "data": b64_data}},
            ],
        }
    ]

    body = {
        "system_instruction": {"parts": [{"text": IMAGE_SYSTEM_INSTRUCTION}]},
        "contents": contents,
        "generationConfig": {"temperature": 0.4, "maxOutputTokens": 512},
    }

    try:
        async with httpx.AsyncClient(timeout=45.0) as client:
            response = await client.post(
                GEMINI_URL,
                headers={
                    "Content-Type": "application/json",
                    "x-goog-api-key": GEMINI_API_KEY,
                },
                json=body,
            )
    except httpx.RequestError:
        err("Could not reach the AI service, please try again", 502)

    if response.status_code != 200:
        print(f"[ai_identify_image] Gemini error {response.status_code}: {response.text}")
        err(f"AI service error ({response.status_code}): {response.text[:300]}", 502)

    data = response.json()
    try:
        raw_text = data["candidates"][0]["content"]["parts"][0]["text"]
    except (KeyError, IndexError):
        err("AI service returned an empty response", 502)

    parsed = parse_gemini_json(raw_text)
    if parsed is None:
        # Gemini didn't return clean JSON - fall back to plain text reply.
        return ok(
            "Image identified",
            {
                "recognized": False,
                "place_name": "",
                "province": "",
                "confidence": "low",
                "reply": raw_text.strip(),
                "latitude": None,
                "longitude": None,
                "google_maps_url": None,
                "suggested_places": [],
            },
        )

    recognized = bool(parsed.get("recognized"))
    place_name = (parsed.get("place_name") or "").strip()
    province = (parsed.get("province") or "").strip()
    description = (parsed.get("description") or "").strip()
    confidence = parsed.get("confidence") or "low"
    lat = parsed.get("latitude")
    lng = parsed.get("longitude")
    if not isinstance(lat, (int, float)):
        lat = None
    if not isinstance(lng, (int, float)):
        lng = None

    grounding_places: list[dict] = []
    if place_name:
        grounding_places = await find_grounding_places(f"{place_name} {province}", limit=3)

    google_maps_url: Optional[str] = None
    if recognized and place_name:
        maps_query = f"{place_name}, {province}, Cambodia" if province else f"{place_name}, Cambodia"
        google_maps_url = build_google_maps_url(maps_query, lat, lng)
    elif grounding_places:
        gp = grounding_places[0]
        gp_lat, gp_lng = gp.get("latitude"), gp.get("longitude")
        gp_name = gp.get("name_en") or gp.get("name", "")
        google_maps_url = build_google_maps_url(f"{gp_name}, Cambodia", gp_lat, gp_lng)

    if recognized and place_name:
        reply_parts = [f"This looks like {place_name}" + (f", {province}" if province else "") + "."]
        if description:
            reply_parts.append(description)
        reply_text = " ".join(reply_parts)
    else:
        reply_text = description or (
            "I couldn't confidently identify the exact place from this photo. "
            "Feel free to tell me more about it (province, nearby landmarks) and I'll help further."
        )

    return ok(
        "Image identified",
        {
            "recognized": recognized,
            "place_name": place_name,
            "province": province,
            "confidence": confidence,
            "reply": reply_text,
            "latitude": lat,
            "longitude": lng,
            "google_maps_url": google_maps_url,
            "suggested_places": [serialize_place_brief(p) for p in grounding_places],
        },
    )