import os

from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from app.models import User, get_db

# load environment variables
load_dotenv()


class Security:
    """Security class to handle security related operations"""
    def __init__(self):
        pass

    ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7
    ALGORITHM = os.getenv('ALGORITHM')
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY')

    oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/users/login")
    pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')

    def get_password_hash(self, password: str) -> str:
        """Generates hashed password for given password"""
        return self.pwd_context.hash(password)

    def verify_password(self, password: str, hashed_password) -> bool:
        """Verify password against hashed password"""
        return self.pwd_context.verify(password, hashed_password)

    @staticmethod
    def get_user(username: str, db: Session) -> User | None:
        """Get a user by email from db"""
        db_user = db.query(User).filter_by(username=username).first()
        return db_user

    def create_access_token(self, data: dict) -> str:
        """Create an access token"""
        to_encode = data.copy()
        expire = datetime.now(timezone.utc) + timedelta(minutes=self.ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode.update({'exp': expire})
        encoded_jwt = jwt.encode(to_encode, self.JWT_SECRET_KEY, algorithm=self.ALGORITHM)
        return encoded_jwt

    def authenticate_user(self, username: str, password: str, db: Session) -> User | bool:
        """Authenticate a user"""
        user = self.get_user(username, db)
        if not user:
            return False
        if not self.verify_password(password, user.password):
            return False
        return user

    def get_current_user(self, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
        """Get a user by decoded token"""
        credentials_exception = HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )
        try:
            payload = jwt.decode(token, self.JWT_SECRET_KEY, algorithms=[self.ALGORITHM])
            username: str = payload.get('sub')
            if username is None:
                raise credentials_exception
        except JWTError:
            raise credentials_exception
        user = self.get_user(username, db)
        if not user:
            raise credentials_exception
        return user
