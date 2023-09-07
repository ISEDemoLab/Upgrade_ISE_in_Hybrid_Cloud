#!/usr/bin/bash


params() {
mods=(
    "amazon.aws"
    "ansible.netcommon"
    "ansible.utils"
    "ansible.windows"
    "azure.azcollection"
    "cisco.asa"
    "cisco.dnac"
    "cisco.ios"
    "cisco.ise"
    "cisco.meraki"
    "cloud.common"
    "community.aws"
    "community.azure"
    "community.general"
    "community.libvirt"
    "community.vmware"
    "oracle.oci"
    "vmware.vmware_rest"
)
}
module_update() {
params;
pushd "${ansdir}"
for element in "${mods[@]}"; do
    ansible-galaxy collection install -U "${element}"
done
popd
}
main() {
module_update;
}
main
