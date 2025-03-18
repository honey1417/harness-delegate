# Fetch GKE Cluster Details
data "google_client_config" "default" {}

data "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  location = var.region # Change as per your cluster
  depends_on = [google_container_cluster.primary]
}

# Kubernetes Provider using GKE authentication
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
}

# Helm Provider using GKE authentication
#Helm provider needs access to the Kubernetes cluster to install Helm charts
#Helm provider lets Terraform deploy applications on GKE using Helm charts.

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
  }
}

module "delegate" {
  source = "harness/harness-delegate/kubernetes"
  version = "0.1.8"

  account_id = "ucHySz2jQKKWQweZdXyCog"
  delegate_token = "NTRhYTY0Mjg3NThkNjBiNjMzNzhjOGQyNjEwOTQyZjY="
  delegate_name = "terraform-delegate-h"
  deploy_mode = "KUBERNETES"
  namespace = "harness-delegate-ng"
  manager_endpoint = "https://app.harness.io"
  delegate_image = "harness/delegate:25.02.85300"
  replicas = 1
  upgrader_enabled = true
  depends_on = [google_container_cluster.primary]
}

