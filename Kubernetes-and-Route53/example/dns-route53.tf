
# =====================================================
# Create Geo-DNS records for Application in AWS Route53
# =====================================================

locals {
  lb_name_parts = split("-", split(".", kubernetes_service.eks_nginx.status.0.load_balancer.0.ingress.0.hostname).0)
}

data "aws_elb" "eks_svc" {
  name = join("-", slice(local.lb_name_parts, 0, length(local.lb_name_parts) - 1))
}

resource "aws_route53_zone" "main" {
  name = var.aws_domain_name
}

resource "aws_route53_record" "www_us" {
  zone_id = aws_route53_zone.main.zone_id
  name = "aws"
  type = "A"

  alias {
    name = "${kubernetes_service.eks_nginx.status.0.load_balancer.0.ingress.0.hostname}"
    zone_id = "${data.aws_elb.eks_svc.zone_id}"
    evaluate_target_health = true
  }
  set_identifier = "us"
  geolocation_routing_policy {
    country = "US"
  }

  depends_on = [
    kubernetes_pod.eks_nginx,
    kubernetes_service.eks_nginx
  ]
}


resource "aws_route53_record" "www_il" {
  zone_id = aws_route53_zone.main.zone_id
  name = "aws"
  type = "A"
  ttl = "5"

  records = [kubernetes_service.mk8s_nginx.status.0.load_balancer.0.ingress.0.ip]
  set_identifier = "il"
  geolocation_routing_policy {
    country = "IL"
  }

  depends_on = [
    kubernetes_pod.mk8s_nginx,
    kubernetes_service.mk8s_nginx
  ]
}

output "r53-nameserver" {
  value = aws_route53_zone.main.name_servers[0]
}
