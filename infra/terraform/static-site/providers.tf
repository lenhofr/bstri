provider "aws" {
  region = var.region
}

# CloudFront ACM certs must be in us-east-1
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
