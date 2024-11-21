# resource "aws_route53_record" "dev_subdomain" {
#   zone_id = "Z02358762FHWIMLLNZDGB"
#   name    = "dev.awsclouddomainname.me"
#   type    = "A"

#   alias {
#     name                   = aws_lb.web_app_alb.dns_name
#     zone_id                = aws_lb.web_app_alb.zone_id
#     evaluate_target_health = true
#   }
# }

resource "aws_route53_record" "demo_subdomain" {
  zone_id = "Z05273572T1HH39BIZ2MZ"
  name    = "demo.awsclouddomainname.me"
  type    = "A"

  alias {
    name                   = aws_lb.web_app_alb.dns_name
    zone_id                = aws_lb.web_app_alb.zone_id
    evaluate_target_health = true
  }
}
