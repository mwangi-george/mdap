from fastapi import FastAPI
from .routes import user_router, transaction_router


def create_app():
    server = FastAPI(
        title="API for extracting key information from MPESA confirmation messages",
        description="Developed with ❤ by [George Mwangi](https://github.com/mwangi-george)."
                    " [Source Code](https://github.com/mwangi-george/mpesa_data_analyzer_api)",
        version="1.0.0",
    )

    user_routes = user_router()
    transaction_routes = transaction_router()

    server.include_router(user_routes)
    server.include_router(transaction_routes)
    return server


app = create_app()
