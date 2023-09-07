# Upgrade_ISE_in_Hybrid_Cloud/setup

This folder is composed of the playbooks used to provision the initial ISE 3.2 deployment.  The files use VMware to host the Admin Nodes, but you can put them anywhere you'd like, just adjust the playbook files accordingly.

|Playbook|Function|
|---|---|
|01-setup_vmware.yaml|Creates 2 ISE instances on VMware ESXi, `vmware-admin` and `vmware-sadmin`|
|02-setup_azure.yaml|Creates 2 ISE instances as PSNs on Azure Cloud `azure-psn` and `azure-psn2`|
|03-setup_oci.yaml|Creates 2 ISE instances as PSNs on Oracle Cloud `oci-psn` and `oci-psn2`|
|04-setup_aws.yaml|Creates 2 ISE instances as PSNs on AWS `aws-psn` and `aws-psn2`|
|05-wait_for_padmin_login.yaml|pause playbooks until Primary and Secondary Admin nodes' Application Server is running|
|06-enable_api.yaml|Enables ERS API and Open API on all nodes|
|07-create_ftp_repository.yaml|Create an FTP repository and name it `FTP` on all nodes|
|08-patch_install.yaml|Install Patch 3 on all nodes|
|09-add_nodes.yaml|Converts `vmware-admin` to a Primary Node, registers all nodes to the deployment, creates Node Groups and adds PSNs to the Node Groups|
|10-certificates.yaml|Install Public Certificate and Root CA Certificate onto all ISE nodes|
|11-admin_pubkey_auth.yaml|Enables `PubkeyAuthentication` for `vmware-admin`|
|12-sadmin_pubkey_auth.yaml|Enables `PubkeyAuthentication` for `vmware-sadmin`|
|13-license_cssm.yaml|Registers the ISE node to Cisco Smart Licensing|
|14-deployment_complete.yaml|Displays a message after a successful deployment|
|15-delete_vmware.yaml|Delete `vmware-admin` and `vmware-sadmin` from VMware|
|create.yaml|Import and run all necessary playbooks to create the ISE 3.2 deployment in a single command|
|destroy.yaml|Import and run all necessary playbooks to deregister from Cisco Smart Licensing and destroy all 8 ISE instances |

I have PLAYS that show how to enable `PubkeyAuthentication` on ISE nodes in case you did not enable this through the ZTP process.  I _HIGHLY_ suggest you use this method to connect to ISE via SSH.  Not only is it more secure, but it allows the same mechanism to be used to SSH to ISE whether it exists on-prem or in the cloud.

## Run multiple playbooks sequentially:

```sh
ansible-playbook setup/create.yaml
```

Contents of setup/create.yaml. Each playbook will finish before moving on to the next. You can skip a playbook by commenting it out (add `# ` before the entry). You can see that I import playbooks from other folders as well.  This way, I don't need more than one copy of a Playbook if all the settings are the same.

I use this method to consistently initialize this 8-node deployment in **3 hours 25 minutes**.

```create.yaml
--- create.yaml
- name: Deploy Azure PSNs (ISE 3.2)
  ansible.builtin.import_playbook: 02-setup_azure.yaml
  tags: [ise32,azure,install]

- name: Deploy OCI PSNs (ISE 3.2)
  ansible.builtin.import_playbook: 03-setup_oci.yaml
  tags: [ise32,oci,install]

- name: Deploy AWS PSNs (ISE 3.2)
  ansible.builtin.import_playbook: 04-setup_aws.yaml
  tags: [ise32,aws,install]

- name: Deploy VMware nodes
  ansible.builtin.import_playbook: 01-setup_vmware.yaml
  tags: [ise32,vmware,install]

- name: Wait for Application Server to be available
  ansible.builtin.import_playbook: 05-wait_for_padmin_login.yaml  

- name: Wait for Application Server to be available
  ansible.builtin.import_playbook: ../iteration_1/08-wait_for_ise_login.yaml
  # From the `iteration_1` folder

- name: Wait for Application Server to be available
  ansible.builtin.import_playbook: ../iteration_2/08-wait_for_ise_login.yaml
  # From the `iteration_2` folder

- name: Enable APIs on Primary and Secondary Admin Nodes
  ansible.builtin.import_playbook: 06-enable_api.yaml

- name: Enable APIs on Iteration 1 Cloud PSNs
  ansible.builtin.import_playbook: ../iteration_1/09-enable_api.yaml
  # From the `iteration_1` folder

- name: Enable APIs on Iteration 2 Cloud PSNs
  ansible.builtin.import_playbook: ../iteration_2/09-enable_api.yaml
  # From the `iteration_2` folder

- name: Configure FTP Repository on Admin Nodes
  ansible.builtin.import_playbook: 07-create_ftp_repository.yaml
  tags: [repo,ftp]

- name: Configure FTP Repository on Iteration 1 Cloud PSNs
  ansible.builtin.import_playbook: ../iteration_1/10-create_ftp_repository.yaml
  tags: [repo,ftp]
  # From the `iteration_1` folder

- name: Configure FTP Repository on Iteration 2 Cloud PSNs
  ansible.builtin.import_playbook: ../iteration_2/10-create_ftp_repository.yaml
  tags: [repo,ftp]
  # From the `iteration_2` folder

- name: Install latest patch for ISE release
  ansible.builtin.import_playbook: 08-patch_install.yaml
  tags: [ise32,patch]

- name: Wait for Application Server to be available
  ansible.builtin.import_playbook: 05-wait_for_padmin_login.yaml  

- name: Wait for Application Server to be available
  ansible.builtin.import_playbook: ../iteration_1/08-wait_for_ise_login.yaml
  # From the `iteration_1` folder

- name: Wait for Application Server to be available
  ansible.builtin.import_playbook: ../iteration_2/08-wait_for_ise_login.yaml
  # From the `iteration_2` folder

- name: Add Nodes to the deployment
  ansible.builtin.import_playbook: 09-add_nodes.yaml

- name: Install CA Cert and System Cert on Primary Admin Node
  ansible.builtin.import_playbook: 10-certificates.yaml

- name: Wait for Application Server to be available
  ansible.builtin.import_playbook: 05-wait_for_padmin_login.yaml  

- name: Wait for Application Server to be available
  ansible.builtin.import_playbook: ../iteration_1/08-wait_for_ise_login.yaml
  # From the `iteration_1` folder

- name: Wait for Application Server to be available
  ansible.builtin.import_playbook: ../iteration_2/08-wait_for_ise_login.yaml
  # From the `iteration_2` folder

- name: Register to Licensing
  ansible.builtin.import_playbook: 13-license_cssm.yaml

- name: Deployment Complete!
  ansible.builtin.import_playbook: 14-deployment_complete.yaml
```

## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>