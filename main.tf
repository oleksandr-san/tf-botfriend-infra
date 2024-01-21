module "cluster" {
  source         = "github.com/oleksandr-san/tf-google-gke-cluster"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
  GKE_MACHINE_TYPE = var.GKE_MACHINE_TYPE
  GKE_CLUSTER_NAME = var.GKE_CLUSTER_NAME
  GKE_POOL_NAME = var.GKE_POOL_NAME
}

# module "cluster" {
#   source = "github.com/oleksandr-san/tf-kind-cluster"
# }

module "flux_bootstrap" {
  source            = "github.com/oleksandr-san/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${module.github_repository.repository_name}"
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.cluster.kubeconfig
  github_token      = var.GITHUB_TOKEN
}

module "github_repository" {
  source                   = "github.com/oleksandr-san/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux"
}

module "tls_private_key" {
  source = "github.com/oleksandr-san/tf-hashicorp-tls-keys"
}

module "gke-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "kustomize-controller"
  namespace           = "flux-system"
  project_id          = var.GOOGLE_PROJECT
  location            = var.GOOGLE_REGION
  cluster_name        = "main"
  use_existing_k8s_sa = true
  annotate_k8s_sa     = true
  roles               = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
}

module "kms" {
  source  = "github.com/den-vasyliev/terraform-google-kms"

  project_id         = var.GOOGLE_PROJECT
  location           = "global"
  keyring            = "sops-flux"
  keys               = ["sops-key-flux"]
  prevent_destroy    = false
}
