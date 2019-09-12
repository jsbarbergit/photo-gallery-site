provider "aws" {
  region  = "eu-west-1"
  version = "2.10.0"
}

terraform {
#  backend "s3" {
#    bucket = "jb-tf-remote-state"
#    key    = "photo-gallery-site/"
#    region = "eu-west-1"
#  }
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "JBTFCloudOrg"

    workspaces {
      name = "jess-photo-gallery-site"
    }
  }
  version = "0.11.13"
}

provider "template" {
  version = "2.1"
}
