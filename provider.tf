provider "aws" {
  shared_config_files = ["~/.aws/credentials"]
  profile             = "default"
  region              = "ap-southeast-1"
}