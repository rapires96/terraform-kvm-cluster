#--- 

locals {
  host_list = toset([ "1", "2", "3" ])
}

#--- GET ISO IMAGE

# Fetch the ubuntu image
resource "libvirt_volume" "os_image" {
  for_each = local.host_list
  name = "${var.hostname}-${each.key}-os_image"
  pool = "homelab"
  source = "${path.module}/local/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}

#--- CUSTOMIZE ISO IMAGE

# 1a. Retrieve our local cloud_init.cfg and update its content (= add ssh-key) using variables
data "template_file" "user_data" {
  template = file("${path.module}/assets/cloud_init.cfg")
  for_each = local.host_list
  vars = {
    hostname = var.hostname
    fqdn = "${var.hostname}-${each.key}.${var.domain}"
    public_key = file("${path.module}/.ssh/id_homelab.pub")
  }
}

# 1b. Save the result as init.cfg
data "template_cloudinit_config" "config" {
  gzip = false
  for_each = local.host_list
  base64_encode = false
  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    # content = "${data.template_file.user_data.rendered}"
    content = data.template_file.user_data[each.key].rendered
  }
}

# 2. Retrieve our network_config
data "template_file" "network_config" {
  template = file("${path.module}/assets/network_config_${var.ip_type}.cfg")
}

# 3. Add ssh-key and network config to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = local.host_list
  name = "${var.hostname}-${each.key}-commoninit.iso"
  pool = "homelab"
  user_data      = data.template_cloudinit_config.config[each.key].rendered
  network_config = data.template_file.network_config.rendered
}

#--- CREATE VM

resource "libvirt_domain" "domain-ubuntu" {
  for_each = local.host_list
  name = "${var.hostname}-${each.key}"
  memory = var.memoryMB
  vcpu = var.cpu

  disk {
    volume_id = libvirt_volume.os_image[each.key].id
  }
  network_interface {
    network_name = "default"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }
}
