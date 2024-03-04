import pandas as pd
from psycopg2.extras import execute_values

def execute_query(conn,query):
    cursor = conn.cursor()
    cursor.execute(query)
    query_result = cursor.fetchall()
    conn.commit()
    cursor.close()
    return query_result

def pg_to_df(conn,query,column_names):
    query_result = execute_query(conn,query)
    df = pd.DataFrame(query_result,columns=column_names)
    return df

def df_to_pg(conn,table_name,table_header,df,page_size):
    with conn.cursor() as c:
        execute_values(
            cur=c
            ,sql=f"""
                INSERT INTO {table_name} ({",".join(table_header)})
                VALUES %s;
                """
            ,argslist=df.to_dict(orient="records")
            ,template=f"""
                (
                    {",".join([f"%({x})s" for x in table_header])}
                )
                """
            ,page_size=page_size
        )
    conn.commit()
    c.close()