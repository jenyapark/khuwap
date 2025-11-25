from sqlalchemy import create_engine, MetaData
from sqlalchemy.orm import sessionmaker, Session
DATABASE_URL = "postgresql://postgres:7087@localhost:5432/postgres"


engine = create_engine(DATABASE_URL)

metadata = MetaData()

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()



