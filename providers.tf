provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

provider "kubernetes" {
  host                   = module.eks_cluster.endpoint
  token                  = module.eks_cluster.token
  cluster_ca_certificate = base64decode(module.eks_cluster.kubeconfig_certificat_authority_data)
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.endpoint
    token                  = module.eks_cluster.token
    cluster_ca_certificate = base64decode(module.eks_cluster.kubeconfig_certificat_authority_data)
  }
}