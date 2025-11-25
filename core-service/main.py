from fastapi import FastAPI
from sqlalchemy import text
from common.db import metadata,  engine
from courses.routers import router as courses_router
from users.routers import router as users_router
from schedules.routers import router as schedules_router
from exchange.routers.crud import router as exchange_router
from exchange.routers.request import router as exchange_request_router
from chat.routers.chat_router import router as chat_router
from fastapi.routing import APIRoute
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Core Service")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # 개발 중엔 모든 도메인 허용
    allow_credentials=True,
    allow_methods=["*"],          # 모든 HTTP 메서드 허용 
    allow_headers=["*"],          # 모든 헤더 허용
)

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
app.include_router(users_router, prefix = "/users", tags = ["users"])
app.include_router(courses_router, prefix = "/courses", tags = ["courses"])
app.include_router(schedules_router, prefix = "/schedules", tags = ["schedules"])
app.include_router(exchange_router, prefix = "/exchange", tags = ["exchange"])
app.include_router(exchange_request_router, prefix = "/exchange/request", tags = ["exchange-request"])
app.include_router(chat_router, prefix = "/chat", tags = ["chat"])