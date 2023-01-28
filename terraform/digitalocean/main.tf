/**
 * # DigitalOcean Project
 */
resource "digitalocean_project" "francrordriguezcom-mon" {
  name        = "francrodriguezcom-mon"
  description = "Infra para monitor.francrodriguez.com"
  purpose     = "monitoring"
  environment = "production"
  resources   = digitalocean_droplet.node.*.urn
}

/**
* # key a usar
*/

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}

/**
 * Create one or more droplets
 */

resource "digitalocean_droplet" "node" {
  count    = var.node_count
  image    = "docker-20-04"
  name     = "node${count.index}"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  vpc_uuid = "71bbce96-523f-4db9-b06e-f5fff6939df7"
  ssh_keys = [data.digitalocean_ssh_key.one.id]


  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install -y python3"]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = var.priv_key
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key var.priv_key -e 'pub_key=var.pub_key' ansible/deploy-monitor.yml"

}
  output "nodes_ip" {
    value = digitalocean_droplet.node.0.ipv4_address
  }
}

/**
* Update DNS Records
*/

# Add an A record to the domain.
resource "digitalocean_record" "www" {
  domain = "francrodriguez.com"
  type   = "A"
  name   = "monitor"
  value  = digitalocean_droplet.node.0.ipv4_address
}
