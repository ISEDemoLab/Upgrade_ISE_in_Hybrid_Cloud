# Upgrade_ISE_in_Hybrid_Cloud/admin_1

This folder is the first to be run in the Upgrade process.  It contains all the Playbooks necessary to deregister the SPAN from the ISE 3.2 deployment and set it up as the basis for the ISE 3.3 upgraded deployment

|Playbook|Function|
|---|---|
|~~01-run_prechecks.yaml~~|~~Run the Upgrade PreChecks as you would through the GUI-based Split Upgrade Flow~~|
|02-remove_sadmin.yaml|Deregister the Secondary Admin Node from the ISE 3.2 depoyment|
|03-delete_sadmin.yaml|Delete the Secondary Admin Node from VMware|
|04-setup-sadmin.yaml|Create a new VM and install ISE 3.3 using ZTP|
|05-enable-api.yaml|Enable ERS API and Open API on the new node|
|06-create_ftp_respository.yaml|Creates a repository named `FTP` on the new node|
|07-backup_and_restore.yaml|Creates a Configuration Backup from the ISE 3.2 Deployment and uses that backup to restore the configuration to the new ISE 3.3 node|
|secondary_admin.yaml|Uses `ansible.builtin.import_playbook` to run all the necessary Playbooks |

You'll notice the ~~01-run_prechecks.yaml~~ entry in the table above.  The goal was to run prechecks prior to upgrading to 3.3.  There's even an API for this!  However, the `preCheckReportID` field is **MANDATORY** and there is no way to get this dynamically created ID until the PreCheck has begun...wait.  *WHAT?* 

That's right.  The only way to get this ID is to start the precheck, but the API requires this field to start the precheck.  There is currently NO POSSIBLE WAY to run these PreChecks outside of the GUI.

```
    - name: Run Upgrade pre-Checks on {{ upg_ppan }}
      delegate_to: localhost
      ansible.builtin.uri:
        url: "https://{{ upg_ppan }}/api/v1/upgrade/prepare/pre-checks"
        method: POST
        url_username: "{{ ise_username }}"
        url_password: "{{ ise_password }}"
        force_basic_auth: yes
        body: |
          {
            "bundleName": "{{ upgrade_bundle }}",
            "hostnames": [
              "vmware-sadmin"
            ],
            "preCheckReportID": "",
            "preChecks": [
              "REPOSITORY_CHECK",
              "MEMORY_CHECK",
              "DISK_CORRUPTION_CHECK",
              "DNS_CHECK",
              "SYSTEM_CERT_CHECK",
              "DISK_SPACE_CHECK",
              "NTP_CHECK",
              "LOAD_AVERAGE_CHECK",
              "SERVICES_CHECK",
              "DEPLOYMENT_CHECK",
              "PAN_FAILOVER_CHECK",
              "SCHEDULE_BACKUP_CHECK",
              "ADMIN_CERT_CHECK",
              "TRUST_CERT_CHECK",
              "MDM_CHECK"
            ],
            "reTrigger": false,
            "repoName": "{{ ise_repository_name }}",
            "upgradeType": "SPLIT_UPGRADE"
          }
        status_code: [
                      200,  # OK
                      202,  # Prechecks initiated successfully
                      400,  # Invalid input. Please provide valid inputs
                      500,  # Internal server error
                      ]
        body_format: json
        validate_certs: "{{ ise_verify }}"
        return_content: true
        timeout: 600 # in seconds (10 minutes)
      register: response
```

I hear what you're screaming at the screen, "Why not just run the Upgrade Readiness Tool (URT)?" Of course, that thought crossed my mind, but it turns out that no matter how you run it through Ansible, it times out.


## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>