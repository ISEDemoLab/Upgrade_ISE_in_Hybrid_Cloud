# Upgrade_ISE_in_Hybrid_Cloud/iteration_2

This folder is the third to be run in the Upgrade process.  It contains all the Playbooks necessary to deregister the "secondary" PSNs from the ISE 3.2 deployment, delete them, create ISE 3.3 PSNs and register them to the ISE 3.3 deployment.  PSNs are assigned to the Node Groups.

|Playbook|Function|
|---|---|
|01-remove_nodes.yaml|Deregisters the following nodes from the ISE 3.2 deployment<br>- `azure-psn2`<br>- `oci-psn2`<br>- `aws-psn2`|
|02-delete_azure_32.yaml|Deletes the `azure-psn2`, NIC, and OS disk from Azure|
|03-delete_oci_psn.yaml|Deletes `oci-psn2` from OCI|
|04-delete_aws_psn.yaml|Deletes `aws-psn2` from AWS|
|05-create_azure_33.yaml|Creates an ISE 3.3 instance on Azure|
|06-create_oci_33.yaml|Creates an ISE 3.3 instance on OCI|
|07-create_aws_33.yaml|Creates an ISE 3.3 instance on AWS|
|08-wait_for_ise_login.yaml|Waits for https://{{isenode}}.securitydemo.net/admin/login.jsp to be accessible, meaning that the Application Server process is `Running`|
|09-enable_api.yaml|Enable ERS API and Open API on the new nodes|
|10-create_ftp_respository.yaml|Creates a repository named `FTP` on the new nodes|
|11-patch_install.yaml|Placeholder playbook to use when ISE 3.3 patches are released|
|12-add_nodes.yaml|Adds the new nodes to this deployment and assigns them to Node Groups|
|13-iteration_1_complete.yaml|Visual and email notification that this iteration is complete|
|main.yaml|Uses `ansible.builtin.import_playbook` to run all the necessary Playbooks|


## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>