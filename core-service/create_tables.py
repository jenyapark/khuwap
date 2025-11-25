# create_tables.py
from common.db import metadata, engine
import chat.models 
import users.models
import exchange.models

if __name__ == "__main__":
    print("Creating tables...")
    metadata.create_all(engine)
    print("Done.")
