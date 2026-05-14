from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
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

app.include_router(auth.router)
app.include_router(reviews.router)
app.include_router(places.router)
app.include_router(profile.router)

@app.get("/")
async def root():
    return {"message": "CamExplore Backend is running"}
