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

resource "aws_s3_bucket_notification" "image_resize_notification" {
  bucket = "${aws_s3_bucket.albums.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.image_resize_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "albums/"
    filter_suffix       = ".jpg"
  }
}

resource "aws_s3_bucket_notification" "image_resize_notification_png" {
  bucket     = "${aws_s3_bucket.albums.id}"
  depends_on = ["aws_s3_bucket_notification.image_resize_notification"]

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.image_resize_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "albums/"
    filter_suffix       = ".png"
  }
}

resource "aws_s3_bucket_notification" "image_resize_notification_jpeg" {
  bucket = "${aws_s3_bucket.albums.id}"
  depends_on = ["aws_s3_bucket_notification.image_resize_notification_png"]
  lambda_function {
    lambda_function_arn = "${aws_lambda_function.image_resize_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "albums/"
    filter_suffix       = ".jpeg"
  }
}

resource "aws_s3_bucket_notification" "image_resize_notification_bmp" {
  bucket = "${aws_s3_bucket.albums.id}"
  depends_on = ["aws_s3_bucket_notification.image_resize_notification_jpeg"]
  lambda_function {
    lambda_function_arn = "${aws_lambda_function.image_resize_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "albums/"
    filter_suffix       = ".bmp"
  }
}
