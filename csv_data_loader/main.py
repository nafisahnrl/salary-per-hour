import pandas as pd
import psycopg2
import json
import yaml
from pg import pg_to_df,df_to_pg

if __name__=='__main__':
    project_path = "/path/to/project"
    config_path = f"{project_path}/config"
    csv_path = f"{project_path}/sample_data"

    with open(f"{config_path}/config.yaml","r") as f:
        config=yaml.safe_load(f)

    conn = psycopg2.connect(database = config['database'],
                        user = config['user'],
                        host = config['host'],
                        password = config['password'],
                        port = config['port'])

    with open(f"{config_path}/list_table.json",'r') as f:
        tables = json.load(f)
    
    for table in tables:
        #get table name and primary key
        table_name = table['table']
        table_pk = table['pk']
        arr_table_pk = [x.strip() for x in table_pk.split(",")]

        #load source file to dataframe
        df_csv = pd.read_csv(f"{csv_path}/{table_name}.csv")
        
        #load target table to dataframe
        sql_existing_record = f"SELECT {table_pk} FROM {table_name}"
        df_target = pg_to_df(conn,sql_existing_record,arr_table_pk)

        #join source & target table, select csv row not in target table
        df_merged = pd.merge(df_csv,df_target,on=arr_table_pk,how='outer',indicator=True)
        df_new_data = df_merged[df_merged['_merge'] == 'left_only'].iloc[:,0:-1]

        #data preprocessing
        #replace Nan value to None
        df_new_data = df_new_data.where(pd.notnull(df_new_data),None)
        #remove record with repeated primary key 
        df_new_data.drop_duplicates(subset=arr_table_pk, keep='first',inplace=True)

        #new data ingestion    
        table_header = df_new_data.columns.tolist()
        df_to_pg(conn,table_name,table_header,df_new_data,config['chunksize'])


