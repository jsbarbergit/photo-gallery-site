resource "null_resource" "update_lambda_zip" {
  # Ensure this runs every time
  triggers {
    rerun = "${uuid()}"
  }

  provisioner "local-exec" {
    command     = "./create_lambda_package.sh image_resize"
  }
}

resource "aws_lambda_function" "image_resize_lambda" {
  depends_on       = ["null_resource.update_lambda_zip"]
  filename         = "lambda_functions/image_resize/function.zip"
  function_name    = "image_resizer"
  description      = "Resize .jpg and .png images to thumbnails. Triggered on S3 PutObject. Writes thumbnail back with _thumbnail suffix"
  role             = "${aws_iam_role.lambda_image_role.arn}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  timeout          = "300"
  memory_size      = "320"
  source_code_hash = "${base64sha256(file("lambda_functions/image_resize/function.zip"))}"
}

resource "aws_lambda_permission" "image_resize_bucket_access" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.image_resize_lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.albums.arn}"
}
