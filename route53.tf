resource "aws_route53_record" "dev_subdomain" {
  zone_id = "Z02358762FHWIMLLNZDGB"
  name    = "dev.awsclouddomainname.me"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web_app.public_ip]
}

resource "aws_route53_record" "demo_subdomain" {
  zone_id = "Z05273572T1HH39BIZ2MZ"
  name    = "demo.awsclouddomainname.me"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web_app.public_ip]
}
