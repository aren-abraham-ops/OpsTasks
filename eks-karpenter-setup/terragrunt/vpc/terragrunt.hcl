// terraform {
//   source = "../../terraform/vpc"
// }

// remote_state {
//   backend = "s3"
//   config = {
//     bucket         = "ops-poc-s3-tfstate"
//     key            = "vpc/terraform.tfstate"
//     region         = "us-west-2"
//     dynamodb_table = "ops-poc-dynamodb"
//     encrypt        = true
//   }
// }

// inputs = {
//   aws_region            = "us-west-2"
//   vpc_cidr              = "10.0.0.0/16"
//   public_subnet_count   = 2
//   private_subnet_count  = 2
//   availability_zones    = ["us-west-2a", "us-west-2b"]
//   environment           = "dev"
// }
