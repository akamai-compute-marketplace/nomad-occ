# HashiCorp Nomad One-Click CLUSTER

HashiCorp Nomad is a simple and flexible container orchestration platform for managing workloads at scale. The Akamai Connected Cloud One-Click CLUSTER will deploy _3_ Nomad Servers and _3_ Nomad Clients, bootstrapped into a single cluster and ready to accept jobs. 
_Limitations: The current bootstrap method limits to ONE server cluster per datacenter._

## Software Included on Nomad Servers

| Software  | Version   | Description   |
| :---      | :----     | :---          |
| Nomad     | 1.5.2     | HashiCorp Container Orchestration |
| Consul    | 1.16.1     | HashiCorp Service Discovery Mesh |
| Fail2ban  | 0.11.2    | Provides protection against brute force and authentication attempts |
| UFW       | 0.36      | Easy-to-use firewall wrapper used to allow HTTP/S and SSH ports |
| Certbot   | 1.12      | Is used to obtain HTTPS/TLS/SSL certificate for the provided domain |

## Software Included on Nomad Clients 

| Software  | Version   | Description   |
| :---      | :----     | :---          |
| Nomad     | 1.5.2     | HashiCorp Container Orchestration |
| Consul    | 1.16.1    | HashiCorp Service Discovery Mesh |
| Docker    | latest    | Container Management Service |
| Java      | 17.0.1    | Java JDK |
| Fail2ban  | 0.11.2    | Provides protection against brute force and authentication attempts |
| UFW       | 0.36      | Easy-to-use firewall wrapper used to allow HTTP/S and SSH ports |
| Certbot   | 1.12      | Is used to obtain HTTPS/TLS/SSL certificate for the provided domain |

**Supported Distributions:**

- Ubuntu 22.04 LTS

## Linode Helpers Included

| Name  | Action  |
| :---  | :---    |
| Hostname   | Assigns a hostname to the Linode based on domains provided via UDF or uses default rDNS. | The Hostname module accepts a UDF to assign a FQDN and write to the `/etc/hosts` file. If no domain is provided the default `ip.linodeusercontent.com` rDNS will be used. For consistency, DNS and SSL configurations should use the Hostname generated `_domain` var when possible. |
| Update Packages   | The Update Packages module performs apt update and upgrade actions as root.  |
| UFW   | Add UFW firewalls to the Linode  | The UFW module will import a `ufw_rules.yml` provided in `roles/$APP/tasks` and enables the service.  |
| Fail2Ban   | The Fail2Ban module installs, activates and enables the Fail2Ban service.  |

## Use our API

Customers can choose to the deploy the Nomad One-Click Cluster through the Linode Marketplace or directly using API. Before using the commands below, you will need to create an [API token](https://www.linode.com/docs/products/tools/linode-api/get-started/#create-an-api-token) or configure [linode-cli](https://www.linode.com/products/cli/) on an environment, and substitute for default values.

SHELL:
```
curl -H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-X POST -d '{
    "authorized_users": [
        "user1",
        "user2"
    ],
    "backups_enabled": false,
    "booted": true,
    "image": "linode/ubuntu22.04",
    "label": "nomad-occ",
    "private_ip": true,
    "region": "us-ord",
    "root_pass": "A_Really_Great_password",
    "stackscript_data": {
        "clusterheader": "Yes",
        "add_ssh_keys": "yes",
        "cluster_size": "6",
        "servers": "3",
        "clients": "3",
        "token_password": "LINODE_API_TOKEN",
        "sudo_username": "sudo_user"
        "email_address": "EMAIL_ADDRESS",
    },
    "stackscript_id": 1226544,
    "tags": [],
    "type": "g6-dedicated-4"
}' https://api.linode.com/v4/linode/instances
```
CLI:
```
linode-cli linodes create \
  --authorized_users user1 \
  --authorized_users user2 \
  --backups_enabled false \
  --booted true \
  --image 'linode/ubuntu22.04' \
  --label nomad-occ \
  --private_ip true \
  --region us-ord \
  --root_pass A_Really_Great_password \
  --stackscript_data '{"clusterheader": "Yes","add_ssh_keys":"yes","cluster_size":"3","clients":"3","token_password":"LINODE_API_TOKEN","sudo_username":"user1"}' \
  --stackscript_id 1226544 \
  --type g6-dedicated-4
```

## Resources

- [Create Linode via API](https://www.linode.com/docs/api/linode-instances/#linode-create)
- [Stackscript referece](https://www.linode.com/docs/guides/writing-scripts-for-use-with-linode-stackscripts-a-tutorial/#user-defined-fields-udfs)
