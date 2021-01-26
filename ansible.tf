resource "null_resource" "foo7" {
  depends_on = [vsphere_virtual_machine.jump]
  connection {
    host = vsphere_virtual_machine.jump.default_ip_address
    type = "ssh"
    agent = false
    user = var.jump.username
    private_key = file(var.jump.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/${basename(var.jump.private_key_path)}",
      "cd ~/ansible ; git clone ${var.ansible.opencartInstallUrl} --branch ${var.ansible.opencartInstallTag} ; cd ${split("/", var.ansible.opencartInstallUrl)[4]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml local.yml --extra-vars '{\"mysql_db_hostname\": ${jsonencode(vsphere_virtual_machine.mysql[0].default_ip_address)}, \"domainName\": ${jsonencode(var.vmw.domains[0].name)}}'",
    ]
  }
}