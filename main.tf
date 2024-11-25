module "service_monitor_crd" {
  count  = var.service_monitor_crd_enabled ? 1 : 0
  source = "./addons/service_monitor_crd"
}

# Ingress Nginx Controller
module "ingress_nginx_controller" {
  source                = "./addons/ingress-nginx"
  count                 = var.ingress_nginx_enabled ? 1 : 0
  ingress_nginx_version = var.ingress_nginx_version
  project               = var.project
  region                = var.region
  environment           = var.environment
  name                  = var.name
  vpc_name              = var.vpc_name
}

## argocd
resource "kubernetes_namespace" "argocd" {
  count = var.argoworkflow_enabled || var.argocd_enabled ? 1 : 0
  metadata {
    name = var.argocd_enabled ? var.argocd_config.namespace : var.argoworkflow_config.namespace
  }
}
module "argocd" {
  source     = "./addons/argocd"
  depends_on = [kubernetes_namespace.argocd] #[module.aws_vpc_cni, module.service-monitor-crd, kubernetes_namespace.argocd, module.ingress-nginx]
  count      = var.argocd_enabled ? 1 : 0
  argocd_config = {
    hostname                     = var.argocd_config.hostname
    values_yaml                  = var.argocd_config.values_yaml
    redis_ha_enabled             = var.argocd_config.redis_ha_enabled
    autoscaling_enabled          = var.argocd_config.autoscaling_enabled
    slack_notification_token     = var.argocd_config.slack_notification_token
    argocd_notifications_enabled = var.argocd_config.argocd_notifications_enabled
    ingress_class_name           = var.argocd_config.ingress_class_name
  }
  namespace = var.argocd_config.namespace
}

# argo-workflow
module "argocd-workflow" {
  source     = "./addons/argocd-workflow"
  depends_on = [kubernetes_namespace.argocd] #[module.aws_vpc_cni, module.service-monitor-crd, kubernetes_namespace.argocd, module.ingress-nginx]
  count      = var.argoworkflow_enabled ? 1 : 0
  argoworkflow_config = {
    values              = var.argoworkflow_config.values
    hostname            = var.argoworkflow_config.hostname
    ingress_class_name  = var.argoworkflow_config.ingress_class_name
    autoscaling_enabled = var.argoworkflow_config.autoscaling_enabled
  }
  namespace = var.argoworkflow_config.namespace
}

# argo-project
module "argo-project" {
  source     = "./addons/argocd-projects"
  count      = var.argocd_enabled ? 1 : 0
  depends_on = [module.argocd, kubernetes_namespace.argocd]
  name       = var.argoproject_config.name
  namespace  = var.argocd_config.namespace
}

## KUBERNETES DASHBOARD
# module "kubernetes-dashboard" {
#   source                              = "./addons/kubernetes-dashboard"
#   count                               = var.kubernetes_dashboard_enabled ? 1 : 0
#   # depends_on                          = [module.cert-manager-le-http-issuer, module.ingress-nginx, module.service-monitor-crd]
#   k8s_dashboard_hostname              = var.k8s_dashboard_hostname
#   alb_acm_certificate_arn             = var.alb_acm_certificate_arn
#   k8s_dashboard_ingress_load_balancer = var.k8s_dashboard_ingress_load_balancer
#   ingress_class_name                  = var.enable_private_nlb ? "internal-${var.ingress_nginx_config.ingress_class_name}" : var.ingress_nginx_config.ingress_class_name
# }

# Internal Ingress Nginx Controller
module "internal_ingress_nginx_controller" {
  source                = "./addons/internal-ingress-nginx"
  count                 = var.internal_ingress_nginx_enabled ? 1 : 0
  ingress_nginx_version = var.ingress_nginx_version
  project               = var.project
  region                = var.region
  environment           = var.environment
  # name                  = var.name
  cluster_name          = var.cluster_name
  vpc_name              = var.vpc_name
}

# Cert-Manager
module "cert_manager" {
  source               = "./addons/cert-manager"
  count                = var.cert_manager_enabled ? 1 : 0
  cert_manager_version = var.cert_manager_version
}

resource "helm_release" "cert_manager_le_http" {
  depends_on = [module.cert_manager]
  count      = var.cert_manager_install_letsencrypt_http_issuers ? 1 : 0
  name       = "cert-manager-le-http"
  chart      = "${path.module}/addons/cert-manager-le-http"
  version    = "0.1.0"
  set {
    name  = "email"
    value = var.cert_manager_letsencrypt_email
    type  = "string"
  }
}

# External-Secrets
module "external_secrets" {
  source = "./addons/external-secrets"
  count  = var.external_secret_enabled ? 1 : 0

  project_id               = var.project
  name                     = var.name
  environment              = var.environment
  enable_service_monitor   = var.service_monitor_crd_enabled
  external_secrets_version = var.external_secrets_version
}

# Keda
module "keda" {
  source                 = "./addons/keda"
  depends_on             = [module.service_monitor_crd]
  count                  = var.enable_keda ? 1 : 0
  environment            = var.environment
  project_id             = var.project
  name                   = var.name
  enable_service_monitor = var.service_monitor_crd_enabled
  keda_version           = var.keda_version
}

# Reloader
module "reloader" {
  source                 = "./addons/reloader"
  depends_on             = [module.service_monitor_crd]
  count                  = var.enable_reloader ? 1 : 0
  reloader_version       = var.reloader_version
  enable_service_monitor = var.service_monitor_crd_enabled
}
