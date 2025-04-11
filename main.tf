#ACTIVIDAD 3

#PROVEDOR
provider "aws" {
    region = "us-east-1"
}

#VPC
resource "aws_vpc" "act3_vpc" {
    cidr_block = "10.10.0.0/20"

    tags = {
        Name = "VPC-Act3"
    }
}

#SUBRED
resource "aws_subnet" "act3_subred_pub" {
    vpc_id = aws_vpc.act3_vpc.id
    cidr_block = "10.10.0.0/24"
    map_public_ip_on_launch = true

    tags = {
        Name = "Act3_Subred"
    }
}

#Gateway
resource "aws_internet_gateway" "act3_igw" {
    vpc_id = aws_vpc.act3_vpc.id

    tags = {
        Name = "Act3_IGW"
    }
}

#TABLAS DE RUTA
resource "aws_route_table" "act3_tablaruta" {
    vpc_id = aws_vpc.act3_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.act3_igw.id
    }

    tags = {
        Name = "Act3_tablaruta"
    }
}

#ASOCIACION DE TABLAS DE RUTAS
resource "aws_route_table_association" "Act3_asociaciones" {
    subnet_id = aws_subnet.act3_subred_pub.id
    route_table_id = aws_route_table.act3_tablaruta.id
}

#======================CREACION DE GRUPOS DE SEGURIDAD======================

#SG JUMP SERVER
resource "aws_security_group" "SG-JS-Linux" {
    vpc_id = aws_vpc.act3_vpc.id
    name = "SG-JS-Linux"
    description = "Grupo de seguridad para el Jump Server Linux"

    #==========REGLAS DE ENTRADA==========

    #SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #HTTP
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #==========REGLAS DE SALDIA==========

    #SSH
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #TODO EL TRAFICO
    egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }    

}

#SG LINUX WEB SERVER
resource "aws_security_group" "SG-LinWeb" {
    vpc_id = aws_vpc.act3_vpc.id
    name = "SG-LinWeb"
    description = "Grupo de seguridad para Linux Web Server"

    #==========REGLAS DE ENTRADA==========
    #SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #==========REGLAS DE SALDIA==========

    #TODO EL TRAFICO
    egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }    
}

#======================CREACION DE INSTANCIAS======================

#INSTANCIA DE Linux-JS
resource "aws_instance" "LinuxJS" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

    subnet_id = aws_subnet.act3_subred_pub.id

    vpc_security_group_ids = [aws_security_group.SG-JS-Linux.id]

    associate_public_ip_address = true

    key_name = "vockey"

    tags = {
        Name = "Servidor Linux JS"
    }

}

#INSTANCIA DE Linux Web 1
resource "aws_instance" "Linux-Web1" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

    subnet_id = aws_subnet.act3_subred_pub.id

    vpc_security_group_ids = [aws_security_group.SG-LinWeb.id]

    associate_public_ip_address = true

    key_name = "vockey"

    tags = {
        Name = "Servidor Linux Web1"
    }
}

#INSTANCIA DE Linux Web 2
resource "aws_instance" "Linux-Web2" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

    subnet_id = aws_subnet.act3_subred_pub.id

    vpc_security_group_ids = [aws_security_group.SG-LinWeb.id]

    associate_public_ip_address = true

    key_name = "vockey"

    tags = {
        Name = "Servidor Linux Web2"
    }
}

#INSTANCIA DE Linux Web 3
resource "aws_instance" "Linux-Web3" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

    subnet_id = aws_subnet.act3_subred_pub.id

    vpc_security_group_ids = [aws_security_group.SG-LinWeb.id]

    associate_public_ip_address = true

    key_name = "vockey"

    tags = {
        Name = "Servidor Linux Web3"
    }
}

#INSTANCIA DE Linux Web 4
resource "aws_instance" "Linux-Web4" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

    subnet_id = aws_subnet.act3_subred_pub.id

    vpc_security_group_ids = [aws_security_group.SG-LinWeb.id]

    associate_public_ip_address = true

    key_name = "vockey"

    tags = {
        Name = "Servidor Linux Web4"
    }
}

#===========================OUTPUTS===========================

#OUTPUT DE Linux Jump Server
output "public_ipLinuxJS" {
    description = "IP publica del Linux-JS"
    value = aws_instance.LinuxJS.public_ip
}

#OUTPUT DE LinuxWeb1
output "public_ipLinuxWeb1" {
    description = "IP publica del LinuxWeb1"
    value = aws_instance.Linux-Web1.public_ip
}

#OUTPUT DE LinuxWeb2
output "public_ipLinuxWeb2" {
    description = "IP publica del LinuxWeb2"
    value = aws_instance.Linux-Web2.public_ip
}

#OUTPUT DE LinuxWeb3
output "public_ipLinuxWeb3" {
    description = "IP publica del LinuxWeb3"
    value = aws_instance.Linux-Web3.public_ip
}

#OUTPUT DE LinuxWeb4
output "public_ipLinuxWeb4" {
    description = "IP publica del LinuxWeb4"
    value = aws_instance.Linux-Web4.public_ip
}
