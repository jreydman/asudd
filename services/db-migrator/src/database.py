import psycopg2

def client():
    client = psycopg2.connect(
        host="localhost",
        port="5432",
        database="assud",
        user="admin",
        password="admin"
    )

    return client

