resource "aws_cloudfront_origin_access_identity" "webapp-oai" {
  comment = aws_s3_bucket_website_configuration.webapp-bucket-wesbite-config.website_domain
}

resource "aws_cloudfront_distribution" "webapp_distribution" {
  origin {
    domain_name = aws_s3_bucket.webapp-bucket.bucket_regional_domain_name
    origin_id   = var.s3OriginId

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.webapp-oai.cloudfront_access_identity_path
    }
  }

  origin {
  	domain_name = replace(aws_api_gateway_deployment.api-deployment.invoke_url, "/^https?://([^/]*).*/", "$1")
  	origin_id   = var.apiGatewayOriginId
	  origin_path = "/${var.apiStageName}"
    custom_header {
      name = "x-api-key"
      value = var.cloudfront-custom-header-key-value
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
    
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3OriginId

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/api"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.apiGatewayOriginId

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
	  viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 15
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.webapp_distribution.domain_name
}