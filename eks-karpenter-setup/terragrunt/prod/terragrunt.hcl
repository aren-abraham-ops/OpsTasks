terraform {
  source = "../../terraform/eks/"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "ops-poc-s3-tfstate"
    key            = "eks-infra/prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "ops-poc-dynamodb"
    encrypt        = true
  }
}

dependencies {
  paths = ["../../vpc"]
}

inputs = {
  aws_region          = "us-east-1"
  cluster_name        = "prod-ops-cluster"
  cluster_version     = "1.31"
  vpc_id              = dependency.vpc.outputs.vpc_id
  private_subnet_ids  = dependency.vpc.outputs.private_subnet_ids
  key_name            = "prod-key-pair"
  environment         = "prod"
}
