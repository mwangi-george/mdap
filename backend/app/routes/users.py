from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from ..models import get_db
from ..schemas.users import UserCreate, ActionConfirm, Token, ManyUsersResponse
from ..services.users import UserServices


def create_user_router() -> APIRouter:
    """ Register the routes for the users endpoints """
    router = APIRouter(prefix="/users", tags=["users"])
    user_services = UserServices()

    @router.post("/register", response_model=ActionConfirm, status_code=status.HTTP_201_CREATED)
    async def register_user(user: UserCreate, db: Session = Depends(get_db)):
        msg = user_services.register_user(user, db)
        formatted_msg = ActionConfirm(msg=msg)
        return formatted_msg

    @router.post("/login", response_model=Token, status_code=status.HTTP_200_OK)
    async def login_for_access_token(
            form_data: OAuth2PasswordRequestForm = Depends(),
            db: Session = Depends(get_db)
    ):
        token = user_services.login_user(form_data.username, form_data.password, db)
        return token

    @router.get("/fetch/all", response_model=ManyUsersResponse, status_code=status.HTTP_200_OK, include_in_schema=False)
    async def fetch_all_users(start: int = 0, limit: int = 20, db: Session = Depends(get_db)):
        try:
            users = user_services.fetch_all_users(start=start, limit=limit, db=db)
            # users_formatted = ManyUsersResponse(users=users)
            return users
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e)
            )

    return router
