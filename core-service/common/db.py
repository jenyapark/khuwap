from sqlalchemy import create_engine, MetaData

DATABASE_URL = "postgresql://postgres:7087@localhost:5432/postgres"


engine = create_engine(DATABASE_URL)

metadata = MetaData()





