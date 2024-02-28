SOURCE_CSV_DIR:=.csvs
# on some systems docker must be ran with sudo as `DOCKER_COMMAND="sudo docker" make x`
DOCKER_COMMAND?=docker
POSTGRES_IMAGE?=postgres:16

default:
	@echo "No default action. Review Makefile and pick one."

AdventureWorks-oltp-install-script.zip:
	# -L - follows redirects
	# -OJ - saves the file according to Content Disposition header returned by the server
	#     the value of which is "AdventureWorks-oltp-install-script.zip"
	curl -LOJ -vv https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks-oltp-install-script.zip

${SOURCE_CSV_DIR}: AdventureWorks-oltp-install-script.zip
	unzip -d ${SOURCE_CSV_DIR} AdventureWorks-oltp-install-script.zip

${SOURCE_CSV_DIR}/csvs_are_converted: ${SOURCE_CSV_DIR}
	${DOCKER_COMMAND} run -it --rm \
		--mount type=bind,source=${PWD}/${SOURCE_CSV_DIR},target=/usr/app/csvs \
		--mount type=bind,source=${PWD}/update_csvs.rb,target=/usr/app/update_csvs.rb \
		-w /usr/app \
		ruby:latest \
		ruby update_csvs.rb /usr/app/csvs
	touch ${SOURCE_CSV_DIR}/csvs_are_converted


###################################

DB_DOCKER_NETWORK?=database
DB_DOCKER_VOLUME?=adventure_works_data

.PHONY: ensure_db_network_exists
ensure_db_network_exists:
	${DOCKER_COMMAND} network create ${DB_DOCKER_NETWORK} | true

.PHONY: ensure_db_volume_exists
ensure_db_volume_exists:
	${DOCKER_COMMAND} volume create adventure_works_data | true

.PHONY: db_start
db_start: ensure_db_network_exists ensure_db_volume_exists
	POSTGRES_IMAGE=${POSTGRES_IMAGE} \
	DB_DOCKER_VOLUME=${DB_DOCKER_VOLUME} \
	DB_DOCKER_NETWORK=${DB_DOCKER_NETWORK} \
	${DOCKER_COMMAND} compose -f docker-compose-postgres.yml up -d

.PHONY: db_stop
db_stop:
	POSTGRES_IMAGE=${POSTGRES_IMAGE} \
	DB_DOCKER_VOLUME=${DB_DOCKER_VOLUME} \
	DB_DOCKER_NETWORK=${DB_DOCKER_NETWORK} \
	${DOCKER_COMMAND} compose -f docker-compose-postgres.yml down

# used only for PSQL client to talk to the DB server
POSTGRES_USER?=postgres
POSTGRES_PASSWORD?=postgres
DB_NAME?=Adventureworks
# match db service container name in docker-compose-postgres.yaml
DB_HOST?=db
CONTAINER_DATA_DIR:=/mnt/src

${SOURCE_CSV_DIR}/create_db.sql: ${SOURCE_CSV_DIR}/csvs_are_converted
	printf "\
CREATE DATABASE \"${DB_NAME}\";\n\
GRANT ALL PRIVILEGES ON DATABASE \"${DB_NAME}\" TO ${POSTGRES_USER};\n\
" > ${SOURCE_CSV_DIR}/create_db.sql

${SOURCE_CSV_DIR}/install.sql: ${SOURCE_CSV_DIR}/csvs_are_converted
	cp ./install.sql ${SOURCE_CSV_DIR}/install.sql

${SOURCE_CSV_DIR}/install.sh: ${SOURCE_CSV_DIR}/create_db.sql ${SOURCE_CSV_DIR}/install.sql
	printf "\
cd ${CONTAINER_DATA_DIR}\n\
psql -h ${DB_HOST} < ${CONTAINER_DATA_DIR}/create_db.sql\n\
psql -h ${DB_HOST} -d ${DB_NAME} < ${CONTAINER_DATA_DIR}/install.sql\n\
" > ${SOURCE_CSV_DIR}/install.sh

.PHONY: upload_data
upload_data: ensure_db_network_exists ${SOURCE_CSV_DIR}/install.sh # db_start
	${DOCKER_COMMAND} run -it --rm \
		-e POSTGRES_USER=${POSTGRES_USER} \
		-e PGUSER=${POSTGRES_USER} \
		-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
		-e PGPASSWORD=${POSTGRES_PASSWORD} \
		--network ${DB_DOCKER_NETWORK} \
		-v ${PWD}/${SOURCE_CSV_DIR}:${CONTAINER_DATA_DIR} \
		-w ${CONTAINER_DATA_DIR} \
		${POSTGRES_IMAGE} \
		bash ./install.sh


.PHONY: db_console
db_console: ensure_db_network_exists # db_start
	${DOCKER_COMMAND} run -it --rm \
		-e POSTGRES_USER=${POSTGRES_USER} \
		-e PGUSER=${POSTGRES_USER} \
		-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
		-e PGPASSWORD=${POSTGRES_PASSWORD} \
		--network ${DB_DOCKER_NETWORK} \
		-v ${PWD}/${SOURCE_CSV_DIR}:${CONTAINER_DATA_DIR} \
		-w ${CONTAINER_DATA_DIR} \
		${POSTGRES_IMAGE} \
		psql -h ${DB_HOST} -d ${DB_NAME}

#####################################

.PHONY: clean
clean: clean
	rm -rf AdventureWorks-oltp-install-script.zip
	rm -rf ${SOURCE_CSV_DIR}
	rm -rf create_db.sql

.PHONY: clean-db
clean-db:
	@echo "Ensure DB is stopped ('make db_stop')"
	docker volume rm ${DB_DOCKER_VOLUME}
