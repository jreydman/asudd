import psycopg2

def run_query(query: str):
    try:
        conn = psycopg2.connect(
            database="assud",
            user="admin",
            password="admin",
            host="localhost",
            port="5432"
        )

        cursor = conn.cursor()

        cursor.execute(query)
        conn.commit()

        print("Query executed")

        response_rows = cursor.fetchall()
        for response_row in response_rows:
            print(response_row)


    except psycopg2.Error as e:
        print(f"Error while work with database:\n{e}")
        return
