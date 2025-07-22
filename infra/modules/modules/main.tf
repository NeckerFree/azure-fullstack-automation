# resource "tls_private_key" "vm_ssh" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "local_file" "ssh_private_key" {
#   content         = tls_private_key.vm_ssh.private_key_openssh
#   filename        = pathexpand("~/.ssh/vm_ssh_key")
#   file_permission = "0600"
# }

# output "public_key" {
#   value = tls_private_key.vm_ssh.public_key_openssh
# }
