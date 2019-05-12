resource "aws_s3_bucket" "site" {
  bucket = "photos.jsbarber.net"
  acl    = "public-read"
  policy = "${file("s3_policies/photos.jsbarber.net_policy.json")}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["DELETE", "GET", "HEAD", "PUT", "POST"]
    allowed_origins = ["*"]
  }
}
