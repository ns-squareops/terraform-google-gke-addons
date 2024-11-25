variable "name" {
  description = "The suffix name for the resources being created."
  type        = string
}

variable "ingress_nginx_enabled" {
  description = "Enable or disable the nginx-ingress controller"
  type        = bool
  default     = false
}

variable "argocd_enabled" {
  description = "Determine whether argocd is enabled or not"
  default     = false
  type        = bool
}

variable "argocd_config" {
  type = object({
    hostname                     = string
    values_yaml                  = any
    redis_ha_enabled             = bool
    autoscaling_enabled          = bool
    slack_notification_token     = string
    argocd_notifications_enabled = bool
    ingress_class_name           = string
    namespace                    = string
  })

  default = {
    hostname                     = ""
    values_yaml                  = {}
    redis_ha_enabled             = false
    autoscaling_enabled          = false
    slack_notification_token     = ""
    argocd_notifications_enabled = false
    ingress_class_name           = ""
    namespace                    = "argocd"
  }
}

variable "argoworkflow_enabled" {
  description = "Determine whether argocd-workflow is enabled or not"
  default     = false
  type        = bool
}

variable "argoworkflow_config" {
  type = object({
    values              = any
    namespace           = string
    hostname            = string
    ingress_class_name  = string
    autoscaling_enabled = bool
  })

  default = {
    values              = {}
    namespace           = "argocd"
    hostname            = ""
    ingress_class_name  = ""
    autoscaling_enabled = true
  }
}

variable "argoproject_config" {
  type = object({
    name = string
  })

  default = {
    name = ""
  }
}

variable "kubernetes_dashboard_enabled" {
  description = "Determines whether k8s-dashboard is enabled or not"
  default     = false
  type        = bool
}

variable "kubernetes_dashboard_config" {
  description = "Specify all the configuration setup here"
  type = object({
    k8s_dashboard_ingress_load_balancer = string
    alb_acm_certificate_arn             = string
    k8s_dashboard_hostname              = string
    private_alb_enabled                 = bool
  })

  default = {
    k8s_dashboard_ingress_load_balancer = ""
    alb_acm_certificate_arn             = ""
    k8s_dashboard_hostname              = ""
    private_alb_enabled                 = false
  }
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "internal_ingress_nginx_enabled" {
  description = "Enable or disable the nginx-ingress controller"
  type        = bool
  default     = false
}

variable "ingress_nginx_version" {
  description = "Version of the nginx-ingress controller"
  type        = string
  default     = "4.11.0"
}

variable "project" {
  description = "ID of the Google Cloud project"
  type        = string
  default     = ""
}

variable "region" {
  description = "Region where the resources will be provisioned"
  type        = string
  default     = "asia-south1"
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = ""
}

variable "cert_manager_enabled" {
  description = "Enable or disable the nginx-ingress controller"
  type        = bool
  default     = false
}

variable "cert_manager_version" {
  description = "Version of cert-manager to deploy"
  type        = string
  default     = "1.15.1"
}

variable "cert_manager_install_letsencrypt_http_issuers" {
  description = "Enable or disable installation of Let's Encrypt HTTP issuers for cert-manager"
  type        = bool
  default     = false
}

variable "cert_manager_letsencrypt_email" {
  description = "Email address to register with Let's Encrypt for cert-manager"
  type        = string
  default     = ""
}

variable "external_secret_enabled" {
  description = "Enable or disable external-secrets deployment"
  type        = bool
  default     = false
}

variable "external_secrets_version" {
  description = "Version of the external-secret operator"
  type        = string
  default     = "0.8.3"
}

variable "environment" {
  description = "Environment in which the infrastructure is being deployed (e.g., production, staging, development)"
  type        = string
}

variable "service_monitor_crd_enabled" {
  description = "Enable or disable the installation of Custom Resource Definitions (CRDs) for Prometheus Service Monitor. "
  default     = false
  type        = bool
}

variable "enable_keda" {
  description = "Enable or disable keda deployment"
  type        = bool
  default     = false
}

variable "keda_version" {
  description = "Version of KEDA to deploy"
  type        = string
  default     = "2.10.2"
}

variable "enable_reloader" {
  description = "Enable or disable reloader"
  default     = false
  type        = bool
}

variable "reloader_version" {
  description = "Reloader release version"
  default     = "1.0.27"
  type        = string
}
