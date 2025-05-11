terraform {
    required_providers {
	aws = {
	    source = "hashicorp/aws"
	    version = "~> 5.0"
	}
    }
}


provider "aws" {
    region = "us-east-1"
    #profile = 'production'
    #access_key = "accesskey"
    #secret_key = "secret_key"
    #shared_credentials_file = ["home/username/aws/credentials"]
 
}
