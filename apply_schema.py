import argparse
import sys
from pathlib import Path

try:
    import psycopg2
except ImportError as e:
    print("psycopg2 is not installed. Please install with: pip install psycopg2-binary", file=sys.stderr)
    sys.exit(2)


def main() -> int:
    parser = argparse.ArgumentParser(description="Apply an SQL schema file to a PostgreSQL database.")
    parser.add_argument("connection", help="PostgreSQL connection string (DSN), e.g. postgresql://user:pass@host:port/dbname")
    parser.add_argument("sql_file", help="Path to the SQL schema file to execute.")
    args = parser.parse_args()

    sql_path = Path(args.sql_file).expanduser().resolve()
    if not sql_path.exists():
        print(f"SQL file not found: {sql_path}", file=sys.stderr)
        return 1

    sql_text = sql_path.read_text(encoding="utf-8")

    conn = None
    try:
        conn = psycopg2.connect(dsn=args.connection)
        # Autocommit so DDL executes immediately and we don't leave open transactions
        conn.autocommit = True
        with conn.cursor() as cur:
            cur.execute(sql_text)
        print(f"Applied schema from {sql_path} successfully.")

        # Optional: show created public tables as a quick verification
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                ORDER BY table_name
                """
            )
            tables = [r[0] for r in cur.fetchall()]
        if tables:
            print("Public tables:")
            for t in tables:
                print(f" - {t}")
        else:
            print("No public tables found.")

        return 0
    except Exception as e:
        print(f"Error applying schema: {e}", file=sys.stderr)
        return 1
    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())
