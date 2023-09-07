# Upgrade_ISE_in_Hybrid_Cloud

Upgrading ISE has been a large thorn in the side of ISE administrators since it was released.  The release of ISE 3.3 saw the introduction of the **New Split Upgrade** process flow.  This flow significantly reduces the time it takes to upgrade an ISE deployment.  However, in-place upgrades are *still* not supported in cloud deployed ISE instances.  This means that whether you have ISE installed in AWS, Azure, or Oracle Cloud (OCI), your only recourse is the Backup and Restore method.

What I have done with this collection of Playbooks is create an 8-node ISE 3.2 Patch 3 deployment in ***four different environments*** (AWS, Azure, OCI, VMware ESXi).  I've then upgraded the deployment to ISE 3.3 using the same method as the GUI-based New Split Upgrade, but instead of in-place upgrades, all nodes are upgraded using the Backup and Restore Method.

The Ansible playbook folders in this repository are listed in this table with their functions:

|Playbook Folder|Function|
|---|---|
|admin_1/|Deregister the Secondary Admin Node from the ISE 3.2 Deployment, delete it, create new VM (3.3), Convert to Primary, Backup 3.2 deployment and restore the backup to this new node|
|admin_2/|Deregister the 3.2 deployment from Cisco Smart Licensing, Delete the 3.2 Primary Admin Node, Create new VM, add it to teh 3.3 deployment, promote to Primary Admin, Register to Cisco Smart Licensing|
|inventory/|Creates a Dynamic Inventory for the specified provider|
|iteration_1/|Deregister the iteration 1 cloud based PSNs from the 3.2 deployment and delete them, create new 3.3 PSNs and register them to the 3.3 deployment|
|iteration_2/|Deregister the iteration 2 cloud based PSNs from the 3.2 deployment and delete them, create new 3.3 PSNs and register them to the 3.3 deployment|
|notifications/|Templates and playbooks for sending email notifications|
|password_reset/|Password reset playbooks for all ISE nodes in the deployment|
|setup/|Create the Base ISE 3.2 Patch 3 deployment with 8 nodes|
|templates/|JSON template files for Azure Resource Manager Deployments|
|vars/|Files used to create variables referenced throughout the Playbooks|
|ztp/|Files used to create the ZTP configuration for ISE nodes installed on VMware|

