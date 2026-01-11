locals {
  name = var.project
  tags = merge(var.tags, { project = var.project })
}

resource "aws_s3_bucket" "site" {
  bucket_prefix = "${local.name}-site-"
  force_destroy = false
  tags          = local.tags
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${local.name}-oac"
  description                       = "OAC for S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_iam_policy_document" "site_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_policy.json
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-site"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-site"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.custom_domain_name == null
    acm_certificate_arn            = var.custom_domain_name == null ? null : aws_acm_certificate_validation.cert[0].certificate_arn
    ssl_support_method             = var.custom_domain_name == null ? null : "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  aliases = var.custom_domain_name == null ? [] : [var.custom_domain_name]

  tags = local.tags
}

resource "aws_acm_certificate" "cert" {
  count             = var.custom_domain_name == null ? 0 : 1
  provider          = aws.use1
  domain_name       = var.custom_domain_name
  validation_method = "DNS"
  tags              = local.tags

  lifecycle {
    precondition {
      condition     = var.custom_domain_name == null || var.route53_zone_id != null
      error_message = "route53_zone_id must be set when using custom_domain_name (needed for ACM DNS validation)."
    }
  }
}

resource "aws_route53_record" "cert_validation" {
  count   = var.custom_domain_name == null ? 0 : length(aws_acm_certificate.cert[0].domain_validation_options)
  zone_id = var.route53_zone_id

  name    = aws_acm_certificate.cert[0].domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.cert[0].domain_validation_options[count.index].resource_record_type
  records = [aws_acm_certificate.cert[0].domain_validation_options[count.index].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  count           = var.custom_domain_name == null ? 0 : 1
  provider        = aws.use1
  certificate_arn = aws_acm_certificate.cert[0].arn

  validation_record_fqdns = aws_route53_record.cert_validation[*].fqdn
}

resource "aws_route53_record" "alias_a" {
  count   = var.custom_domain_name != null && var.create_route53_record ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.custom_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alias_aaaa" {
  count   = var.custom_domain_name != null && var.create_route53_record ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.custom_domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
