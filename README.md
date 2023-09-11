# nomad-occ
HashiCorp Nomad One-Click Cluster

!!! DEPLOYMENT INSTRUCTIONS !!!

Fork this repo and generate a new PAT with at least RO permissions for it. 

Put the PAT here: https://github.com/linode-solutions/nomad-occ_share/blob/main/scripts/ss.sh#L13

And your Git username here: https://github.com/linode-solutions/nomad-occ_share/blob/main/scripts/ss.sh#L14

Next, add ss.sh to the Cloud Manager as a new Stackscript. Deploy the Stackscript, ensuring you have a valid Linode API key. 

!!! KNOWN ISSUES !!!

Manually add the tag `consul-server` to the provisioner Linode. 

Only one server cluster per datacenter. For POC we're just leveraging auto-join with minimal logic, and running a second cluster in the same DC breaks bootstrap.

The Linode labeling scheme is currently simple (add integer per node) this means that if you have Linodes already named $INSTANCE_LABEL2 the deployment fails, falsely registering old Linodes as the new instances.
