variable "token" {}

variable "access_key" {}
variable "secret_key" {}
variable "aws_region" {
    default = "us-east-1"
}

# CoreOS Stable Channel
variable "aws_amis" {
    default = {
        "ap-northeast-1": "ami-1fb9e61e"
        "sa-east-1" : "ami-8f57fe92"
        "ap-southeast-2" : "ami-874620bd"
        "ap-southeast-1" : "ami-d6d88084"
        "us-east-1"  : "ami-04a2766c"
        "us-west-2"  : "ami-3193e801"
        "us-west-1"  : "ami-63eae826"
        "eu-west-1"  : "ami-92ea39e5"
    }
}

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.aws_region}"
}

resource "aws_instance" "docker_host" {
  instance_type = "t1.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  count = 3
  key_name = "${var.aws_key_name}"
  security_groups = "coreos-testing"
  user_data = "#cloud-config\n\ncoreos:\n  etcd:\n    discovery: https://discovery.etcd.io/${var.token}\n  units:\n    - name: etcd.service\n      command: start\n    - name: fleet.service\n      command: start"
}

output "addresses" {
  value = "Public DNS Addresses: ${aws_instance.docker_host.*.public_dns}"
}
