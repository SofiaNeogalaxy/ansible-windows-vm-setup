# Windows VM Setup with Ansible Package Management
This repository provides Terraform and Ansible code to create and provision a Windows VM on Azure with various packages installed using Ansible.

### Prerequisites
Before using this repository, you need to have the following:

 - Azure account with an active subscription
 - Terraform CLI
 - Ansible CLI
 - Azure CLI
 
### Setup
To setup the environment, follow these steps:

Clone the repository and navigate to the repository directory
Initialize the Terraform environment:
```csharp

terraform init
```
Modify the variables.tf file according to your needs, for example, by specifying the desired region or VM size.
Deploy the infrastructure:
```
terraform apply
```
Once the infrastructure is deployed, navigate to the ansible directory and run the playbook:
```
ansible-playbook azure-cli.yaml generic.yaml prereqs.yaml localhost.yaml
```
Once the playbook is complete, you can verify that the packages have been installed on the VM.

### Files
This repository contains the following files:

 - main.tf: Terraform code to create the Windows VM and network resources.
 - outputs.tf: Terraform code to output the public IP of the VM.
 - providers.tf: Terraform code to specify the Azure provider.
 - ansible: Directory containing Ansible playbooks and inventory files.
   - azure-cli.yaml: Ansible playbook to install Azure CLI.
   - generic.yaml: Ansible playbook to install Git and Python.
   - hosts: Ansible inventory file specifying the IP address of the VM.
   - localhost.yaml: Ansible playbook to install Ansible on the VM.
   - prereqs.yaml: Ansible playbook to install various prerequisites.
