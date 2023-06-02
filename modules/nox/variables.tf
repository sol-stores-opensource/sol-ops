variable "name" {}
variable "k8s_namespace" {}
variable "project_id" {}
variable "db_connection_name" {}
variable "app_env" {}
variable "gke_cluster_name" {}
variable "region" {}
variable "ssl_domains" {
  type = list(string)
}
variable "uploads_bucket_location" {}
variable "uploads_bucket_name" {}
variable "replicas" {}
variable "PORT" {}
variable "container_env" {}
variable "cpu" {}
variable "memory" {}
