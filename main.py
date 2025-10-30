from fastapi import FastAPI
from sqlalchemy import text
from common.db import metadata,  engine
from courses.routers import router as courses_router
from users.routers import router as users_router
from schedules.routers import router as schedules_router

app = FastAPI()

@app.get("/healthz")
async def health_check():
    return {"status": "ok"}

@app.get("/db-test")
async def db_test():
    try:
        with engine.connect() as conn:
            result = conn.execute(text("SELECT version();"))
            version = result.fetchone()[0]
        return {"db_version": version}
    except Exception as e:
        return {"error": str(e)}

metadata.create_all(engine)
app.include_router(courses_router)
app.include_router(users_router)
app.include_router(schedules_router)
