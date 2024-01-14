# module. In this case, it returns the path to the directory containing the current module.

output "kubeconfig" {
  value       = "cluster.kubeconfig"
  description = "The path to the kubeconfig file"
}