import logging
import os
import json
import azure.functions as func
from azure.cosmos import CosmosClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Visitor counter function triggered.')

    url = os.environ["COSMOS_DB_URL"]
    key = os.environ["COSMOS_DB_KEY"]
    database_name = "ResumeDB"
    container_name = "Counter"

    client = CosmosClient(url, credential=key)
    database = client.get_database_client(database_name)
    container = database.get_container_client(container_name)

    item_id = "visitorCounter"
    partition_key = "counterPartition"

    try:
        item = container.read_item(item=item_id, partition_key=partition_key)
        item["count"] += 1
        container.upsert_item(item)
        count = item["count"]
    except Exception as e:
        logging.error(f"Error updating counter: {e}")
        return func.HttpResponse(
            json.dumps({"error": "Error updating visitor counter"}),
            mimetype="application/json",
            status_code=500
        )

    return func.HttpResponse(
        json.dumps({"count": count}),
        mimetype="application/json",
        status_code=200
    )


