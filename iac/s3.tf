locals {
  mime_types         = jsondecode(file("mime.json"))
  web_app_build_path = "../web-app/build/"
}

resource "aws_s3_bucket" "webapp-bucket" {
  bucket = var.bucketName
}

resource "aws_s3_bucket_ownership_controls" "web-bucket-ownership" {
  bucket = aws_s3_bucket.webapp-bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "webapp-bucket-public-access-block" {
  bucket = aws_s3_bucket.webapp-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "webapp-bucket-wesbite-config" {
  bucket = aws_s3_bucket.webapp-bucket.id
  index_document {
    suffix = "index.html"
  }
}

data "aws_iam_policy_document" "read_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.webapp-bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.webapp-oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "webapp-bucket-policy" {
  bucket = aws_s3_bucket.webapp-bucket.id
  policy = data.aws_iam_policy_document.read_bucket_policy.json
}

resource "aws_s3_object" "webapp-bucket-s3-objects" {
  for_each     = fileset(local.web_app_build_path, "**")
  bucket       = aws_s3_bucket.webapp-bucket.id
  key          = each.value
  source       = "${local.web_app_build_path}${each.value}"
  etag         = filemd5("${local.web_app_build_path}${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", "${local.web_app_build_path}${each.value}"), null)
}