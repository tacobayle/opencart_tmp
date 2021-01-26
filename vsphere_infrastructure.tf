data "vsphere_datacenter" "dc" {
  name = var.vcenter.dc
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vcenter.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name = var.vcenter.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vcenter.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkMgt" {
  name = var.vcenter.networkMgmt
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkMaster" {
  name = var.master.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkWorker" {
  name = var.worker.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkBackendVmw" {
  name = var.backend_vmw["network"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkBackendLsc" {
  name = var.backend_lsc["network"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkBackendMysql" {
  name = var.mysql.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkBackendOpencart" {
  name = var.opencart.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkClient" {
  name = var.client["network"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networksLsc" {
  count = length(var.lsc.serviceEngineGroup.networks)
  name = element(var.lsc.serviceEngineGroup.networks, count.index).name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folder" {
  path          = var.vcenter.folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folderSe" {
  path          = var.lsc.serviceEngineGroup.folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_tag_category" "ansible_group_backend_lsc" {
  name = "ansible_group_backend_lsc"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_backend_vmw" {
  name = "ansible_group_backend_vmw"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_client" {
  name = "ansible_group_client"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_controller" {
  name = "ansible_group_controller"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_jump" {
  name = "ansible_group_jump"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_mysql" {
  name = "ansible_group_mysql"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_opencart" {
  name = "ansible_group_opencart"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_se" {
  name = "ansible_group_se"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_master" {
  name = "ansible_group_master"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_worker" {
  name = "ansible_group_worker"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}