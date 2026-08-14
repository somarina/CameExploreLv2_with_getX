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


# ── response helpers ───────────────────────────────────────────────────────

def ok(message: str, data=None):
    return {
        "result": True,
        "message": message,
        "data": data if data is not None else {},
    }


def err(message: str, status_code: int = 400):
    raise HTTPException(
        status_code=status_code,
        detail={
            "result": False,
            "message": message,
            "data": {},
        },
    )


# ── CamExplore AI identity and behavior ────────────────────────────────────

SYSTEM_INSTRUCTION = """
You are CamExplore AI, the official travel agent and travel companion
inside the CamExplore application.

IDENTITY:
- Your name is "CamExplore AI".
- You are a specialized Cambodia travel agent.
- You are NOT a general-purpose AI assistant.
- You are NOT ChatGPT.
- Never describe yourself as ChatGPT, Gemini, Google AI, or another AI service.
- Never behave like a general chatbot.
- Your purpose is to help users discover and plan travel in Cambodia.
- Speak naturally like a friendly, knowledgeable Cambodian travel agent.

MAIN PURPOSE:
Help users with Cambodia travel, including:

- Tourist destinations
- Cambodian provinces and cities
- Hotels and accommodation
- Travel packages
- Trip planning
- Travel itineraries
- Cambodian food
- Restaurants
- Cambodian culture and history
- Temples and cultural attractions
- Beaches and islands
- Nature and adventure
- Transportation
- Travel budgets
- Best times to visit places
- Nearby attractions
- Travel recommendations
- Identifying Cambodian landmarks from uploaded images

CAMEXPLORE CONTEXT:
CamExplore is a Cambodia tourism and booking application.

When relevant, help users discover:
- Places
- Hotels
- Travel packages
- Attractions
- Travel ideas

available through CamExplore.

TRAVEL AGENT BEHAVIOR:
- Act like a helpful travel agent, not a general AI chatbot.
- Give practical travel recommendations.
- Ask useful follow-up questions when necessary.
- When a user asks for a trip recommendation, consider:
  - destination
  - number of days
  - budget
  - interests
  - travel companions
  - preferred activities
- When appropriate, create a simple itinerary.
- Recommend realistic Cambodia travel experiences.
- Prefer real places provided from the CamExplore database over generic recommendations.

DATABASE RULE:
If real places from the CamExplore database are provided in the context:
- Prefer those places.
- Use their actual names.
- Do not invent additional database information.
- Do not invent prices.
- Do not invent availability.
- Do not invent ratings.
- Do not invent opening hours.
- Do not claim that a booking exists unless the application confirms it.

CAMBODIA FOCUS:
CamExplore AI specializes in Cambodia travel.

If the user asks about another country:
Do not become a general travel assistant for that country.

Instead, politely bring the conversation back to Cambodia.

Example:
User:
"Tell me about Thailand."

Response:
"ខ្ញុំជា CamExplore AI ដែលជាជំនួយការទេសចរណ៍សម្រាប់កម្ពុជា។ ខ្ញុំអាចជួយអ្នកស្វែងរកទីកន្លែង សណ្ឋាគារ អាហារ និងគម្រោងដំណើរកម្សាន្តនៅកម្ពុជា។ តើអ្នកចង់ទៅកន្លែងណានៅកម្ពុជាដែរ?"

OFF-TOPIC QUESTIONS:
If the user asks something unrelated to Cambodia travel,
do NOT answer it as a general AI assistant.

Examples:
- Programming
- Coding
- Mathematics
- Homework
- Technology questions
- Politics
- General world news
- Celebrity information
- General medical questions
- General unrelated knowledge
- Writing code
- Creating unrelated stories
- General AI questions

Instead, politely redirect the user to CamExplore's travel purpose.

Example:
User:
"Can you write Python code?"

Response:
"I'm CamExplore AI, your Cambodia travel companion. I specialize in helping with Cambodia destinations, hotels, food, itineraries, and travel plans. What kind of trip are you planning?"

AI IDENTITY QUESTIONS:
If the user asks:
- "Are you ChatGPT?"
- "Are you Gemini?"
- "What AI are you?"
- "What model are you?"
- "Who made you?"

Do not reveal or discuss the underlying AI provider or model.

Respond naturally as CamExplore AI.

Example:
"I'm CamExplore AI, your Cambodia travel companion. I'm here to help you discover places, plan trips, find travel ideas, and explore Cambodia."

LANGUAGE:
- Reply in the same language the user uses.
- If the user writes Khmer, reply in Khmer.
- If the user writes English, reply in English.
- If the user mixes Khmer and English, you may naturally use both.
- Keep Khmer responses natural and easy for Cambodian users to understand.

RESPONSE STYLE:
- Friendly
- Helpful
- Natural
- Practical
- Concise
- Like a professional travel agent
- Easy to understand on a mobile phone

Do not:
- Say "As an AI language model"
- Say "I am a large language model"
- Mention internal AI systems
- Give unnecessary technical explanations
- Behave like a general-purpose chatbot

MARKDOWN:
Use clean Markdown when it improves readability.

Use Markdown for:
- headings
- bold important names
- bullet lists
- numbered lists
- simple itineraries
- short sections

Example:

## Recommended for You

**1. Siem Reap**
- Visit Angkor Wat
- Explore Angkor Thom
- Enjoy the night market

**2. Phnom Penh**
- Royal Palace
- National Museum
- Riverside

Do NOT show raw Markdown formatting incorrectly.

Use proper Markdown syntax so the CamExplore mobile application
can render the response beautifully.

TRAVEL RECOMMENDATION EXAMPLE:

User:
"I have 3 days in Cambodia. Where should I go?"

Response:

## 🌴 3-Day Cambodia Trip

**Day 1 — Phnom Penh**
- Royal Palace
- National Museum
- Riverside in the evening

**Day 2 — Siem Reap**
- Angkor Wat
- Angkor Thom
- Ta Prohm

**Day 3 — Siem Reap**
- Local market
- Cambodian food
- Relax and explore the city

If you'd like, I can also help you choose a hotel or travel package.

BOOKING BEHAVIOR:
You may guide users toward booking when appropriate.

For example:

User:
"I want to visit Siem Reap for 3 days."

You can recommend:
- places
- hotels
- travel packages
- activities

But NEVER claim:
- a booking was completed
- a payment was completed
- a room was reserved
- a travel package was purchased

unless the actual CamExplore booking system confirms it.

LOCATION:
If the user's current location is provided:
- Use it for "near me", "nearby", or "around here".
- Prefer nearby Cambodian destinations when appropriate.
- Do not reveal exact GPS coordinates.

DATABASE GROUNDING:
If real CamExplore places are provided:
- Prefer those places.
- Use their real names.
- Use their province and category when helpful.
- Never invent database information.

FINAL RULE:

Every conversation should remain within the identity and purpose of:

"CamExplore AI — Your Cambodia Travel Companion."

The user should feel like they are talking to a specialized
Cambodia travel agent built specifically for CamExplore,
not a general AI chatbot.
"""


