data "template_file" "cognito_unauth_trust_tpl" {
  template = "${file("iam_policies/cognito_unauth_trust_policy.tpl")}"

  vars = {
    region  = "${var.region}"
    pool_id = "${aws_cognito_identity_pool.site_pool.id}"
  }
}

data "template_file" "cognito_unauth_tpl" {
  template = "${file("iam_policies/cognito_unauth_policy.tpl")}"
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
