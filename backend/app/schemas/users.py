from pydantic import BaseModel


class UserCreate(BaseModel):
    name: str
    email: str
    mpesa_number: str
    username: str
    password: str

    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "name": "John Doe",
                "email": "john_doe@gmail.com",
                "mpesa_number": "+254700111222",
                "username": "john_doe",
                "password": "0987",
            }
        }


class ActionConfirm(BaseModel):
    msg: str


class Token(BaseModel):
    access_token: str
    token_type: str


class UserProfile(BaseModel):
    id: int
    name: str
    email: str
    mpesa_number: str
    password: str
    username: str


class ManyUsersResponse(BaseModel):
    users: list[UserProfile] | None
