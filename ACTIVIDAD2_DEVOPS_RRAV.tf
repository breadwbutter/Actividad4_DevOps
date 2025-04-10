#ACTIVIDAD 2

#PROVEDOR
provider "aws" {
    region = "us-east-1"
}

#VPC
resource "aws_vpc" "act2terra_vpc" {
    cidr_block = "10.10.0.0/20"

    tags = {
        Name = "VPC-Act2-Terra"
    }
}

#SUBRED
resource "aws_subnet" "act2terra_subred_pub" {
    vpc_id = aws_vpc.act2terra_vpc.id
    cidr_block = "10.10.0.0/24"
    map_public_ip_on_launch = true

    tags = {
        Name = "Act2Terra_Subred"
    }
}

#Gateway
resource "aws_internet_gateway" "act2terra_igw" {
    vpc_id = aws_vpc.act2terra_vpc.id

    tags = {
        Name = "Act2terra_IGW"
    }
}

#TABLAS DE RUTA
resource "aws_route_table" "act2terra_tablaruta" {
    vpc_id = aws_vpc.act2terra_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.act2terra_igw.id
    }

    tags = {
        Name = "Act2terra_tablaruta"
    }
}

#ASOCIACION DE TABLAS DE RUTAS
resource "aws_route_table_association" "Act2terra_asociaciones" {
    subnet_id = aws_subnet.act2terra_subred_pub.id
    route_table_id = aws_route_table.act2terra_tablaruta.id
}

#======================CREACION DE GRUPOS DE SEGURIDAD======================

#SG JUMP SERVER
resource "aws_security_group" "SGTerra-WinJS" {
    vpc_id = aws_vpc.act2terra_vpc.id
    name = "SGTerra-WinJS"
    description = "Grupo de seguridad JumpServer para conectarme a los otros servers"

    #==========REGLAS DE ENTRADA==========

    #RDP
    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #==========REGLAS DE SALDIA==========

    #SSH
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.10.0.0/24"]
    }

    #RDP
    egress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["10.10.0.0/24"]
    }
}

#SG WINDOWS WEB
resource "aws_security_group" "SGTerra-WinWeb" {
    vpc_id = aws_vpc.act2terra_vpc.id
    name = "SGTerra-WinWeb"
    description = "Grupo de seguridad para Windows Web Server"

    #==========REGLAS DE ENTRADA==========
    #RDP
    ingress {
        from_port = 3389
        to_port = 3389
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

    #HTTP
    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    
}

#SG WINDOWS LINUX
resource "aws_security_group" "SGTerra-WinLin" {
    vpc_id = aws_vpc.act2terra_vpc.id
    name = "SGTerra-WinLin"
    description = "Grupo de seguridad para Windows Web Linux"

    #==========REGLAS DE ENTRADA==========
    #SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.10.0.0/24"]
    }

    #HTTP   
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #==========REGLAS DE SALDIA==========

    #HTTP
    egress {
        from_port = 80
        to_port = 80
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

#======================CREACION DE INSTANCIAS======================

#INSTANCIA DE WinJS
resource "aws_instance" "TerraWinJS" {
    ami = "ami-0c765d44cf1f25d26"
    instance_type = "t2.medium"

    subnet_id = aws_subnet.act2terra_subred_pub.id

    vpc_security_group_ids = [aws_security_group.SGTerra-WinJS.id]

    associate_public_ip_address = true

    key_name = "vockey"

    tags = {
        Name = "Servidor TerraWinJS"
    }

}

#INSTANCIA DE WinWeb
resource "aws_instance" "TerraWinWeb" {
    ami = "ami-0c765d44cf1f25d26"
    instance_type = "t2.medium"

    subnet_id = aws_subnet.act2terra_subred_pub.id

    vpc_security_group_ids = [aws_security_group.SGTerra-WinWeb.id]

    associate_public_ip_address = true

    key_name = "vockey"

    tags = {
        Name = "Servidor TerraWinWeb"
    }

}

#INSTANCIA DE Linux
resource "aws_instance" "TerraLinux" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

    subnet_id = aws_subnet.act2terra_subred_pub.id

    vpc_security_group_ids = [aws_security_group.SGTerra-WinLin.id]

    associate_public_ip_address = true

    key_name = "vockey"

    tags = {
        Name = "Servidor TerraLinux"
    }
}

#OUTPUT DE WinJS
output "public_ipWinJS" {
    description = "IP publica del WinJS"
    value = aws_instance.TerraWinJS.public_ip
}

#OUTPUT DE WinWeb
output "public_ipWinWeb" {
    description = "IP publica del WinWeb"
    value = aws_instance.TerraWinWeb.public_ip
}

#OUTPUT DE LinuxWeb
output "public_ipLinweb" {
    description = "IP publica del LinuxWeb"
    value = aws_instance.TerraLinux.public_ip
}