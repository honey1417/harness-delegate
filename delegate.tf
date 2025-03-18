#Fetching Google Cloud Authentication Details
#this data source retrieves authentication details from the Google Cloud provider.
#It provides credentials (like the access token) to authenticate with GKE.

data "google_client_config" "default" {}

# Fetch GKE Cluster Details

data "google_container_cluster" "gke_cluster" {
  name     = var.GKE_CLUSTER
  location = var.GKE_REGION # Change as per your cluster
  depends_on = [google_container_cluster.primary]
}

# Kubernetes Provider using GKE authentication
#This block configures the Kubernetes provider to interact with the GKE cluster.
#Kubernetes provider allows Terraform to manage resources inside GKE, such as Deployments, Services, and Ingress.

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"  #Sets the Kubernetes API server endpoint 
  token                  = data.google_client_config.default.access_token     #Uses the Google Cloud access token to authenticate.
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)  #GKE uses TLS certificates for secure communication.
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