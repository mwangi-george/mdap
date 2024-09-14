from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

load_dotenv()

# change mode to false to use local storage
production_mode: bool = True


def create_db_url(in_production=False):
    """ Creates database URL based on environment variables"""
    if not in_production:
        url = os.getenv('LOCAL_DB_URL')
        return url
    else:
        url = os.getenv('PRODUCTION_DB_URL')
        return url


DB_URL = create_db_url(in_production=production_mode)


if DB_URL.startswith('sqlite'):
    # sqlilte requires additional args
    engine = create_engine(DB_URL, connect_args={"check_same_thread": False})
else:
    engine = create_engine(DB_URL)

# class to create database session with the engine defined above
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """Create a database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
