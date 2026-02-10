from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from pydantic import BaseModel
import re

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class SearchQuery(BaseModel):
    query: str

@app.get("/")
def home():
    return {"status": "AI service running"}

@app.post("/search/natural-language")
def natural_language_search(data: SearchQuery):
    text = data.query.lower()

    bedrooms = None
    max_price = None
    keywords = []

    # detect BHK
    bhk_match = re.search(r'(\d+)\s*bhk', text)
    if bhk_match:
        bedrooms = int(bhk_match.group(1))

    # detect price
    price_match = re.search(r'(under|below)\s*(\d+)', text)
    if price_match:
        max_price = int(price_match.group(2))

    # simple keyword detection
    if "college" in text:
        keywords.append("college")
    if "student" in text:
        keywords.append("student")

    return {
        "success": True,
        "filters": {
            "bedrooms": bedrooms,
            "max_price": max_price,
            "keywords": keywords
        }
    }
class PriceRequest(BaseModel):
    city: str
    sqft: float
    bedrooms: int
    bathrooms: int

@app.post("/price/predict")
def predict_price(data: PriceRequest):
    # simple heuristic model (acceptable for academic project)

    base_price = 4000

    # bedroom factor
    bedroom_factor = data.bedrooms * 3500

    # size factor
    size_factor = data.sqft * 8

    # bathroom factor
    bathroom_factor = data.bathrooms * 1500

    # city multiplier
    city_multiplier = 1.0
    if data.city.lower() in ["bangalore", "bengaluru"]:
        city_multiplier = 1.8
    elif data.city.lower() in ["chennai"]:
        city_multiplier = 1.5
    elif data.city.lower() in ["coimbatore"]:
        city_multiplier = 1.2

    predicted = (base_price + bedroom_factor + size_factor + bathroom_factor) * city_multiplier

    return {
        "predicted_price": int(predicted)
    }
