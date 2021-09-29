# Confluent Multi Region Cluster Demo

## Pre-requsits
- docker, docker-compose
- browser

### 1. Start the demo

```
# Start the services
docker-compose up -d
```
```
# Wait for 60 seconds or so and check that services are running
docker-compose ps
```
If there are issues, start the services in parts, leave some time between each command
```
docker-compose up -d zookeeper-central broker-ccc
```
```
docker-compose up -d broker-west-1 broker-west-2 broker-east-3 broker-east-4
```
```
docker-compose up -d broker-west-5 broker-east-6
```
```
docker-compose up -d control-center
```
Check everything is healthy by pointing a browser at http://localhost:9021




### 2. Create topics
```
./scripts/lhs-create-topics.sh
```



### 3. Examine the topic descriptions, note leaders, replicas, observers, and min-insync-replica configurations
```
./scripts/lhs-describe-topics.sh
```
```
# Output should look something like this:
==> Describe topic: t1-stretched

Topic: t1-stretched	TopicId: McyCKJ6-T7C2NTsuLo5yQw	PartitionCount: 1	ReplicationFactor: 4	Configs: min.insync.replicas=3,confluent.placement.constraints={"version":1,"replicas":[{"count":2,"constraints":{"rack":"west-f"}},{"count":2,"constraints":{"rack":"east-f"}}],"observers":[]}
	Topic: t1-stretched	Partition: 0	Leader: 2	Replicas: 2,1,3,4	Isr: 2,1,3,4	Offline: 

==> Describe topic: t1-stretched-with-observers

Topic: t1-stretched-with-observers	TopicId: qx9kT_KHR2a3OBitNxAJLQ	PartitionCount: 1	ReplicationFactor: 6	Configs: min.insync.replicas=3,confluent.placement.constraints={"observerPromotionPolicy":"under-min-isr","version":2,"replicas":[{"count":2,"constraints":{"rack":"west-f"}},{"count":2,"constraints":{"rack":"east-f"}}],"observers":[{"count":1,"constraints":{"rack":"west-o"}},{"count":1,"constraints":{"rack":"east-o"}}]}
	Topic: t1-stretched-with-observers	Partition: 0	Leader: 2	Replicas: 2,1,4,3,5,6	Isr: 1,2,3,4	Offline: 	Observers: 5,6

```



### 4. Run producers and consumers (do each of these in a different terminal)

```
./scripts/lhs-run-producer-t1-stretched.sh
```
```
./scripts/lhs-run-producer-t1-stretched-with-observers.sh
```
```
./scripts/lhs-run-consumer-t1-stretched.sh
```
```
./scripts/lhs-run-consumer-t1-stretched-with-observers.sh
```



### 5. Simulate failure of a Data Center
```
# Stop the brokers
docker-compose stop broker-west-1 broker-west-2 broker-west-5
```
```
# Notice how the producer for t1-stretched get's producer errors;
ERROR Error when sending message to topic t1-stretched with key: null, value: 55 bytes with error: (org.apache.kafka.clients.producer.internals.ErrorLoggingCallback)
org.apache.kafka.common.errors.NotEnoughReplicasException: Messages are rejected since there are fewer in-sync replicas than required.

# However the producer to t1-stretched-with-observers continues uninterrupted

# Note both producers may get metadata refresh messages
```
```
# Describe the topics
./scripts/lhs-describe-topics.sh
```
```
# Output should look like below
# Notice how:
# - both topics have gone through leader election
# - t1-stretched has 2 in-sync-replicas, and this is below the minimum of 3
# - t1-stretched with observers has 3 in-sync-replicas because the observer has joined the in-sync-replica list
==> Describe topic: t1-stretched

Topic: t1-stretched	TopicId: McyCKJ6-T7C2NTsuLo5yQw	PartitionCount: 1	ReplicationFactor: 4	Configs: min.insync.replicas=3,confluent.placement.constraints={"version":1,"replicas":[{"count":2,"constraints":{"rack":"west-f"}},{"count":2,"constraints":{"rack":"east-f"}}],"observers":[]}
	Topic: t1-stretched	Partition: 0	Leader: 3	Replicas: 2,1,3,4	Isr: 3,4	Offline: 2,1

==> Describe topic: t1-stretched-with-observers

Topic: t1-stretched-with-observers	TopicId: qx9kT_KHR2a3OBitNxAJLQ	PartitionCount: 1	ReplicationFactor: 6	Configs: min.insync.replicas=3,confluent.placement.constraints={"observerPromotionPolicy":"under-min-isr","version":2,"replicas":[{"count":2,"constraints":{"rack":"west-f"}},{"count":2,"constraints":{"rack":"east-f"}}],"observers":[{"count":1,"constraints":{"rack":"west-o"}},{"count":1,"constraints":{"rack":"east-o"}}]}
	Topic: t1-stretched-with-observers	Partition: 0	Leader: 4	Replicas: 2,1,4,3,5,6	Isr: 3,4,6	Offline: 5,1,2	Observers: 5,6

```



### 6. Restart the failed Data Centre and describe the topics
```
# Restart the brokers (notice that the producer for t1-stretched starts producing again - producers may get metadata messages)
docker-compose start broker-west-1 broker-west-2 broker-west-5
```
```
# Describe the topics (depending on when this is run, leader election may have run restoring the original leader)
./scripts/lhs-describe-topics.sh

```



### 7. Simulate observer catch up
```
Stop the brokers that host the observer replicas (broker-west-5, broker-east-6).
The observer replicas will now fall behind the regular replicas.
Stop the remaining brokers in the west data center (broker-west-1, broker-west-2).
Note how this time the producer for t1-stretched-with-observers starts getting "not enough replica" errors as the observer cannot join the ISR list.
Start the broker with the observer (broker-east-6).
Note how the broker starts, the observer catches up and joins the ISR list.
The producer can now carry on as before.
```
