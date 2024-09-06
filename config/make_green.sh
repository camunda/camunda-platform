#! /bin/sh

apk add curl;

curl -k --request PUT http://opensearch:9200/myauditlogindex/_settings --header "Content-Type: application/json" -u admin:${OPENSEARCH_INITIAL_ADMIN_PASSWORD} --data '{"index" : {"number_of_replicas" : 0}}'
