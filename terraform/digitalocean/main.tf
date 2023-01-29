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

data "digitalocean_ssh_key" "one" {
  name = "one"
}

/**
 * Create one or more droplets
 */

resource "digitalocean_droplet" "node" {
  image    = "docker-20-04"
  name     = "monitor"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  vpc_uuid = "71bbce96-523f-4db9-b06e-f5fff6939df7"
  ssh_keys = [data.digitalocean_ssh_key.one.id]

}

/**
* Update DNS Records
*/

# Add an A record to the domain.
resource "digitalocean_record" "www" {
  domain = "francrodriguez.com"
  type   = "A"
  name   = "monitor"
  value  = digitalocean_droplet.node.monitor.ipv4_address
}
