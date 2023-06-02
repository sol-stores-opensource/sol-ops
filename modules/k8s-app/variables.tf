variable "name" {}
variable "project_id" {}
variable "gke_cluster_name" {}
variable "region" {}
variable "github_owner" {}
variable "github_name" {}
variable "github_deploy_branch" {}
variable "service_account_roles" {
  type = list(string)
}
variable "container_env" {}
variable "ssl_domains" {
  type = list(string)
}
variable "PORT" {}
variable "cpu" {}
variable "memory" {}
variable "replicas" {}

variable "health_startup_path" {
  default = "/healthz/startup"
}
variable "health_readiness_path" {
  default = "/healthz/readiness"
}
variable "health_liveness_path" {
  default = "/healthz/liveness"
}
