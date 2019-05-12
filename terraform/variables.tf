variable "region" {
  default = "eu-west-1"
}

variable "site_bucket" {
  default     = "photos.jsbarber.net"
  description = "S3 Web Site Bucket"
}

variable "album_bucket" {
  default     = "jess-photo-albums"
  description = "S3 Bucket where Albums and Photos are stored"
}