STOPWORDS = {
    "the",
    "a",
    "an",
    "is",
    "are",
    "was",
    "were",
    "to",
    "for",
    "in",
    "on",
    "at",
    "of",
    "and",
    "or",
    "with",
    "i",
    "me",
    "my",
    "you",
    "your",
    "please",
    "can",
    "what",
    "where",
    "when",
    "how",
    "which",
    "best",
    "good",
    "some",
    "any",
    "want",
    "like",
    "about",
    "trip",
    "travel",
    "visit",
    "cambodia",
    "place",
    "places",
    "recommend",
    "suggest",
    "tell",
}


def extract_keywords(
    text: str,
    limit: int = 5,
) -> list[str]:
    words = re.findall(
        r"[a-zA-Z]+",
        text.lower(),
    )

    seen: list[str] = []

    for w in words:
        if (
            len(w) > 2
            and w not in STOPWORDS
            and w not in seen
        ):
            seen.append(w)

    return seen[:limit]


def haversine_km(
    lat1: float,
    lon1: float,
    lat2: float,
    lon2: float,
) -> float:
    r = 6371.0

    p1 = math.radians(lat1)
    p2 = math.radians(lat2)

    dphi = math.radians(
        lat2 - lat1
    )

    dlambda = math.radians(
        lon2 - lon1
    )

    a = (
        math.sin(dphi / 2) ** 2
        + math.cos(p1)
        * math.cos(p2)
        * math.sin(dlambda / 2) ** 2
    )

    return 2 * r * math.asin(
        math.sqrt(a)
    )


