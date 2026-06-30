# from dotenv import load_dotenv
# import os
# from motor.motor_asyncio import AsyncIOMotorClient

# load_dotenv()

# MONGODB_URL = os.getenv("MONGODB_URL")
# DATABASE_NAME = os.getenv("DATABASE_NAME")

# client = AsyncIOMotorClient(MONGODB_URL)
# db = client[DATABASE_NAME]

from dotenv import load_dotenv
import os
import certifi
from motor.motor_asyncio import AsyncIOMotorClient

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL")
DATABASE_NAME = os.getenv("DATABASE_NAME")

client = AsyncIOMotorClient(
    MONGODB_URL,
    tls=True,
    tlsCAFile=certifi.where()
)

db = client[DATABASE_NAME]