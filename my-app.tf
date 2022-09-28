provider "aws" {
    region = "ap-southeast-2"
 }

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet"{
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id 
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-webserver"{
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id 
    my_ip = var.my_ip
    image_name = var.image_name
    env_prefix = var.env_prefix
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    avail_zone = var.avail_zone
    subnet_id = module.myapp-subnet.subnet.id
}



## create a new security group
# resource "aws_security_group" "myapp-sg" {
#     name = "myapp-sg"
#     vpc_id = aws_vpc.myapp-vpc.id 
#     ingress{
#         from_port = 22
#         to_port = 22
#         protocol = "tcp"
#         cidr_blocks = [var.my_ip] #who is allowed to access resource on port 22
#     }
#     ingress{
#         from_port = 8080 
#         to_port = 8080
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"] 
#     }

#     egress{
#         from_port = 0
#         to_port = 0
#         protocol = "-1"
#         cidr_blocks = ["0.0.0.0/0"] 
#         prefix_list_ids = []
#     }
#     tags = {
#         Name: "${var.env_prefix}-sg"
#     }
# }

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