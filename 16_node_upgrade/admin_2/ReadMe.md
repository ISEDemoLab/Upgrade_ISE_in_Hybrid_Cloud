# Upgrade_ISE_in_Hybrid_Cloud/admin_2

This folder is the last to be run in the Upgrade process.  It contains all the Playbooks necessary to deregister the deployment from Cisco SSM servers, delete the `vmware-admin` node and create a new ISE 3.3 `vmware-admin`, register it to the deployment and promote it to the Primary Admin Node.  Also registers the ISE 3.3 deployment to Cisco SSM Servers.

|Playbook|Function|
|---|---|
|01-license_remove.yaml|Deregisters the ISE deployment from Cisco Smart Licensing|
|02-delete_admin.yaml|Delete the Primary Admin Node from VMware|
|03-setup-admin.yaml|Create a new VM and install ISE 3.3 using ZTP|
|04-add_vmware_admin.yaml|Registers `vmware-admin`  to the ISE 3.3 deployment as the Secondary Admin Node|
|05-enable-api.yaml|Enables the API Gateway on `vmware-admin` |
|06-promote_to_primary.yaml|Promotes vmware-admin to the Primary Admin Node|
|07-certificates.yaml|Installs the Admin certificate onto the PPAN|
|08-license_cssm.yaml|Registers the new ISE 3.3 deployment to Cisco Smart Licensing|
|09-upgrade_complete.yaml|Visual and email notification that the Upgrade process is complete|
|primary_admin.yaml|Uses `ansible.builtin.import_playbook` to run all the necessary Playbooks|

Upgrading ISE using Backup and Restore will result in the original Secondary Policy Admin Node (SPAN) in the role of the Primary Policy Admin Node (PPAN) for the upgraded deployment.  To overcome this, `06-promote_to_primary.yaml` is used to restore the roles to their original configurations.

This folder of Playbooks will deregister the 3.2Patch3 deployment from Cisco Smart Licensing, destroy the remaining Admin Node and install a new 3.3 Admin Node.  It will be added to the 3.3 deployment, promoted to the Primary Admin Node, certificates will be installed and the 3.3 deployment will be registered to the Cisco Smart Licensing Server.

```mermaid
flowchart LR
    subgraph 3.3
      direction TB
      subgraph Admin Nodes2[Admin Nodes]
        direction LR
        vmware-admin ~~~ vmware-sadmin
      end
      subgraph PSNs2[PSNs]
        direction LR
        subgraph WestUS2[WestUS]
          direction TB
          azure-psn ~~~ azure-psn2
        end
        subgraph EastUS2[EastUS]
          direction TB
          aws-psn ~~~ aws-psn2
        end
        subgraph CentralUS2[CentralUS]
          direction TB
          oci-psn ~~~ oci-psn2
        end
      end
    end
    vmware-admin & vmware-sadmin --> aws-psn & aws-psn2 & azure-psn & azure-psn2 & oci-psn & oci-psn2
```

## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>
