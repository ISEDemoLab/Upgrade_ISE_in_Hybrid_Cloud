# Upgrade_ISE_in_Hybrid_Cloud/templates
This folder contains _sanitized_ JSON templates for the following Azure Resource Manager deployments used in this lab:

|Template Name|Parameters File|Function|
|---|---|---|
|ise32-azuredeploy.json|azure-psn32-azuredeploy.parameters.json<br>azure-psn232-azuredeploy.parameters.json|Deploy ISE 3.2 from the Marketplace with a nic and private ip|
|ise32-azuredeploy.json|ise33-1-azuredeploy.parameters.json<br>ise33-2-azuredeploy.parameters.json|Deploy ISE 3.3 from the Marketplace with a nic and private ip|

The template files are just as they would be downloaded from Azure, the parameters files will need to be updated with your information.  **I have removed the subscription id, ssh key, and user data entries from all parameters files**.

These templates are used due to the fact that 
>  |⚠| There is no Ansible module that allows for the **User Data** to be collected and used for the ISE deployment, which is *required*|
>  |:---:|---|

While I am grateful that Azure allows for the templates as a workaround to these shortcomings, I would hope that they add modules to their collection that address them.  The templates add a LOT of unnecessary steps to the process.



## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>