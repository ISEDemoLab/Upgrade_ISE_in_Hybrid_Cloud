# Upgrade_ISE_in_Hybrid_Cloud/ztp

To use Zero Touch Provisioning (ZTP) with VMware, you need to have an understanding of this article:  [ISE Zero Touch Provisioning (ZTP)](https://community.cisco.com/t5/security-knowledge-base/ise-zero-touch-provisioning-ztp/ta-p/4541606)

The files used are 
|File Name|Function|
|--|---|
|create_ztp_image.sh|Shell script used to create the ZTP settings `.iso` file from the `.conf` files|
|vmware-admin.conf<br>vmware-sadmin.conf|Configuration parameters for the ZTP `.iso` file|
|vmware-admin.iso<br>vmware-sadmin.iso|.iso file created using `create_ztp_image.sh` and a `.conf` file|

Using a ZTP `.iso` file to pass along the configuration settings to the `setup` script when installing ISE is the most efficient installation method.  This is due to the fact that once the installation is started, there is no need for further input from you.

This is an example of the ZTP settings that I pass along to my ISE installations.
```
hostname=vmware-admin
ipv4_addr=10.1.100.40
ipv4_mask=255.255.255.0
ipv4_default_gw=10.1.100.1
domain=securitydemo.net
primary_nameserver=10.1.100.10
#secondary and tertiary are optional
secondary_nameserver=8.8.8.8
primary_ntpserver=10.1.100.1
timezone=America/New_York
ssh=true
username=iseadmin
password=ISEisC00LISE
#Public Key Authentication configuration is optional
public_key=ssh-rsa public_key_contents
ers=true
openapi=true
pxgrid=true
pxGrid_Cloud=true
#Skipping specific checks
SkipIcmpChecks=true
SkipDnsChecks=true
SkipNtpChecks=true
```

Yes, I know that i can also install a Patch from the ZTP settings when setting up my initial 3.2 deployment (in the `setup/` folder).  This option is not available in Cloud-based instances, which means I need a separate TASK to accomplish this for those nodes.  Instead od adding time to the installation for the VMware nodes, I install all the patches at once, which decreases the total time to initialize the deployment.


## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>