def nearest_province(
    lat: float,
    lng: float,
) -> Optional[dict]:

    if not PROVINCES:
        return None

    return min(
        PROVINCES,
        key=lambda p: haversine_km(
            lat,
            lng,
            p["latitude"],
            p["longitude"],
        ),
    )


def serialize_place_brief(
    place: dict,
) -> dict:

    return {
        "id": str(place["_id"]),
        "name_en": place.get("name_en")
        or place.get("name", ""),
        "name_km": place.get(
            "name_km",
            "",
        ),
        "province": place.get(
            "province"
        ),
        "category": place.get(
            "category"
        ),
        "image_url": place.get(
            "image_url"
        ),
        "rating": place.get(
            "rating",
            0,
        ),
    }


async def find_grounding_places(
    message: str,
    limit: int = 5,
    lat: Optional[float] = None,
    lng: Optional[float] = None,
) -> list[dict]:

    keywords = extract_keywords(
        message,
        limit=6,
    )

    if not keywords:
        return []

    fields = [
        "name_en",
        "name_km",
        "description_en",
        "province",
        "category",
        "tags",
    ]

    query = {
        "$and": [
            {
                "status": "approved"
            },
            {
                "$or": [
                    {
                        f: {
                            "$regex": kw,
                            "$options": "i",
                        }
                    }
                    for kw in keywords
                    for f in fields
                ]
            },
        ]
    }

    cursor = (
        places_collection
        .find(query)
        .sort("rating", -1)
        .limit(
            limit * 3
            if lat is not None
            else limit
        )
    )

    places = [
        p
        async for p in cursor
    ]

    if lat is not None and lng is not None:

        def distance(
            p: dict,
        ) -> float:

            if (
                p.get("latitude")
                is None
                or p.get("longitude")
                is None
            ):
                return float("inf")

            return haversine_km(
                lat,
                lng,
                p["latitude"],
                p["longitude"],
            )

        places.sort(
            key=distance
        )

    return places[:limit]


def build_gemini_contents(
    payload: AiChatSchema,
) -> list[dict]:

    contents = []

    if payload.history:
        for turn in payload.history:
            contents.append(
                {
                    "role": turn.role,
                    "parts": [
                        {
                            "text": turn.text
                        }
                    ],
                }
            )

    contents.append(
        {
            "role": "user",
            "parts": [
                {
                    "text": payload.message
                }
            ],
        }
    )

    return contents


@router.post("/chat")
async def ai_chat(
    payload: AiChatSchema,
    user: Optional[dict] = Depends(
        get_current_user_optional
    ),
):

    if not GEMINI_API_KEY:
        err(
            "AI assistant is not configured yet",
            503,
        )

    grounding_places = (
        await find_grounding_places(
            payload.message,
            lat=payload.latitude,
            lng=payload.longitude,
        )
    )

    system_text = SYSTEM_INSTRUCTION

    # ── Current location ──────────────────────────────────────────────────

    if (
        payload.latitude is not None
        and payload.longitude is not None
    ):

        province = nearest_province(
            payload.latitude,
            payload.longitude,
        )

        if province:
            system_text += (
                "\n\nCURRENT USER LOCATION:\n"
                f"The user's device reports they are currently "
                f"near {province['name']} province, Cambodia "
                f"(based on GPS coordinates).\n"
                f"If they ask about 'my location', 'current location', "
                f"'near me', or 'nearby', assume they mean "
                f"{province['name']} unless they say otherwise."
            )

    # ── CamExplore database places ───────────────────────────────────────

    if grounding_places:

        lines = [
            f"- {p.get('name_en') or p.get('name', '')} "
            f"({p.get('province', 'Cambodia')}, "
            f"{p.get('category', 'attraction')})"
            for p in grounding_places
        ]

        system_text += (
            "\n\nREAL CAMEXPLORE DATABASE PLACES:\n"
            "These are real places currently available in "
            "the CamExplore database. Prefer them when they "
            "match the user's request:\n"
            + "\n".join(lines)
        )

    body = {
        "system_instruction": {
            "parts": [
                {
                    "text": system_text
                }
            ]
        },

        "contents": build_gemini_contents(
            payload
        ),

        "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 1024,
            "thinkingConfig": {
                "thinkingLevel": "low"
            },
        },
    }

    try:

        async with httpx.AsyncClient(
            timeout=30.0
        ) as client:

            response = await client.post(
                GEMINI_URL,
                headers={
                    "Content-Type": "application/json",
                    "x-goog-api-key": GEMINI_API_KEY,
                },
                json=body,
            )

    except httpx.RequestError:

        err(
            "Could not reach the AI service, please try again",
            502,
        )

    if response.status_code != 200:

        print(
            f"[ai_chat] Gemini error "
            f"{response.status_code}: "
            f"{response.text}"
        )

        err(
            f"AI service error "
            f"({response.status_code}): "
            f"{response.text[:300]}",
            502,
        )

    data = response.json()

    try:

        reply_text = (
            data["candidates"][0]
            ["content"]["parts"][0]
            ["text"]
        )

    except (
        KeyError,
        IndexError,
    ):

        err(
            "AI service returned an empty response",
            502,
        )

    return ok(
        "AI response",
        {
            "reply": reply_text,
            "suggested_places": [
                serialize_place_brief(p)
                for p in grounding_places
            ],
        },
    )


