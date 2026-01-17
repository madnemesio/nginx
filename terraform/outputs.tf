output "wif_provider_name" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}

output "github_actions_sa_email" {
  value = google_service_account.github_actions.email
}

output "artifact_registry_repo" {
  value = google_artifact_registry_repository.my_repo.name
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}
