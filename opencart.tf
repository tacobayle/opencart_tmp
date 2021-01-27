resource "vsphere_tag" "ansible_group_opencart" {
  name             = "opencart_tmp"
  category_id      = vsphere_tag_category.ansible_group_opencart_tmp.id
}

data "template_file" "opencart_userdata" {
  count = length(var.opencart.ipsData)
  template = file("${path.module}/userdata/opencart.userdata")
  vars = {
    username     = var.opencart.username
    pubkey       = file(var.jump["public_key_path"])
    ipData      = element(var.opencart.ipsData, count.index)
    opencartDownloadUrl = var.opencart["opencartDownloadUrl"]
    netplanFile  = var.opencart.netplanFile
    maskData = var.opencart.maskData
  }
}

data "vsphere_virtual_machine" "opencart" {
  name          = var.opencart["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "opencart" {
  count = length(var.opencart.ipsData)
  name             = "opencart-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path

  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  network_interface {
                      network_id = data.vsphere_network.networkBackendOpencart.id
  }


  num_cpus = var.opencart["cpu"]
  memory = var.opencart["memory"]
  wait_for_guest_net_timeout = var.opencart["wait_for_guest_net_timeout"]
  #wait_for_guest_net_routable = var.opencart["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.opencart.guest_id
  scsi_type = data.vsphere_virtual_machine.opencart.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.opencart.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.opencart.scsi_controller_scan_count

  disk {
    size             = var.opencart["disk"]
    label            = "opencart-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.opencart.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.opencart.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.opencart.id
  }

  tags = [
        vsphere_tag.ansible_group_opencart.id,
  ]

  vapp {
    properties = {
     hostname    = "opencart-${count.index}"
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.opencart_userdata[count.index].rendered)
   }
 }

  connection {
    host        = self.default_ip_address
    type        = "ssh"
    agent       = false
    user        = var.opencart.username
    private_key = file(var.jump["private_key_path"])
    }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }
}
