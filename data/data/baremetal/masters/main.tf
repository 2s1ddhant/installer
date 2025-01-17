provider "ironic" {
  url                = var.ironic_uri
  inspector          = var.inspector_uri
  microversion       = "1.69"
  timeout            = 3600
  auth_strategy      = "http_basic"
  ironic_username    = var.ironic_username
  ironic_password    = var.ironic_password
  inspector_username = var.ironic_username
  inspector_password = var.ironic_password
}

resource "ironic_node_v1" "openshift-master-host" {
  count          = var.master_count
  name           = var.masters[count.index]["name"]
  resource_class = "baremetal"

  inspect   = true
  clean     = true
  available = true

  ports = [
    {
      address     = var.masters[count.index]["port_address"]
      pxe_enabled = "true"
    },
  ]

  properties  = var.properties[count.index]
  root_device = var.root_devices[count.index]

  driver      = var.masters[count.index]["driver"]
  driver_info = var.driver_infos[count.index]

  boot_interface       = var.masters[count.index]["boot_interface"]
  management_interface = var.masters[count.index]["management_interface"]
  power_interface      = var.masters[count.index]["power_interface"]
  raid_interface       = var.masters[count.index]["raid_interface"]
  vendor_interface     = var.masters[count.index]["vendor_interface"]
  deploy_interface     = var.masters[count.index]["deploy_interface"]
}

resource "ironic_deployment" "openshift-master-deployment" {
  count = var.master_count
  node_uuid = element(
    ironic_node_v1.openshift-master-host.*.id,
    count.index,
  )

  instance_info = var.instance_infos[count.index]
  user_data     = var.ignition_master
  deploy_steps  = var.deploy_steps[count.index]
}

data "ironic_introspection" "openshift-master-introspection" {
  count = var.master_count

  uuid = element(
    ironic_node_v1.openshift-master-host.*.id,
    count.index,
  )
}
