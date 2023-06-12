export MONGODB_VERSION := 4.4.22
export STRIMZI_VERSION := latest-kafka-3.1.0
export DEBEZIUM_VERSION := 1.9
export DEBEZIUM_CONNECTOR_VERSION := 1.9.7.Final

all: up config

config: init-mongodb init-connector

.PHONY: all

up:
	docker-compose up --build -d

down:
	docker-compose down

init-mongodb:
	sleep 10
	docker-compose exec configsvr01 sh -c "mongo < /scripts/configserver.js"

	sleep 10
	docker-compose exec shard01-a sh -c "mongo < /scripts/replicaset_1.js"
	docker-compose exec shard02-a sh -c "mongo < /scripts/replicaset_2.js"
	docker-compose exec shard03-a sh -c "mongo < /scripts/replicaset_3.js"

	sleep 10
	docker-compose exec router01 sh -c "mongo < /scripts/router.js"

	sleep 2
	docker-compose exec router01 sh -c "mongo < /scripts/init_inventory.js"

init-connector:
	curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @connect/config.json
