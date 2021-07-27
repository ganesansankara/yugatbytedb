#!/bin/sh

#In order to enable coomunicatin between containers need network
DOCKER_CMD="sudo docker"
PS_CMD="${DOCKER_CMD} ps -a"

MYIPADDR=`hostname -I | awk '{print $1}'`
echo MYIPADDR=${MYIPADDR}

superset_standalone()
{
    # Install superset
pip install apache-superset

# Initialize the database
superset db upgrade

# Create an admin user (you will be prompted to set a username, first and last name before setting a password)
export FLASK_APP=superset
superset fab create-admin

# Load some data to play with
#superset load_examples

# Create default roles and permissions
superset init

# To start a development web server on port 8088, use -p to bind to another port
superset run -h 0.0.0.0 -p 8088 --with-threads --reload --debugger
}
superset_setup () {

#Clone Superset's Github repository
#Clone Superset's repo in your terminal with the following command:

#git clone https://github.com/apache/superset.git
#Once that command completes successfully, you should see a new superset folder in your current directory.

#3. Launch Superset Through Docker Compose
#Navigate to the folder you created in step 1:

# cd superset
#Then, run the following command:
#touch ./docker/requirements-local.txt
#echo exasol > ./docker/requirements-local.txt
#Rebuild your local image with the new driver baked in:
#docker-compose build --platform linux/amd64 --force-rm
#docker-compose --platform linux/amd64  -f docker-compose-non-dev.yml up


cname=ganesan-superset
#Superset
${DOCKER_CMD} build --platform linux/amd64 --tag ${cname} --file ./SuperSetDockerFile .
#${DOCKER_CMD} run --platform linux/amd64 -d --name ${cname}  -p 8080:8080 ${cname} 
#${DOCKER_CMD} start ${cname} 

#${DOCKER_CMD} run --platform linux/amd64 -it ${cname}  /bin/bash
${DOCKER_CMD} run --platform linux/amd64 -d --name ${cname} -p 8080:8080 ${cname} superset run -h 0.0.0.0 -p 8080 --debugger 
${DOCKER_CMD} exec -it ${cname} superset db upgrade
${DOCKER_CMD} exec -it ${cname} superset fab create-admin \
               --username admin \
               --password admin \
               --firstname Superset \
               --lastname Admin \
               --email admin@superset.com 

#Setup roles
${DOCKER_CMD}  exec -it ${cname}  superset init




${PS_CMD}

http://${MYIPADDR}:8080/login/

http://localhost:8080/login/
# For gitpod
#gp preview http://localhost:8080

}

exasol_setup () {
#Exasol
cname=ganesan-exasol
#sudo rm -rf ~/.local/*
#Make persitent volume so data survives in restarts
PVOL=$HOME/Ganesan/docker/volumes/exasol
sudo rm -rf ${PVOL}
mkdir -p ${PVOL}


${DOCKER_CMD} build --platform linux/amd64  --tag ${cname} --file ./ExasolDockerFile .
${DOCKER_CMD} run --platform linux/amd64 -it --name ${cname} -p 9563:8563 --privileged --stop-timeout 120 -v exa_volume:${PVOL} ${cname} 

${DOCKER_CMD} start ${cname} 
#${DOCKER_CMD} run --platform linux/amd64 -it --name ${cname}  -p 9563:8563 --privileged --stop-timeout 120 -v exa_volume:${PVOL} exasol/docker-db:latest


${PS_CMD}
}
yugabytedb_setup () {
#Yugabytedb

#sudo rm -rf ~/.local/*
#Make persitent volume so data survives in restarts
PVOL=$HOME/Ganesan/docker/volumes/yugabyte
sudo rm -rf ${PVOL}
mkdir -p ${PVOL}


#${DOCKER_CMD} build --tag ganesan-yugabyte --file ./YugabytedbDockerFile .
#${DOCKER_CMD} run -d --name ganesan-yugabyte -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042  ganesan-yugabyte
#${DOCKER_CMD} run -d --name ganesan-yugabyte -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042 -v ${PVOL}:/home/yugabyte/var -e POSTGRES_DB=ganesan-yugabyte  -e POSTGRES_USER=ganesan -e POSTGRES_PASSWORD=password1  ganesan-yugabyte
${DOCKER_CMD} run -d --name ganesan-yugabyte  -p7000:7000 -p9000:9000 -p5433:5433 -p9042:9042 -v ${PVOL}:/home/yugabyte/var yugabytedb/yugabyte:latest bin/yugabyted start --daemon=false

#${DOCKER_CMD} start ganesan-yugabyte
#${DOCKER_CMD} exec -it ganesan-postgres bash


${PS_CMD}
}