To use Zero Touch Provisioning (ZTP) with VMware, you need to have an understanding of this article:  [ISE Zero Touch Provisioning (ZTP)](https://community.cisco.com/t5/security-knowledge-base/ise-zero-touch-provisioning-ztp/ta-p/4541606)

## Goals

There were two goals for this project :

- To upgrade the entire deployment with *no interaction* other than starting the process.
- To be able to upgrade an 8 node deployment within one single 8 hour work shift.  Upgrading ISE is TIME CONSUMING, I know it.  Having been on the *planning/maintenance window/change window/waiting* side of many ISE upgrades, I wanted to streamline this process so that I would not have to work longer than necessary for the process to complete.
   - The process used in these Playbooks takes a total of ***6 HOURS*** to upgrade all 8 nodes with consistency and repeatability.  I have gone through this process and refined it over and over (moving playbooks and tasks around, trying different modules/APIs) to find the shortest amount of time I could for this Upgrade.
   - Have a larger deployment?  Great!  If your nodes are set up in a primary/secondary, or primary/secondary/tertiary, or behind a load balancer, just add the PSNs to `iteration_1` and `iteration_2`.  You'll be happy to find that the time added for these PSNs is rather short!

## Quick Start

Clone this repository:

```sh
git clone https://github.com/ISEDemoLab/Upgrade_ISE_in_Hybrid_Cloud.git
```

Create your Python environment and install Ansible:

> ⚠ Installing Ansible using Linux packages (`sudo apt install ansible`) may result in a much older version of Ansible being installed.  
> 💡 Installing Ansible with Python packages will get you the latest.  
> 💡 If you have any problems installing Python or Ansible, see [Installing Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

```sh
pipenv install --python 3.10               # use Python 3.9 or later
pipenv install paramiko                    # ISE SSH/CLI access
pipenv install ansible                     # Ansible packages
pipenv install jmespath                    # JSON parser for Python
pipenv install ciscoisesdk                 # Python packages for Cisco ISE
pipenv install ansible[azure]              # Python packages for Azure 
pipenv install boto3 botocore              # Python packages for AWS 
pipenv install oci                         # Python packages for OCI
pipenv install pyvmomi                     # Python packages for VMware
pipenv shell                               # Launch the virtual environment
```

Download the Azure python library requirements doc and install the packages listed in the document:

```sh
wget -nv -q https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt
pipenv install -r requirements-azure.txt 
```

The `azure.storage.cloudstorageaccount` module is not included in the Ansible collection by default, so install it with this command:

```sh
pipenv install azure-storage==0.35.1 
```

## Minimum version of `ciscoisesdk`

If you already have Ansible installed and have been using it, you can see the version of the SDKs being used with the command `pip show <name_of_sdk>`.  If your ISE version is 3.1 Patch 1 or newer, you need at least version 2.0.10 of `ciscoisesdk`

```yaml
ISE Demo Lab:~/Upgrade_ISE_in_Hybrid_Cloud$ pip show ciscoisesdk
Name: ciscoisesdk
Version: 2.0.10
Summary: Cisco Identity Services Engine Platform SDK
Home-page: https://ciscoisesdk.readthedocs.io/en/latest/
Author: Jose Bogarin Solano
Author-email: jbogarin@altus.cr
License: MIT
Location: /home/charlie/Upgrade_ISE_in_Hybrid_Cloud/.venv/lib/python3.10/site-packages
Requires: fastjsonschema, future, requests, requests-toolbelt, xmltodict
Required-by:
```

If your version is older than 2.0.10, you can upgrade with the following command:

```sh
$ pip install ciscoisesdk --upgrade
```

## Requirements

### Create an AWS IAM user for API and create an Access key under that user:

[How do I create an AWS access key?](https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/)
This is a knowledge base article that contains links to the detailed steps needed.

### Create an Azure Service Principal using the Azure CLI:

Use this page to create the Azure service principal:
[Quickstart: Create an Azure service principal for Ansible](https://learn.microsoft.com/en-us/azure/developer/ansible/create-ansible-service-principal?tabs=azure-cli)

> ⚠ There is a typo in the **Assign a role to the Azure service principal** section.  
> 💡 The text reads **"Replace `<appID>` with the value provided from the output of `az ad sp create-for-rba` command."**
> 💡 It should read **"Replace `<appID>` with the value provided from the output of `az ad sp create-for-rbac` command."** which is the command from the first step.

### Create an API Signing Key and default config file for OCI:

[SDK and CLI Configuration File](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File)
[Required Keys and OCIDs](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm)

### Configure ESXi API for Ansible

[VMware Prerequisites](https://docs.ansible.com/ansible/latest/collections/community/vmware/docsite/vmware_scenarios/vmware_requirements.html)

### Install the VMware vSphere Automation SDK for Python for `community.vmware` collection modules

[VMware vSphere Automation SDK for Python](https://medium.com/@hegdeanusha25/getting-started-with-the-vmware-vsphere-automation-sdk-for-python-505b9c4b03c9)
If your virtual environment is already setup, just run the following command:

```sh
pip install — upgrade git+https://github.com/vmware/vsphere-automation-sdk-python.git
```

This is only needed for the dynamic inventory in this lab.

### The following Ansible collections are needed:

- azure.azcollection
- amazon.aws
- oracle.oci
- vmware.vmware_rest
- community.vmware
- cisco.ise
- cisco.ios
- ansible.netcommon

If you already have Ansible installed and have been using it, you can see the version of the collections with the command `ansible-galaxy collection list`.   If your ISE version is 3.1 Patch 1 or newer, you need at least version 2.5.15 of the `cisco.ise` collection.

The collections listed in this top section are those installed to be used:

```ini
ISE Demo Lab:~/Upgrade_ISE_in_Hybrid_Cloud$ ansible-galaxy collection list

# /home/charlie/.ansible/collections/ansible_collections
Collection                    Version
----------------------------- -------
amazon.aws                    6.3.0
ansible.netcommon             5.1.2
ansible.utils                 2.10.3
ansible.windows               2.0.0
azure.azcollection            1.16.0
cisco.ios                     5.0.0
cisco.ise                     2.5.15
cisco.meraki                  2.15.3
cloud.common                  2.1.4
community.aws                 6.2.0
community.azure               2.0.0
community.general             7.3.0
community.libvirt             1.2.0
community.vmware              3.9.0
oracle.oci                    4.29.0
vmware.vmware_rest            2.3.1
```

You can upgrade the collection with the following command:

```sh
ansible-galaxy collection install cisco.ise -U
```

## Environment Variables

Export your Azure and ISE credentials into your terminal environment:

```sh
export AZURE_CLIENT_ID=<service_principal_client_id>
export AZURE_SECRET=<service_principal_password>
export AZURE_SUBSCRIPTION_ID=<azure_subscription_id>
export AZURE_TENANT=<azure_tenant_id>

export AWS_REGION=<region>
export AWS_ACCESS_KEY=<access_key>
export AWS_SECRET_KEY=<secret_key>

export VCENTER=<hostname_or_ip_address>
export VCENTER_USERNAME=<vcenter_username>
export VCENTER_PASSWORD=<vcenter_password>
export VMWARE_HOST=<hostname_or_ip_address>
export VMWARE_USER=<esxi_username>
export VMWARE_PASSWORD=<esxi_password>

export ISE_USERNAME=iseadmin
export ISE_PASSWORD=<ise_password>
export ISE_VERIFY=False
export ISE_DEBUG=False
```

or you may edit and source these variables from a file in your `~/.secrets` directory.  I keep my credentials for each platform in a separate file, this way I can source only the credentials needed for the current project.  OCI doesn't require this since it sources the credentials from the default config file as detailed above.

```sh
source ~/.secrets/azure.sh
source ~/.secrets/aws.sh
source ~/.secrets/vmware.sh
source ~/.secrets/ise.sh
```

## Ansible Variables

Edit the project and deployment settings in `vars/main.yaml` to match your environment:

```yaml
project_name: Upgrade_ISE_in_Hybrid_Cloud
```

## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>