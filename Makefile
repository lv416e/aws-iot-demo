tf-plan:
	terraform init
	terraform fmt
	terraform validate
	terraform plan

tf-deploy:
	terraform init -upgrade
	terraform fmt
	terraform validate
	terraform destroy -auto-approve
	terraform apply -auto-approve
	aws s3 cp --profile terraform --recursive keys s3://iot-bucket-20230624/keys

tf-apply:
	terraform init
	terraform fmt
	terraform apply -auto-approve

tf-destroy:
	terraform destroy -auto-approve