# ── image landmark identification ─────────────────────────────────────────

ALLOWED_IMAGE_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/heic",
    "image/heif",
}

MAX_IMAGE_BYTES = 8 * 1024 * 1024


IMAGE_SYSTEM_INSTRUCTION = """
You are CamExplore AI's Cambodia travel landmark recognition feature.

Your job is to help users identify Cambodian travel destinations
from uploaded images.

You are still CamExplore AI.

You are NOT a general image recognition assistant.

The image is most likely a Cambodian:
- temple
- pagoda
- monument
- tourist attraction
- natural site
- city
- statue
- beach
- island
- cultural location

Identify the specific Cambodian place if you genuinely recognize it.

Respond with ONLY a raw JSON object
(no markdown, no code fences, no extra text)
in exactly this shape:

{
  "recognized": true or false,
  "place_name": "string or empty",
  "province": "string or empty",
  "confidence": "high", "medium", or "low",
  "description": "2-4 friendly sentences about the place",
  "latitude": number or null,
  "longitude": number or null
}

Only set recognized to true if you are genuinely confident
about the exact Cambodian landmark.

Only include latitude and longitude if you are confident
about the exact landmark coordinates.

Never guess coordinates.

If you cannot confidently identify the exact place:
- recognized = false
- place_name = ""
- province = ""
- confidence = "low"
- Give an honest description of what the image appears to show.

Never invent a specific Cambodian location.
"""


def build_google_maps_url(
    query_name: str,
    lat: Optional[float],
    lng: Optional[float],
) -> str:

    if (
        lat is not None
        and lng is not None
    ):

        return (
            "https://www.google.com/maps/search/"
            f"?api=1&query={lat},{lng}"
        )

    query = quote_plus(
        query_name
    )

    return (
        "https://www.google.com/maps/search/"
        f"?api=1&query={query}"
    )


def parse_gemini_json(
    raw_text: str,
) -> Optional[dict]:

    cleaned = raw_text.strip()

    if cleaned.startswith("```"):

        cleaned = re.sub(
            r"^```(json)?",
            "",
            cleaned,
            flags=re.IGNORECASE,
        ).strip()

        if cleaned.endswith("```"):
            cleaned = cleaned[:-3].strip()

    try:
        return json.loads(
            cleaned
        )

    except json.JSONDecodeError:
        return None


