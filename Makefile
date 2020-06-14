INFRA_PATH = infra

run:
	docker run -it --rm -p 8080:5000 simpleapi

image:
	docker build -t simpleapi .

env:
	docker run -it \
		--name build-server \
		-p 8080:8080 -p 50000:50000 \
		--mount source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind \
		-v ${PWD}:/aws \
		--entrypoint 'bash' \
		amazon/aws-cli

run-env:
	docker start build-server && docker exec -it build-server /bin/bash

init-infra:
	terraform init ${INFRA_PATH}

plan:
	terraform plan ${INFRA_PATH}

apply:
	terraform apply -auto-approve ${INFRA_PATH}

fmt:
	terraform fmt -recursive -check

kill:
	terraform destroy -auto-approve ${INFRA_PATH}
	rm -f key.pem