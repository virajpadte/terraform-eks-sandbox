TERRAFORM_IMAGE := "hashicorp/terraform:1.1.9"
THIS_FILE := $(lastword $(MAKEFILE_LIST))
AWS_PROFILE := "temp_sandbox"
AWS_ACCESS_KEY_ID := $(shell aws configure get "aws_access_key_id" --profile $(AWS_PROFILE))
AWS_SECRET_ACCESS_KEY := $(shell aws configure get "aws_secret_access_key" --profile $(AWS_PROFILE))
AWS_REGION := $(shell aws configure get region --profile $(AWS_PROFILE))
AWS_ACCOUNT := $(aws sts get-caller-identity --query "Account" --profile $(AWS_PROFILE))
# HELP
.PHONY: help
help: ## Shows information on all make targets for containerized terraform environment
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

# NERDCTL Targets
format: clean ## Format the terraform files
	@echo "Formating terraform files"
	@nerdctl run -e TF_VAR_access_key=$(AWS_ACCESS_KEY_ID) \
			-e TF_VAR_secret_key=$(AWS_SECRET_ACCESS_KEY) \
			-e TF_VAR_region=$(AWS_REGION) \
			-v `pwd`:/workspace \
			-w /workspace --name terraform-sandbox-node $(TERRAFORM_IMAGE) fmt -recursive

validate: clean ## Validate terraform files
	@echo "Initialize terraform workspace"
	@nerdctl run -e TF_VAR_access_key=$(AWS_ACCESS_KEY_ID) \
			-e TF_VAR_secret_key=$(AWS_SECRET_ACCESS_KEY) \
			-e TF_VAR_region=$(AWS_REGION) \
			-v `pwd`:/workspace \
			-w /workspace --name terraform-sandbox-node $(TERRAFORM_IMAGE) init -upgrade
		
	@$(MAKE) -f $(THIS_FILE) clean
	@echo "Validating terraform image file"
	@nerdctl run -e TF_VAR_access_key=$(AWS_ACCESS_KEY_ID) \
			-e TF_VAR_secret_key=$(AWS_SECRET_ACCESS_KEY) \
			-e TF_VAR_region=$(AWS_REGION) \
			-v `pwd`:/workspace \
			-w /workspace --name terraform-sandbox-node $(TERRAFORM_IMAGE) validate

plan: validate ## Build a terraform plan
	@$(MAKE) -f $(THIS_FILE) clean
	@echo "Synthesizing a terraform plan for this stack"
	@nerdctl run -e TF_VAR_access_key=$(AWS_ACCESS_KEY_ID) \
			-e TF_VAR_secret_key=$(AWS_SECRET_ACCESS_KEY) \
			-e TF_VAR_region=$(AWS_REGION) \
			-v `pwd`:/workspace \
			-w /workspace --name terraform-sandbox-node $(TERRAFORM_IMAGE) plan -out saved_plan

apply: plan ## Apply the terraform plan
	@echo "Do you want to proceed with deployment? [y/N]" && read ans && \
	if [ $${ans:-'N'} = 'y' ]; \
		then $(MAKE) -f $(THIS_FILE) clean; echo "Applying the synthesized plan using terraform"; \
		nerdctl run -e TF_VAR_access_key=$(AWS_ACCESS_KEY_ID) \
		-e TF_VAR_secret_key=$(AWS_SECRET_ACCESS_KEY) \
		-e TF_VAR_region=$(AWS_REGION) \
		-v `pwd`:/workspace \
		-w /workspace --name terraform-sandbox-node $(TERRAFORM_IMAGE) apply -auto-approve "saved_plan" ; \
	else echo "Please make changes and plan to deploy again..."; fi	
destroy: clean ## Delete the entire stack
	@nerdctl run -e TF_VAR_access_key=$(AWS_ACCESS_KEY_ID) \
			-e TF_VAR_secret_key=$(AWS_SECRET_ACCESS_KEY) \
			-e TF_VAR_region=$(AWS_REGION) \
			-v `pwd`:/workspace \
			-w /workspace --name terraform-sandbox-node $(TERRAFORM_IMAGE) plan  -destroy -out saved_plan

	@echo "WARNING!!! THIS STEP CANNOT BE REVERTED!!!\nAre you sure you want to delete the entire stack? [y/N]" && read ans && \
	if [ $${ans:-'N'} = 'y' ]; \
		then $(MAKE) -f $(THIS_FILE) clean; echo "Deleting the entire stack managed by terraform"; \
		nerdctl run -e TF_VAR_access_key=$(AWS_ACCESS_KEY_ID) \
		-e TF_VAR_secret_key=$(AWS_SECRET_ACCESS_KEY) \
		-e TF_VAR_region=$(AWS_REGION) \
		-v `pwd`:/workspace \
		-w /workspace --name terraform-sandbox-node $(TERRAFORM_IMAGE) apply -auto-approve "saved_plan" ; \
	else echo "Please make changes and plan to deploy again..."; fi

clean: ## Clean terraform container setup
	@nerdctl stop terraform-sandbox-node | True
	@nerdctl rm -v terraform-sandbox-node | True

# EKS Targets
setup-eks-config: ## Setup EKS access using Kubectl
	@echo "Setting up configuration to access eks-cluster using kubectl"
	@aws eks update-kubeconfig --name eks-cluster --profile $(AWS_PROFILE)

get-node-instances: ## Get EKS node instance IDs
	@kubectl get nodes -o=json | jq -r '.items[].spec.providerID' | grep -o 'i-[^\s]*'

connect-node: ## Setup SSM session to specific node. Please provide NODE_ID=<instance_id> as argument
	@aws ssm start-session --profile temp_sandbox --target $(NODE_ID)