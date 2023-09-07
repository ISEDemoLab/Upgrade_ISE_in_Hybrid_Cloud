# Upgrade_ISE_in_Hybrid_Cloud/password_reset

In this folder, there are 2 subfolders
|Folder|Function|
|---|---|
|noprompt|Will update the password on the ISE node(s) with a preconfigured password|
|prompt|Will pause and wait for you to enter the password for the node(s)|

This is pretty self-explanatory.  Though if you want to create a playbook to change ALL the passwords at once, take a look at the `../setup/create.yaml` file on how to use the `ansible.builtin.import_playbook` module.




## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>