# Export Terraform output variable values to a stack yaml file 
# that can be consumed by zenml stack import
resource "local_file" "stack_file" {
  content  = <<-ADD
    # Stack configuration YAML
    # Generated by the GCP Kubeflow MLOps stack recipe.
    zenml_version: ${var.zenml-version}
    stack_name: gcp_kubeflow_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}
    components:
      artifact_store:
        flavor: gcp
        name: gcs_artifact_store
        path: gs://${google_storage_bucket.artifact-store.name}
      container_registry:
        flavor: gcp
        name: gcr_container_registry
        uri: ${local.container_registry.region}.gcr.io/${local.project_id}
      metadata_store:
        database: zenml_db
        flavor: mysql
        host: ${module.metadata_store.instance_first_ip_address}
        name: cloudsql_metadata_store
        port: 3306
        secret: gcp_mysql_secret
        upgrade_migration_enabled: true
      orchestrator:
        flavor: kubeflow
        name: gke_kubeflow_orchestrator
        synchronous: True
        kubernetes_context: gke_${local.project_id}_${local.region}_${module.gke.name}
      secrets_manager:
        flavor: gcp_secrets_manager
        name: gcp_secrets_manager
        project_id: ${local.project_id}
      experiment_tracker:
        flavor: mlflow
        name: gke_mlflow_experiment_tracker
        tracking_uri: http://${data.kubernetes_service.mlflow_tracking.status.0.load_balancer.0.ingress.0.ip}
        tracking_username: ${var.mlflow-username}
        tracking_password: ${var.mlflow-password}
      model_deployer:
        flavor: kserve
        name: gke_kserve
        kubernetes_context: gke_${local.project_id}_${local.region}_${module.gke.name}
        kubernetes_namespace: ${local.kserve.workloads_namespace}
        base_url: http://${data.kubernetes_service.kserve_ingress.status.0.load_balancer.0.ingress.0.ip}:${data.kubernetes_service.kserve_ingress.spec.0.port.1.port}
        secret: gcp_kserve_secret
      step_operator:
        flavor: vertex
        project: ${local.project_id}
        region: ${local.region}
    ADD
  filename = "./gcp_kubeflow_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}.yml"
}