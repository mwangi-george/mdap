from typing import List, Tuple, Any

from sqlalchemy.orm import Session
from sqlalchemy import or_, Row
from fastapi import HTTPException, status

from ..schemas import UserCreate
from ..models import User
from ..security import Security

# initialize security ops object
security = Security()


class UserServices:

    def __init__(self):
        pass

    @staticmethod
    def register_user(user: UserCreate, db: Session) -> str:
        """Creates a new user in the database"""

        # Check if either email or Mpesa number already exists
        existing_user = db.query(User).filter(
            or_(User.email == user.email, User.mpesa_number == user.mpesa_number, User.username == user.username)
        ).first()

        if existing_user:
            if existing_user.email == user.email:
                raise HTTPException(
                    status_code=status.HTTP_406_NOT_ACCEPTABLE,
                    detail=f"{existing_user.email} is already registered"
                )
            elif existing_user.mpesa_number == user.mpesa_number:
                raise HTTPException(
                    status_code=status.HTTP_406_NOT_ACCEPTABLE,
                    detail=f"{existing_user.mpesa_number} is associated with another account"
                )
            elif existing_user.username == user.username:
                raise HTTPException(
                    status_code=status.HTTP_406_NOT_ACCEPTABLE,
                    detail=f"{existing_user.username} is already taken"
                )

        # Create and add the new user
        new_user = User(
            email=user.email,
            name=user.name,
            mpesa_number=user.mpesa_number,
            username=user.username,
            password=security.get_password_hash(user.password),
        )

        try:
            db.add(new_user)
            db.commit()
            db.refresh(new_user)
            return f"{new_user.email} registered successfully"
        except Exception as e:
            db.rollback()
            print(f"Error occurred: {e}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Could not register user"
            )

    @staticmethod
    def login_user(username: str, password: str, db: Session) -> dict:
        """Login a user and return an access token"""
        user = security.authenticate_user(username, password, db)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password"
            )
        access_token = security.create_access_token(data={"sub": user.username})
        return {"access_token": access_token, "token_type": "bearer"}

    @staticmethod
    def fetch_all_users(db: Session, start: int = 0, limit: int = 20):
        try:
            users = db.query(User).offset(start).limit(limit).all()
            return users
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Could not fetch users"
            )
