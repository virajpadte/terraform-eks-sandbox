
# Terraform EKS Sandbox
[![forthebadge](http://forthebadge.com/images/badges/built-with-love.svg)](http://forthebadge.com)
 [![forthebadge](https://forthebadge.com/images/badges/open-source.svg)](https://forthebadge.com)

This repo provides a good starting point to deploy eks cluster using terraform. While looking around for good resources around this topics I found a ton of prebaked modules with abstracted variables for handling various scenarios such has managed node groups, custom AMIs, secrets management etc. However, in order to really understand all the resources needed to provision a working EKS cluster I decided to dissect each dependency in this module without leveraging any external dependent submodules. Hope this helps anyone who is looking to get started.

# Deploying terraform stack
Note: Before attempting to use the make target ensure that nerdctl is installed and rancher desktop is running a single k8 local cluster to support the terraform containers. This is a good reference to get started with rancher desktop as a docker desktop alternative.
```console
foo@bar:~$ cd terraform-eks-sandbox
foo@bar:~$ make
help                         - Shows information on all make targets for containerized terraform environment
format                       - Format the terraform files
validate                     - Validate terraform files
plan                         - Build a terraform plan
apply                        - Apply the terraform plan
destroy                      - Delete the entire stack
clean                        - Clean terraform container setup
```

### License Summary
This contribution is made available under the MIT-0 license. See the LICENSE file.

### Keep contributing to Open Source
लोकाः समस्ताः सुखिनोभवंतु
