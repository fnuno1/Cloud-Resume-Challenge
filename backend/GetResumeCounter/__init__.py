import logging
import os
import azure.functions as func
from azure.cosmos import CosmosClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Visitor counter function triggered.')

    # Pull connection details from local.settings.json
    url = os.environ["COSMOS_DB_URL"]
    key = os.environ["COSMOS_DB_KEY"]
    database_name = "ResumeDB"
    container_name = "Counter"

    client = CosmosClient(url, credential=key)
    database = client.get_database_client(database_name)
    container = database.get_container_client(container_name)

    # Read the counter item (replace with your actual id/partition key)
    item_id = "visitorCounter"
    partition_key = "counterPartition"

    try:
        item = container.read_item(item=item_id, partition_key=partition_key)
        item["count"] += 1
        container.upsert_item(item)
        count = item["count"]
    except Exception as e:
        logging.error(f"Error updating counter: {e}")
        return func.HttpResponse("Error updating visitor counter", status_code=500)

    return func.HttpResponse(str(count), status_code=200)

