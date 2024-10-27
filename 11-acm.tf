module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${var.base_domain}"
  zone_id     = data.aws_route53_zone.base_domain.zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.base_domain}",
    "www.${var.base_domain}",
  ]

  wait_for_validation = true

  tags = {
    Name = "${var.base_domain}"
  }
}