resource "null_resource" "local_kubectl_setup" {
  triggers = {
    cluster_endpoint = module.eks.cluster_endpoint
  }
  provisioner "local-exec" {
    command = <<-EOT
      # Check if kubectl is installed
      if ! command -v kubectl &> /dev/null
      then
          echo "kubectl not found. Installing..."
          sudo apt-get update && sudo apt-get install -y curl
          curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
          echo "kubectl installed successfully."
      else
          echo "kubectl is already installed."
      fi
    EOT
  }
}

resource "local_file" "kubeconfig" {
  content    = module.eks.kubeconfig
  filename   = "/root/.kube/config" # Explicitly write to root's kubeconfig
  depends_on = [null_resource.local_kubectl_setup]
}