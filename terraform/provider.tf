provider "aws" {
  region  = "eu-west-1"
  version = "2.10.0"
}

terraform {
  backend "s3" {
    bucket = "jb-tf-remote-state"
    key    = "photo-gallery-site/"
    region = "eu-west-1"
  }

  version = "0.11.13"
}

provider "template" {
  version = "2.1"
}
