import mysql.connector
import os
import time
from pymongo import MongoClient
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_connection(max_retries=20, delay_seconds=2):
    """
    Retry DB connection because API can start before MySQL is ready.
    """
    last_error = None
    for _ in range(max_retries):
        try:
            return mysql.connector.connect(
                database=os.getenv("MYSQL_DATABASE"),
                user=os.getenv("MYSQL_USER"),
                password=os.getenv("MYSQL_ROOT_PASSWORD"),
                port=3306,
                host=os.getenv("MYSQL_HOST", "db"),
            )
        except mysql.connector.Error as err:
            last_error = err
            time.sleep(delay_seconds)
    raise last_error


def get_mongo_client():
    return MongoClient(
        host=os.getenv("MONGO_HOST", "db_mongo"),
        username=os.getenv("MONGO_USER"),
        password=os.getenv("MONGO_PASSWORD"),
        authSource="admin",
        serverSelectionTimeoutMS=5000,
    )


@app.get("/posts")
async def get_posts():
    client = get_mongo_client()
    db = client[os.getenv("MONGO_DATABASE", "blog_db")]
    posts = list(db.posts.find({}, {"_id": 0}))
    client.close()
    return {"posts": posts}


@app.get("/users")
async def get_users():
    conn = get_connection()
    cursor = conn.cursor()
    sql_select_Query = "select * from utilisateurs"
    cursor.execute(sql_select_Query)

    records = cursor.fetchall()
    print("Total number of rows in table: ", cursor.rowcount)
    cursor.close()
    conn.close()

    return {"utilisateurs": records}
