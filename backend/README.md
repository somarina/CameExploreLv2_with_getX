# CamExplore Backend

FastAPI + MongoDB backend for CamExplore authentication.

## Run local

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn main:app --reload
```

Open Swagger:

```text
http://127.0.0.1:8000/docs
```

## Main Auth APIs

- POST `/auth/register`
- POST `/auth/login`
- POST `/auth/google-login`
- POST `/auth/telegram-login`
- POST `/auth/forgot-password`
- POST `/auth/verify-otp`
- POST `/auth/reset-password`
- GET `/auth/profile`
- PUT `/auth/profile`
- PUT `/auth/change-password`
- POST `/auth/logout`
- POST `/reviews/`
- GET `/reviews/`

For protected routes, click **Authorize** in Swagger and enter:

```text
Bearer YOUR_ACCESS_TOKEN
```

Usage:
    python seed_admin.py

<!-- ffffffffffffffffffff -->
