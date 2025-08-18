terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"        
    key            = "my_cicd_proj/terraform.tfstate"   
    region         = "ap-northeast-1"                  
    dynamodb_table = "my-terraform-locks"             
    encrypt        = true
  }
}
