source environments/local/$1.sh

./infrastructure/local/switch_context.sh $1

gcloud pubsub topics create ${L2CACHE_EXCHANGE}
gcloud pubsub subscriptions create ${L2CACHE_UPDATE_QUEUE} --topic=${L2CACHE_EXCHANGE} --topic-project=${PROJECT_NAME} --ack-deadline=60 --expiration-period="never" --max-retry-delay=10

gcloud pubsub topics create ${PYCHUNKEDGRAPH_EDITS_EXCHANGE}
gcloud pubsub subscriptions create ${PYCHUNKEDGRAPH_REMESH_QUEUE} --topic=${PYCHUNKEDGRAPH_EDITS_EXCHANGE} --topic-project=${PROJECT_NAME} --ack-deadline=600 --expiration-period="never" --max-retry-delay=10 --message-filter='attributes.remesh_priority="true"'
gcloud pubsub subscriptions create ${PYCHUNKEDGRAPH_LOW_PRIORITY_REMESH_QUEUE} --topic=${PYCHUNKEDGRAPH_EDITS_EXCHANGE} --topic-project=${PROJECT_NAME} --ack-deadline=600 --expiration-period="never" --max-retry-delay=10 --message-filter='attributes.remesh_priority="false"' 
    
if ((${PCGL2CACHE_MAX_REPLICAS} > 0))
then
    echo "HERE"
    gcloud pubsub subscriptions create ${L2CACHE_TRIGGER_QUEUE} --topic=${PYCHUNKEDGRAPH_EDITS_EXCHANGE} --topic-project=${PROJECT_NAME} --ack-deadline=600 --expiration-period="never" --max-retry-delay=10 --message-filter='attributes.remesh_priority="true"'
    gcloud pubsub subscriptions create ${L2CACHE_LOW_PRIORITY_TRIGGER_QUEUE} --topic=${PYCHUNKEDGRAPH_EDITS_EXCHANGE} --topic-project=${PROJECT_NAME} --ack-deadline=600 --expiration-period="never" --max-retry-delay=10 --message-filter='attributes.remesh_priority="false"'
fi