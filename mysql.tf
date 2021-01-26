
resource "vsphere_tag" "ansible_group_mysql" {
  name             = "mysql_tmp"
  category_id      = vsphere_tag_category.ansible_group_mysql_tmp.id
}

data "template_file" "mysql_userdata" {
  count = length(var.mysql.ipsData)
  template = file("${path.module}/userdata/mysql.userdata")
  vars = {
    username     = var.mysql.username
    pubkey       = file(var.jump["public_key_path"])
    netplanFile  = var.mysql.netplanFile
    ipData = element(var.mysql.ipsData, count.index)
    maskData = var.mysql.maskData
  }
}

data "vsphere_virtual_machine" "mysql" {
  name          = var.mysql["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "mysql" {
  count = length(var.mysql.ipsData)
  name             = "mysql-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path

  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  network_interface {
                      network_id = data.vsphere_network.networkBackendMysql.id
  }

  num_cpus = var.mysql["cpu"]
  memory = var.mysql["memory"]
  wait_for_guest_net_timeout = var.mysql["wait_for_guest_net_timeout"]
  #wait_for_guest_net_routable = var.mysql["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.mysql.guest_id
  scsi_type = data.vsphere_virtual_machine.mysql.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.mysql.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.mysql.scsi_controller_scan_count

  disk {
    size             = var.mysql["disk"]
    label            = "mysql-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.mysql.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.mysql.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.mysql.id
  }

  tags = [
        vsphere_tag.ansible_group_mysql.id,
  ]


  vapp {
    properties = {
     hostname    = "mysql-${count.index}"
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.mysql_userdata[count.index].rendered)
   }
 }

  connection {
    host        = self.default_ip_address
    type        = "ssh"
    agent       = false
    user        = var.mysql.username
    private_key = file(var.jump["private_key_path"])
    }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }
}
