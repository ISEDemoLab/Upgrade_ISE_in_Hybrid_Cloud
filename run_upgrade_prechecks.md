# Upgrade_ISE_in_Hybrid_Cloud/run_upgrade_prechecks.md

This is a **BIG** topic, but this ReadMe will contain a detailed explanation of the use of the following APIs:

- `POST` request for `https://{{ upg_ppan }}/api/v1/upgrade/prepare/pre-checks`
- `GET` request for `https://{{ upg_ppan }}/api/v1/upgrade/prepare/get-status`

The documentation at https://cs.co/ise-api/#!upgrade-openapi shows the information in the body of the `POST` request to be

```json
{
  "bundleName": "ise-upgradebundle-2.6.x-3.0.x-to-3.1.0.486.NOT_FOR_RELEASE.x86_64.tar.gz",
  "hostnames": [
    "string"
  ],
  "patchBundleName": "ise-patchbundle-2.6.0.156-Patch1-20061206.SPA.x86_64.tar.gz",
  "preCheckReportID": "50bc7f99-057a-4d9f-aec4-20b7d4b89846",
  "preChecks": [
    "string"
  ],
  "reTrigger": false,
  "repoName": "repo_name",
  "upgradeType": "FULL_UPGRADE or SPLIT_UPGRADE"
}
```

Let's break this down a bit:
|Attribute|Expected Value|
|---|---|
|"bundleName"|Simple, this is name name of the `ise-upgradebundle`|
|"hostnames"|Used if choosing `SPLIT_UPGRADE`. If using `FULL_UPGRADE` the value is `[]`|
|"patchBundleName"|Easy, this is the `ise-patchbundle` name. Just like through the GUI, you can install a patch during the upgrade process|
|"preCheckReportID"|This is to be used in conjunction with the `reTrigger` attribute|
|"preChecks"|This is the list of `preChecks` that you want to run. Unless you are setting `reTrigger` to `true`, this value should simply be `[]`|
|"reTrigger"|To recheck specific `preChecks`, set this to `true`, enter the `preCheckReportID` attribute value, and list the `preChecks` to run again|
|"repoName"|The repository that contains the `ise-upgradebundle` and (if applicable) the `ise-patchbundle`|
|"upgradeType"|Choose `FULL_UPGRADE` or `SPLIT_UPGRADE`|

## Initiating the `preChecks`

When sending the API requests, they are sent to the Primary PAN.

### `POST` request for `https://{{ upg_ppan }}/api/v1/upgrade/prepare/pre-checks`

If you are running an initial Upgrade PreCheck for a Full Upgrade, the data would be

```json
{
  "bundleName": "ise-upgradebundle-3.0.x-3.2.x-to-3.3.0.430.SPA.x86_64.tar.gz",
  "hostnames": [],
  "patchBundleName": "",
  "preCheckReportID": "",
  "preChecks": [],
  "reTrigger": false,
  "repoName": "FTP",
  "upgradeType": "FULL_UPGRADE"
}
```

While the initial Split Upgrade data would be

```json
{
  "bundleName": "ise-upgradebundle-3.0.x-3.2.x-to-3.3.0.430.SPA.x86_64.tar.gz",
  "hostnames": [
     vmware-sadmin.securitydemo.net,
     aws-psn.securitydemo.net,
     azure-psn.securitydemo.net
  ],
  "patchBundleName": "",
  "preCheckReportID": "",
  "preChecks": [],
  "reTrigger": false,
  "repoName": "FTP",
  "upgradeType": "SPLIT_UPGRADE"
}
```

Notice that the only difference is that the hostnames for the nodes to check in this iteration are listed.  What I found, though, is that `hostnames` in this case actually means "FQDN of the host you would like to check". Since I am ultimately performing a Backup and Restore upgrade, all I want to check is my Secondary PAN `vmware-sadmin.securitydemo.net`.

Whether it's the `hostnames` attribute or the `preChecks`, the value of `[]` is None.  In this API if no `hostnames` or `preChecks` are specified the default would be ALL.  In these instances it would be ALL `hostnames` or ALL `preChecks`.

The response  to this API should be similar to

```json
{
  "response": {
    "preCheckReportID": "fa422157-df80-480c-b9d1-548313f57526",
    "message": "SPLIT_UPGRADE preChecks inprogress"
  },
  "version": "1.0.0"
}
```

This is where you can record the ReportID

## Review the PreCheck Report

### `GET` request for `https://{{ upg_ppan }}/api/v1/upgrade/prepare/get-status`

The data sent to retrieve the PreCheck Report is

```sh
          {
            "preCheckReportID: "fa422157-df80-480c-b9d1-548313f57526"
          }
```

This is also sent to the Primary PAN.  The response is _LONG_! review the responses and look for any failures.  If you identify a failure and want to re-run that specific `preCheck`, then you would `reTrigger` those checks

## `reTrigger` Upgrade PreChecks

To `reTrigger`, send a `POST` request for `https://{{ upg_ppan }}/api/v1/upgrade/prepare/pre-checks` specifying the `preChecks` you want to recheck

```json
          {
            "bundleName": "{{ upgrade_bundle }}",
            "hostnames": [
               vmware-sadmin.securitydemo.net,
               aws-psn.securitydemo.net,
               azure-psn.securitydemo.net
            ],
            "preCheckReportID": "fa422157-df80-480c-b9d1-548313f57526",
            "patchBundleName": "",
            "preChecks": [
              "REPOSITORY_CHECK",
              "DNS_CHECK",
              "PLATFORM_CHECK",
              "DB_UPGRADE_CHECK"
            ],
            "reTrigger": true,
            "repoName": "FTP",
            "upgradeType": "SPLIT_UPGRADE"
          }
```

You can see that this time, `reTrigger` has been changed to `true`, the `preCheckReportID` has been populated, and the `preChecks` I want to re-run are listed.

The names of all the `preChecks` are

```sh
    "REPOSITORY_CHECK",
    "MEMORY_CHECK",
    "DISK_CORRUPTION_CHECK",
    "PLATFORM_CHECK",
    "DNS_CHECK",
    "SYSTEM_CERT_CHECK",
    "DISK_SPACE_CHECK",
    "NTP_CHECK",
    "LOAD_AVERAGE_CHECK",
    "SERVICES_CHECK",
    "DEPLOYMENT_CHECK",
    "BUNDLE_DOWNLOAD_CHECK",
    "PAN_FAILOVER_CHECK",
    "SCHEDULE_BACKUP_CHECK",
    "CONFIG_BACKUP_CHECK",
    "DB_UPGRADE_CHECK",
    "ADMIN_CERT_CHECK",
    "TRUST_CERT_CHECK",
    "MDM_CHECK",
```

## Upgrade Readiness Tool (URT)

I hear what you're screaming at the screen, "Why not just run the Upgrade Readiness Tool (URT)?" Of course, that thought crossed my mind, but it turns out that no matter how you run it through Ansible, it times out.  No only that, there is no mechanism to retrieve the results from the URT.

## License

MIT

## Author

Charlie Moreton, <https://github.com/ISEDemoLab>