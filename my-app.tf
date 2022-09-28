terraform {
    required_version = ">= 0.12"
    # Backends -determines how state is loaded/stored -default:local storge
    backend "s3" {
      bucket = "tf-myapp-bucket"
      key = "myapp/state.tfstate"
      region = "ap-southeast-2" 
    }
}

provider "aws" {
    region = "ap-southeast-2"
 }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {Name = "${var.env_prefix}-subnet-1"}

  tags = {
    Name = "${var.env_prefix}-vpc"
    Environment = "dev"
  }
}

module "myapp-webserver"{
    source = "./modules/webserver"
    vpc_id = module.vpc.vpc_id 
    my_ip = var.my_ip
    image_name = var.image_name
    env_prefix = var.env_prefix
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    avail_zone = var.avail_zone
    subnet_id = module.vpc.public_subnets[0]
}

# resource "aws_route_table" "myapp-route_table" {
#     vpc_id = aws_vpc.myapp-vpc.id
#     route{
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.myapp_igw.id
#     }
#     tags = {
#         Name: "${var.env_prefix}-rtb"
#     }
# } 

# resource "aws_route_table_association" "a-rtb-subnet"{
#     subnet_id = aws_subnet.myapp-subnet-1.id
#     route_table_id = aws_route_table.myapp-route_table.id
# }

# $touch main.tf 创建文件

# $touch main.tf 创建文件