import logging
import azure.functions as func
from azure.data.tables import TableClient
import os
import json

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Processing visitor counter request.")

    connection_string = os.environ["AzureWebJobsStorage"]
    table_name = os.environ["TABLE_NAME"]

    table_client = TableClient.from_connection_string(
        conn_str=connection_string,
        table_name=table_name
    )

    # Match the entity you inserted: PartitionKey=resume, RowKey=counter, count=1
    entity = table_client.get_entity(partition_key="resume", row_key="counter")
    entity["count"] = int(entity["count"]) + 1
    table_client.update_entity(entity)

    return func.HttpResponse(
        json.dumps({"count": entity["count"]}),
        mimetype="application/json",
        status_code=200
    )


