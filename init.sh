#/home/dean/dean/projects1/withoutbonus/init.sh
#!/bin/bash
export ANSIBLE_HOST_KEY_CHECKING=False

# Step 1: Provision Infrastructure
(
  cd terraform
  terraform init 
  # terraform destroy -auto-approve
  terraform apply -auto-approve
)

# Step 2: Extract IPs
ips=$(cd terraform && terraform output -json instance_ips | jq -r '.[]')

# Step 3: Update Ansible Hosts
(
  cd ansible
  echo "[nats_cluster]" > hosts.ini
  for ip in $ips; do
    echo $ip >> hosts.ini
  done
)

# Step 4: Run Ansible Playbook
(
  cd ansible
  pwd  # prints current directory
  tree # prints directory structure
  ansible-playbook -i hosts.ini playbooks/install-nats.yml -vvv # to replace this line with this ? "" ansible-playbook playbooks/install-nats.yml
)
