resource "aws_s3_bucket" "site" {
  bucket = "${var.site_bucket}"
  acl    = "public-read"
  policy = "${file("s3_policies/photos.jsbarber.net_policy.json")}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "albums" {
  bucket = "${var.album_bucket}"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["DELETE", "GET", "HEAD", "PUT", "POST"]
    allowed_origins = ["*"]
  }
}
