# Debezium MongoDB issue DBZ-6516
The repository aims to reproduce the case reported in the issue [DBZ-6516](https://issues.redhat.com/browse/DBZ-6516)

**MongoDB Cluster topology**
- **2 Mongos** (router): The mongos acts as query routers, providing an interface
between client applications and the sharded cluster.
  - `router01`
  - `router02`
- **3 Config Servers**: Store metadata and configuration settings for the cluster
  - `configsvr01`
  - `configsvr02`
  - `configsvr03`
- **3 Shards** (each a 3 member replica set): Each shard contains a subset of
the sharded data. Each shard can be deployed as a replica set.
  - `shard01-a`, `shard01-b`, `shard01-c`
  - `shard02-a`, `shard02-b`, `shard02-c`
  - `shard03-a`, `shard03-b`, `shard03-c`


## Installation
Clone this repo:

```bash
git clone https://github.com/mronconis/debezium-mongodb-DBZ-6516.git
cd debezium-mongodb-DBZ-6516
```
and run `Makefile`:

```bash
make
```

## Steps to reproduce issue DBZ-6516
Proceed with the next steps only after the thread monitor of task-0 is properly connected:

```bash
docker logs -f connect01 | grep "INFO \[mongodb-connector|task-0\] Monitor thread successfully"
```

***Result***
```
... INFO [mongodb-connector|task-0] Monitor thread successfully connected to server with description ...
```

### Step 1

```bash
# Insert one record on collection
docker exec router01 sh -c "mongo < /scripts/insert_sample.js"
```

```bash
# Verify if processed by debezium
docker exec -it kafka01 /kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic dbserver1.inventory.fooevent --from-beginning
```

```bash
# Verify connector metrics
docker exec -it connect01 curl http://localhost:9404/metrics | grep "^debezium_metrics_MilliSecondsBehindSource"
```

***Result OK***
```
debezium_metrics_MilliSecondsBehindSource{context="streaming",name="dbserver1, task=0",plugin="mongodb",} 85.0
```

### Step 2

Restart another task other than task-0:
```bash
# Restart task X
curl -X POST localhost:8083/connectors/mongodb-connector/tasks/2/restart
```

### Step 3

```bash
# Insert one record on collection
docker exec router01 sh -c "mongo < /scripts/insert_sample.js"
```

```bash
# Verify if processed by debezium
docker exec -it kafka01 /kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic dbserver1.inventory.fooevent --from-beginning
```

```bash
# Verify connector metrics
docker exec -it connect01 curl http://localhost:9404/metrics | grep "^debezium_metrics_MilliSecondsBehindSource"
```

***Result KO***
```
debezium_metrics_MilliSecondsBehindSource{context="streaming",name="dbserver1, task=0",plugin="mongodb",} -1.0
```
