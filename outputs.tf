
#output "vm_ips" {
#  for_each = local.host_list
#  value = libvirt_domain.domain-ubuntu.network_interface[each.key].0.addresses
#  description = "IP addresses of the created VMs"
#}
