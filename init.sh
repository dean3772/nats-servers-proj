#!/bin/bash
export ANSIBLE_HOST_KEY_CHECKING=False

# Step 1: Provision Infrastructure
(
  cd terraform
  terraform destroy -auto-approve
  terraform init --reconfigure
  terraform apply -auto-approve
)

# Step 2: Extract IPs
ips=$(cd terraform && terraform output -json instance_ips | jq -r '.[]')

echo "Waiting for servers to be ready..."

for ip in $ips; do
  while true; do
    # Try SSHing into the server. If it's successful, break the loop.
    ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i "~/.ssh/0923pairaws.pem" "ubuntu@$ip" 'exit 0' && break
    
    # If SSH failed, sleep for 5 seconds and try again
    sleep 5
  done
  echo "Server $ip is up!"
done

echo "All servers are up, proceeding with Ansible..."


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
