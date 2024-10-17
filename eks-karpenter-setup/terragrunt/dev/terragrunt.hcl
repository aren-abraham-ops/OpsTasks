// terraform {
//   source = "../../terraform/eks"
// }

// remote_state {
//   backend = "s3"
//   config = {
//     bucket         = "ops-poc-s3-tfstate"
//     key            = "eks-infra/dev/terraform.tfstate"
//     region         = "us-west-2"
//     dynamodb_table = "ops-poc-dynamodb"
//     encrypt        = true
//   }
// }

// dependency "vpc" {
//   config_path = "../vpc"
// }


// inputs = {
//   aws_region          = "us-west-2"
//   cluster_name        = "dev-ops-cluster"
//   cluster_version     = "1.31"
//   vpc_id              = dependency.vpc.outputs.vpc_id
//   private_subnet_ids  = dependency.vpc.outputs.private_subnet_ids
//   key_name            = "dev-key-pair"
//   environment         = "dev"
// }