@router.post("/identify-image")
async def ai_identify_image(
    image: UploadFile = File(...),
    message: Optional[str] = Form(None),
    latitude: Optional[float] = Form(None),
    longitude: Optional[float] = Form(None),
    user: Optional[dict] = Depends(
        get_current_user_optional
    ),
):

    if not GEMINI_API_KEY:
        err(
            "AI assistant is not configured yet",
            503,
        )

    if image.content_type not in ALLOWED_IMAGE_TYPES:

        err(
            "Please upload a JPG, PNG, WEBP, or HEIC image",
            400,
        )

    image_bytes = await image.read()

    if not image_bytes:

        err(
            "The uploaded image is empty",
            400,
        )

    if len(image_bytes) > MAX_IMAGE_BYTES:

        err(
            "Image is too large (max 8MB)",
            400,
        )

    b64_data = base64.b64encode(
        image_bytes
    ).decode("utf-8")

    user_prompt = (
        message or ""
    ).strip() or (
        "What Cambodian travel place is this? "
        "Tell me about it."
    )

    contents = [
        {
            "role": "user",
            "parts": [
                {
                    "text": user_prompt
                },
                {
                    "inline_data": {
                        "mime_type": image.content_type,
                        "data": b64_data,
                    }
                },
            ],
        }
    ]

    body = {
        "system_instruction": {
            "parts": [
                {
                    "text": IMAGE_SYSTEM_INSTRUCTION
                }
            ]
        },

        "contents": contents,

        "generationConfig": {
            "temperature": 0.4,
            "maxOutputTokens": 1024,
            "thinkingConfig": {
                "thinkingLevel": "low"
            },
            "responseMimeType": "application/json",
        },
    }

    try:

        async with httpx.AsyncClient(
            timeout=45.0
        ) as client:

            response = await client.post(
                GEMINI_URL,
                headers={
                    "Content-Type": "application/json",
                    "x-goog-api-key": GEMINI_API_KEY,
                },
                json=body,
            )

    except httpx.RequestError:

        err(
            "Could not reach the AI service, please try again",
            502,
        )

    if response.status_code != 200:

        print(
            f"[ai_identify_image] Gemini error "
            f"{response.status_code}: "
            f"{response.text}"
        )

        err(
            f"AI service error "
            f"({response.status_code}): "
            f"{response.text[:300]}",
            502,
        )

    data = response.json()

    try:

        raw_text = (
            data["candidates"][0]
            ["content"]["parts"][0]
            ["text"]
        )

    except (
        KeyError,
        IndexError,
    ):

        finish_reason = (
            data.get("candidates")
            or [{}]
        )[0].get(
            "finishReason"
        )

        usage = data.get(
            "usageMetadata",
            {},
        )

        print(
            "[ai_identify_image] "
            f"empty response - "
            f"finishReason={finish_reason} "
            f"usage={usage}"
        )

        err(
            "AI service returned an empty response",
            502,
        )

    finish_reason = data[
        "candidates"
    ][0].get(
        "finishReason"
    )

    if finish_reason == "MAX_TOKENS":

        usage = data.get(
            "usageMetadata",
            {},
        )

        print(
            "[ai_identify_image] "
            "response truncated by MAX_TOKENS "
            f"- usage={usage} "
            f"raw_text={raw_text!r}"
        )

    parsed = parse_gemini_json(
        raw_text
    )

    if parsed is None:

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

    recognized = bool(
        parsed.get(
            "recognized"
        )
    )

    place_name = (
        parsed.get(
            "place_name"
        )
        or ""
    ).strip()

    province = (
        parsed.get(
            "province"
        )
        or ""
    ).strip()

    description = (
        parsed.get(
            "description"
        )
        or ""
    ).strip()

    confidence = (
        parsed.get(
            "confidence"
        )
        or "low"
    )

    lat = parsed.get(
        "latitude"
    )

    lng = parsed.get(
        "longitude"
    )

    if not isinstance(
        lat,
        (int, float),
    ):
        lat = None

    if not isinstance(
        lng,
        (int, float),
    ):
        lng = None

    grounding_places: list[dict] = []

    if place_name:

        grounding_places = (
            await find_grounding_places(
                f"{place_name} {province}",
                limit=3,
            )
        )

    google_maps_url: Optional[str] = None

    if (
        recognized
        and place_name
    ):

        maps_query = (
            f"{place_name}, {province}, Cambodia"
            if province
            else f"{place_name}, Cambodia"
        )

        google_maps_url = (
            build_google_maps_url(
                maps_query,
                lat,
                lng,
            )
        )

    elif grounding_places:

        gp = grounding_places[0]

        gp_lat = gp.get(
            "latitude"
        )

        gp_lng = gp.get(
            "longitude"
        )

        gp_name = (
            gp.get("name_en")
            or gp.get("name", "")
        )

        google_maps_url = (
            build_google_maps_url(
                f"{gp_name}, Cambodia",
                gp_lat,
                gp_lng,
            )
        )

    if recognized and place_name:

        reply_parts = [
            f"This looks like {place_name}"
            + (
                f", {province}"
                if province
                else ""
            )
            + "."
        ]

        if description:
            reply_parts.append(
                description
            )

        reply_text = " ".join(
            reply_parts
        )

    else:

        reply_text = (
            description
            or
            "I couldn't confidently identify "
            "the exact Cambodian travel place "
            "from this photo. Feel free to tell "
            "me more about the province or nearby "
            "landmarks and I'll help you explore it."
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
            "suggested_places": [
                serialize_place_brief(p)
                for p in grounding_places
            ],
        },
    )