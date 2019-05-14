data "template_file" "cognito_unauth_trust_tpl" {
  template = "${file("iam_policies/cognito_unauth_trust_policy.tpl")}"

  vars = {
    pool_id = "${aws_cognito_identity_pool.site_pool.id}"
  }
}

data "template_file" "cognito_unauth_tpl" {
  template = "${file("iam_policies/cognito_unauth_policy.tpl")}"
}

data "template_file" "lambda_image_trust_tpl" {
  template = "${file("iam_policies/lambda_image_trust_policy.tpl")}"
}

data "template_file" "lambda_image_tpl" {
  template = "${file("iam_policies/lambda_image_policy.tpl")}"
}

resource "aws_iam_role" "site_unauth_role" {
  name               = "photo_site_unauth_role"
  assume_role_policy = "${data.template_file.cognito_unauth_trust_tpl.rendered}"
}

resource "aws_iam_role_policy" "site_unauth_policy" {
  name = "Cognito_photo_site_unauth_policy"
  role = "${aws_iam_role.site_unauth_role.id}"

  policy = "${data.template_file.cognito_unauth_tpl.rendered}"
}

resource "aws_iam_role" "lambda_image_role" {
  name               = "lambda_image_role"
  assume_role_policy = "${data.template_file.lambda_image_trust_tpl.rendered}"
}

resource "aws_iam_role_policy" "lambda_image_policy" {
  name = "lambda_image_policy"
  role = "${aws_iam_role.lambda_image_role.id}"

  policy = "${data.template_file.lambda_image_tpl.rendered}"
}
