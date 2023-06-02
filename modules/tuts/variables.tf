variable "name" {}
variable "k8s_namespace" {}
variable "project_id" {}
variable "nonce" {}
variable "app_env" {}
variable "gke_cluster_name" {}
variable "region" {}
variable "ssl_domains" {
  type = list(string)
}
variable "replicas" {}
variable "PORT" {}
