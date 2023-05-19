variable "secret_key" {
    default = ""
    sensitive = true
}

variable "access_key" {
    default = ""
    sensitive = true
}

variable "ami" {
    default = "ami-0fb391cce7a602d1f"
}

variable "type" {
    default = "t2.micro"
}

variable "vpcid" {
    default = "vpc-0456a399b3724e89b"
}

variable "subneta" {
    default = "subnet-0c6be4d6e10409a00"
}

variable "subnetb" {
    default = "subnet-0ef7012ca0fe5804e"
}

variable "region" {
    default = "eu-west-2"
}

variable "project" {
    default = "project"
}

variable "lab" {
    default = "lab_4"
}

variable "newkeyname" {
    default = "newkey"
}

variable "keyfilename" {
    default = "key.pem"
}