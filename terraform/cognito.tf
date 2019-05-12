resource "aws_cognito_identity_pool" "site_pool" {
  identity_pool_name               = "photo_site_pool"
  allow_unauthenticated_identities = true
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = "${aws_cognito_identity_pool.site_pool.id}"

  roles {
    "unauthenticated" = "${aws_iam_role.site_unauth_role.arn}"
  }
}
