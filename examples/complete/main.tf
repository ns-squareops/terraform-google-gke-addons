locals {
  region       = "asia-south1"
  location     = "asia-south1"
  environment  = "dev"
  name         = "gkeaddons"
  project_name = "atmosly-439606"
  project      = "atmosly-439606"
  cluster_name = "gke-dev-gke-cluster"
  argocd_namespace = "argocd"
}

module "gke_addons" {
  source = "../../"

  name                                          = local.name
  region                                        = local.region
  project                                       = local.project
  environment                                   = local.environment
  cluster_name                                  = local.cluster_name
  ingress_nginx_enabled                         = false
  internal_ingress_nginx_enabled                = true # not working 
  cert_manager_enabled                          = true
  cert_manager_install_letsencrypt_http_issuers = true
  cert_manager_letsencrypt_email                = "mona@squareops.com"
  external_secret_enabled                       = false
  service_monitor_crd_enabled                   = false
  enable_keda                                   = false
  enable_reloader                               = false
  vpc_name                                      = "atmosly-vpc"

## ArgoCD
  argocd_enabled = false
  argocd_config = {
    hostname                     = "argocd.rnd.squareops.in"
    values_yaml                  = file("${path.module}/config/argocd.yaml")
    namespace                    = local.argocd_namespace
    redis_ha_enabled             = true
    autoscaling_enabled          = true
    slack_notification_token     = ""
    argocd_notifications_enabled = false
    ingress_class_name           = "nginx" # enter ingress class name according to your requirement (example: "ingress-nginx", "internal-ingress")
  }
  argoproject_config = {
    name = "argo-project" # enter name for aro-project appProjects
  }

  ## ArgoCD-Workflow
  argoworkflow_enabled = false
  argoworkflow_config = {
    values              = file("${path.module}/config/argocd-workflow.yaml")
    namespace           = local.argocd_namespace
    autoscaling_enabled = true
    hostname            = "argocd-workflow.rnd.squareops.in"
    ingress_class_name  = "nginx" # enter ingress class name according to your requirement (example: "ingress-nginx", "internal-ingress")
  }

  ## KUBERNETES-DASHBOARD
  kubernetes_dashboard_enabled = false
  kubernetes_dashboard_config = {
    k8s_dashboard_ingress_load_balancer = "alb"                            ##Choose your load balancer type (e.g., NLB or ALB). Enable load balancer controller, if you require ALB, Enable Ingress Nginx if NLB.
    private_alb_enabled                 = false                            # to enable Internal (Private) ALB , set this and aws_load_balancer_controller_enabled "true" together
    alb_acm_certificate_arn             = ""                               # If using ALB in above parameter, ensure you provide the ACM certificate ARN for SSL.
    k8s_dashboard_hostname              = "k8s-dashboard.rnd.squareops.in" # Enter Hostname
    ingress_class_name                  = "gce"
  }  
}
