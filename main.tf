resource "google_container_cluster" "primary" {
    name = var.GKE_CLUSTER 
    location = var.GKE_REGION
    deletion_protection = false
    remove_default_node_pool = true 
    initial_node_count = var.NODE_COUNT
    node_config {
        machine_type = var.MACHINE_TYPE 
        disk_size_gb = 50
        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
    
}

