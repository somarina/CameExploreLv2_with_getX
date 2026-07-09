"""
seed_admin.py
Run this ONCE to create the very first admin account directly in MongoDB,
in its own dedicated "admins" collection — completely separate from the
"users" collection (which holds personal/company accounts).

There is no public /register/admin route for this reason. After this
first "big admin" is created, they can create further "small admin"
accounts through the protected API route:
    POST /api/dashboard/auth/register/admin
(requires being logged in as an existing admin)

Usage:
    python seed_admin.py

Safe to run more than once: if an admin already exists with this email,
the script tells you and exits without creating a duplicate.
"""

import asyncio
import getpass
from datetime import datetime

from app.db.daatabase import db
from app.utils.password import hash_password

admins_collection = db["admins"]


async def seed_admin():
    print("=== Create Admin Account (admins collection) ===")
    name = input("Admin name: ").strip()
    email = input("Admin email: ").strip().lower()
    phone = input("Admin phone (optional, press enter to skip): ").strip()
    password = getpass.getpass("Admin password: ")
    confirm = getpass.getpass("Confirm password: ")

    if password != confirm:
        print("Passwords do not match. Aborting.")
        return

    if len(password) < 8:
        print("Password must be at least 8 characters. Aborting.")
        return

    existing = await admins_collection.find_one({"email": email})
    if existing:
        print(f"An admin already exists for {email}. Nothing to do.")
        return

    now = datetime.utcnow()
    admin_doc = {
        "name": name,
        "email": email,
        "phone": phone,
        "password": hash_password(password),
        "profile_image": "",
        "created_by": "seed_script",
        "created_at": now,
        "updated_at": now,
    }

    result = await admins_collection.insert_one(admin_doc)
    print(f"Admin created successfully in 'admins' collection. _id = {result.inserted_id}")


if __name__ == "__main__":
    asyncio.run(seed_admin())