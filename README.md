# Project Title: 3-Node NATS Cluster Deployment with Ansible and Terraform

## Overview
 - This project automates the deployment of a 3-node NATS cluster using Ansible and Terraform. The Ansible playbook installs and configures NATS, while the Terraform script sets up the AWS infrastructure.

 - the python script aims to test the funcionality of the nats cluster by trying to subscribe to a subject on one node and publish to the same subject on another node 

## Requirements
- AWS Account
- awscli
- Ansible
- Terraform
- jq (for JSON processing)
- python

## Language & Tools
- Ansible
- Terraform
- Shell scripting
- Python (for optional utilities)

## File Structure
Here's a basic outline of the file structure:

```
.
├── README.md
├── ansible
│   ├── ansible.cfg
│   ├── hosts.ini
│   ├── playbooks
│   │   └── install-nats.yml
│   └── roles
│       └── nats
│           ├── handlers
│           │   └── main.yml
│           └── tasks
│               ├── main.yml
│               ├── nats-server.service
│               └── templates
│                   └── nats.conf.j2
├── init.sh
├── python_scripts
│   ├── publishtest.py
│   └── requirements.txt
└── terraform
    └── main.tf
```

## Quickstart:
Set up AWS credentials
Make sure you've set your AWS credentials as environment variables.

### Clone the repository
```
git clone https://github.com/dean3772/nats-servers-proj.git
```
```
cd nats-servers-proj
```
### Install Python dependencies
```
pip install -r python_scripts/requirements.txt
```
### Run the init script:
##### the script will proviiton the infrustructure, 
##### extract the ip's of the servers from tf output,
##### inject those ip's in the ansible hosts.ini file,
##### and run the ansible playbook
```
chmod +x init.sh
./init.sh
```
## Detailed Documentation
#### Ansible Playbooks
-  install-nats.yml: Main playbook that installs and configures the NATS cluster.
- Role files (nats): Contains the tasks, handlers, and templates for configuring NATS.
#### Handlers:
- Reload systemd: Reloads the systemd daemon.
- Restart NATS: Restarts the NATS service.
#### Tasks:
- Installs required system packages.
- Downloads and installs NATS.
- Sets up NATS configuration.
- Ensures NATS is running as a service.
#### Terraform Scripts:



- main.tf: Contains the AWS resource declarations for the NATS cluster.
- AWS Resources
- VPC
- Subnets
- Security Groups
- EC2 Instances
### Test The Functionality of the 3-node nats cluster using Python Script:

```
cd python_script
pip install -r requirements.txt
python publishtest.py
```
### The script does the following:

 - Initialize Two NATS Clients: The script initializes two NATS clients connected to two different servers.
 - Asynchronous Operation: The script uses Python's asyncio library for non-blocking IO operations.
 - Message Subscription: The first NATS client subscribes to a topic called foo.
 - Publishing and Receiving Messages: The second NATS client publishes a message with a unique ID to the foo topic, which is received by the first client.
 - Unique Identifier: Each message contains a unique ID generated from the current UTC time and a random integer.
 - Confirmation: Both the publishing and receiving actions are confirmed before the script terminates.

