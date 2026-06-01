from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from fastapi import HTTPException
from app.routes import places, auth, reviews, profile

app = FastAPI(
    title="CamExplore API",
    description="Tourism and Cultural Places API for Cambodia",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Test 
@app.on_event("startup")
async def startup_check():
    try:
        from app.db.daatabase import client
        await client.admin.command("ping")
        print("MongoDB Atlas connected successfully!")
    except Exception as e:
        print(f"MongoDB Atlas connection failed: {e}")

# ── Global error handlers (teacher's style) ───────────────────────────────────

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    detail = exc.detail
    if isinstance(detail, dict) and "result" in detail:
        return JSONResponse(status_code=exc.status_code, content=detail)
    return JSONResponse(
        status_code=exc.status_code,
        content={"result": False, "message": str(detail), "data": {}},
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = exc.errors()
    first = errors[0] if errors else {}
    field = " -> ".join(str(l) for l in first.get("loc", []) if l != "body")
    msg = first.get("msg", "Validation error")
    message = f"{field}: {msg}" if field else msg
    return JSONResponse(
        status_code=422,
        content={"result": False, "message": message, "data": {}},
    )


# ── Routers ───────────────────────────────────────────────────────────────────

app.include_router(auth.router)
app.include_router(reviews.router)
app.include_router(places.router)
app.include_router(profile.router)


@app.get("/")
async def root():
    return {"result": True, "message": "CamExplore Backend is running", "data": {}}