rabbitmq_setup () {
#Raabbit MQ
#${DOCKER_CMD} run -d --hostname cash-amqp --name s2btocash-amqp rabbitmq:3
${DOCKER_CMD} run -d --hostname cash-amqp --name s2btocash-amqp -p 15672:15672 -p 5671:5671 -p 5672:5672 -p 15671:15671 -p 25672:25672  -e RABBITMQ_DEFAULT_USER=ganesan -e RABBITMQ_DEFAULT_PASS=password rabbitmq:3-management

# Solace
#${DOCKER_CMD} run -d --name solace -p 8080:8080 -p 55555:55555 \
#--shm-size=1g --env username_admin_globalaccesslevel=admin --env username_admin_password=admin \
#solace/solace-pubsub-standard
#${DOCKER_CMD} start solace
}
minio_setup () {
#Miniio


${DOCKER_CMD} stop cash
NAS_FOLDER=/tmp/cash
sudo rm -rf ${NAS_FOLDER}
mkdir ${NAS_FOLDER}
${DOCKER_CMD} run -d --name cash -p 192.168.1.122:9000:9000 \
 -e "MINIO_ACCESS_KEY=minio" \
 -e "MINIO_SECRET_KEY=minio123" \
 -v ${NAS_FOLDER}:/container/vol \
 minio/minio gateway nas /container/vol
${DOCKER_CMD} start cash


#${DOCKER_CMD} run -d --name miniocli  minio/mc
#${DOCKER_CMD} start miniocli
mc_host=cash
mc_bucket=${mc_host}/s2btocash

sleep 30
${DOCKER_CMD} run -a STDIN --name ganesan-miniocli  --entrypoint=/bin/sh minio/mc <<!EOF

mc config host add ${mc_host} http://${MYIPADDR}:9000 minio minio123
mc mb ${mc_bucket}
#cat /root/.mc/config.json;
mc admin config set ${mc_bucket} notify_amqp:1 exchange="bucketevents" exchange_type="fanout" mandatory="false" no_wait="false"  url="amqp://ganesan:password@${MYIPADDR}:5672" auto_deleted="false" delivery_mode="0" durable="false" internal="false" routing_key="bucketlogs"
mc admin service restart ${mc_bucket}
mc event add ${mc_bucket} arn:minio:sqs::1:amqp 
exit;
!EOF

}

postgres_setup () {
#Postgres


#sudo rm -rf ~/.local/*
#Make persitent volume so data survives in restarts
PVOL=$HOME/Ganesan/docker/volumes/postgres
#sudo rm -rf ${PVOL}
mkdir -p ${PVOL}


${DOCKER_CMD} build --tag ganesan-postgres --file ./PostgresDockerFile .
${DOCKER_CMD} run -d --name ganesan-postgres -p 5432:5432 -p 9187:9187 -v ${PVOL}:/var/lib/postgresql/data -e POSTGRES_DB=ganesan-postgres  -e POSTGRES_USER=ganesan -e POSTGRES_PASSWORD=password1  ganesan-postgres

${DOCKER_CMD} start ganesan-postgres
#${DOCKER_CMD} exec -it ganesan-postgres bash


${PS_CMD}
}

dremio_setup () {
#Dremio

${DOCKER_CMD} build --tag ganesan-dremio --file ./DremioDockerFile .
${DOCKER_CMD} run -d --name ganesan-dremio -p 9047:9047 -p 31010:31010 -p 45678:45678 -p 47470:47470 ganesan-dremio
${DOCKER_CMD} start ganesan-dremio
${PS_CMD}

#Add user for Dremio
# Add Dremio Admin user

#curl 'http://localhost:9047/apiv2/bootstrap/firstuser' -X PUT \
#     -H 'Authorization: _dremionull' -H 'Content-Type: application/json' \
#     --data-binary '{"userName":"ganesan","password":"malathi9","firstName":"Gan","lastName":"S","email":"banana@banana.com","createdAt":1526186430755}'

#ip addr show


sleep 20
${PS_CMD}
}

# Call functions
#postgres_setup
#dremio_setup
#rabbitmq_setup
#minio_setup
#yugabytedb_setup
#exasol_setup
superset_setup
#superset_standalone

