data "aws_availability_zones" "available" {
  state = "available"
}

# VPCの設定
resource "aws_vpc" "sbcntr_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "sbcntrVpc"
  }
}

############### Subnet, RouteTable, IGW ###############

# コンテナ周りの設定

## コンテナアプリ用のプライベートサブネット
resource "aws_subnet" "sbcntr_subnet_private_container_1a" {
  cidr_block     = "10.0.8.0/24"
  vpc_id         = aws_vpc.sbcntr_vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "sbcntr_subnet_private_container_1c" {
  cidr_block     = "10.0.9.0/24"
  vpc_id         = aws_vpc.sbcntr_vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, 1)
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1c"
    Type = "Isolated"
  }
}

## コンテナアプリ用のルートテーブル
resource "aws_route_table" "sbcntr_route_app" {
  vpc_id = aws_vpc.sbcntr_vpc.id

  tags = {
    Name = "sbcntr-route-app"
  }
}

## コンテナサブネットへルート紐付け
resource "aws_route_table_association" "sbcntr_route_app_association_1a" {
  subnet_id      = aws_subnet.sbcntr_subnet_private_container_1a.id
  route_table_id = aws_route_table.sbcntr_route_app.id
}

resource "aws_route_table_association" "sbcntr_route_app_association_1c" {
  subnet_id      = aws_subnet.sbcntr_subnet_private_container_1c.id
  route_table_id = aws_route_table.sbcntr_route_app.id
}

# DB周りの設定

## DB用のプライベートサブネット
resource "aws_subnet" "sbcntr_subnet_private_db_1a" {
  cidr_block     = "10.0.16.0/24"
  vpc_id         = aws_vpc.sbcntr_vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-db-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "sbcntr_subnet_private_db_1c" {
  cidr_block     = "10.0.17.0/24"
  vpc_id         = aws_vpc.sbcntr_vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, 1)
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-db-1c"
    Type = "Isolated"
  }
}

## DB用のルートテーブル
resource "aws_route_table" "sbcntr_route_db" {
  vpc_id = aws_vpc.sbcntr_vpc.id

  tags = {
    Name = "sbcntr-route-db"
  }
}

## DBサブネットへルート紐付け
resource "aws_route_table_association" "sbcntr_route_db_association_1a" {
  subnet_id      = aws_subnet.sbcntr_subnet_private_db_1a.id
  route_table_id = aws_route_table.sbcntr_route_db.id
}

resource "aws_route_table_association" "sbcntr_route_db_association_1c" {
  subnet_id      = aws_subnet.sbcntr_subnet_private_db_1c.id
  route_table_id = aws_route_table.sbcntr_route_db.id
}

# Ingress周りの設定

## Ingress用のパブリックサブネット
resource "aws_subnet" "sbcntr_subnet_public_ingress_1a" {
  cidr_block     = "10.0.0.0/24"
  vpc_id         = aws_vpc.sbcntr_vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1a"
    Type = "Public"
  }
}

resource "aws_subnet" "sbcntr_subnet_public_ingress_1c" {
  cidr_block     = "10.0.1.0/24"
  vpc_id         = aws_vpc.sbcntr_vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1c"
    Type = "Public"
  }
}

## Ingress用のルートテーブル
resource "aws_route_table" "sbcntr_route_ingress" {
  vpc_id = aws_vpc.sbcntr_vpc.id

  tags = {
    Name = "sbcntr-route-ingress"
  }
}

## Ingressサブネットへルート紐付け
resource "aws_route_table_association" "sbcntr_route_ingress_association_1a" {
  subnet_id      = aws_subnet.sbcntr_subnet_public_ingress_1a.id
  route_table_id = aws_route_table.sbcntr_route_ingress.id
}

resource "aws_route_table_association" "sbcntr_route_ingress_association_1c" {
  subnet_id      = aws_subnet.sbcntr_subnet_public_ingress_1c.id
  route_table_id = aws_route_table.sbcntr_route_ingress.id
}

## Ingress用ルートテーブルのデフォルトルート
resource "aws_route" "sbcntr_route_ingress_default" {
  route_table_id         = aws_route_table.sbcntr_route_ingress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sbcntr_igw.id

  #depends_on = [aws_vpc_gateway_attachment.sbcntr_vpcgw_attachment]
}


# 管理用サーバ周りの設定

## 管理用のパブリックサブネット
resource "aws_subnet" "sbcntr_subnet_public_management_1a" {
  cidr_block     = "10.0.240.0/24"
  vpc_id         = aws_vpc.sbcntr_vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1a"
    Type = "Public"
  }
}

resource "aws_subnet" "sbcntr_subnet_public_management_1c" {
  cidr_block     = "10.0.241.0/24"
  vpc_id         = aws_vpc.sbcntr_vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1c"
    Type = "Public"
  }
}

## 管理用サブネットのルートはIngressと同様として作成する
resource "aws_route_table_association" "sbcntr_route_management_association_1a" {
  route_table_id = aws_route_table.sbcntr_route_ingress.id
  subnet_id      = aws_subnet.sbcntr_subnet_public_management_1a.id
}

resource "aws_route_table_association" "sbcntr_route_management_association_1c" {
  route_table_id = aws_route_table.sbcntr_route_ingress.id
  subnet_id      = aws_subnet.sbcntr_subnet_public_management_1c.id
}

# インターネットへ通信するためのゲートウェイの作成
resource "aws_internet_gateway" "sbcntr_igw" {
  vpc_id = aws_vpc.sbcntr_vpc.id

  tags = {
    Name = "sbcntr-igw"
  }
}

/*
resource "aws_vpc_gateway_attachment" "sbcntr_vpcgw_attachment" {
  vpc_id             = aws_vpc.sbcntr_vpc.id
  internet_gateway_id = aws_internet_gateway.sbcntr_igw.id
}
*/

############### Security groups ###############

# セキュリティグループの生成

## インターネット公開のセキュリティグループの生成
resource "aws_security_group" "sbcntr_sg_ingress" {
  name        = "ingress"
  description = "Security group for ingress"
  vpc_id      = aws_vpc.sbcntr_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "from 0.0.0.0/0:80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    ipv6_cidr_blocks = ["::/0"]
    description = "from ::/0:80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  tags = {
    Name = "sbcntr-sg-ingress"
  }
}

## 管理用サーバ向けのセキュリティグループの生成
resource "aws_security_group" "sbcntr_sg_management" {
  name        = "management"
  description = "Security Group of management server"
  vpc_id      = aws_vpc.sbcntr_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "sbcntr-sg-management"
  }
}

## バックエンドコンテナアプリ用セキュリティグループの生成
resource "aws_security_group" "sbcntr_sg_container" {
  name        = "container"
  description = "Security Group of backend app"
  vpc_id      = aws_vpc.sbcntr_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "sbcntr-sg-container"
  }
}

## フロントエンドコンテナアプリ用セキュリティグループの生成
resource "aws_security_group" "sbcntr_sg_front_container" {
  name        = "front-container"
  description = "Security Group of front container app"
  vpc_id      = aws_vpc.sbcntr_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "sbcntr-sg-front-container"
  }
}

## 内部用ロードバランサ用のセキュリティグループの生成
resource "aws_security_group" "sbcntr_sg_internal" {
  description = "Security group for internal load balancer"
  name  = "internal"
  vpc_id      = aws_vpc.sbcntr_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "sbcntr-sg-internal"
  }
}

## DB用セキュリティグループの生成
resource "aws_security_group" "sbcntr_sg_db" {
  description = "Security Group of database"
  name  = "database"
  vpc_id      = aws_vpc.sbcntr_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "sbcntr-sg-db"
  }
}

# ルール紐付け
## Internet LB -> Front Container
resource "aws_vpc_security_group_ingress_rule" "sbcntr_sg_front_container_froms_sg_ingress" {
  ip_protocol               = "tcp"
  description               = "HTTP for Ingress"
  from_port                 = 80
  to_port                   = 80
  security_group_id         = aws_security_group.sbcntr_sg_front_container.id
  referenced_security_group_id  = aws_security_group.sbcntr_sg_ingress.id
}

## Front Container -> Internal LB
resource "aws_vpc_security_group_ingress_rule" "sbcntr_sg_internal_from_sg_front_container" {
  ip_protocol               = "tcp"
  description               = "HTTP for front container"
  from_port                 = 80
  to_port                   = 80
  security_group_id         = aws_security_group.sbcntr_sg_internal.id
  referenced_security_group_id  = aws_security_group.sbcntr_sg_front_container.id
}

## Internal LB -> Back Container
resource "aws_vpc_security_group_ingress_rule" "sbcntr_sg_container_from_sg_internal" {
  ip_protocol               = "tcp"
  description               = "HTTP for internal lb"
  from_port                 = 80
  to_port                   = 80
  security_group_id         = aws_security_group.sbcntr_sg_container.id
  referenced_security_group_id  = aws_security_group.sbcntr_sg_internal.id
}

## Back container -> DB
resource "aws_vpc_security_group_ingress_rule" "sbcntr_sg_db_from_sg_container_tcp" {
  ip_protocol               = "tcp"
  description               = "MySQL protocol from backend App"
  from_port                 = 3306
  to_port                   = 3306
  security_group_id         = aws_security_group.sbcntr_sg_db.id
  referenced_security_group_id  = aws_security_group.sbcntr_sg_container.id
}

## Front container -> DB
resource "aws_vpc_security_group_ingress_rule" "sbcntr_sg_db_from_sg_front_container_tcp" {
  ip_protocol               = "tcp"
  description               = "MySQL protocol from frontend App"
  from_port                 = 3306
  to_port                   = 3306
  security_group_id         = aws_security_group.sbcntr_sg_db.id
  referenced_security_group_id = aws_security_group.sbcntr_sg_front_container.id
}

## Management server -> DB
resource "aws_vpc_security_group_ingress_rule" "sbcntr_sg_db_from_sg_management_tcp" {
  ip_protocol               = "tcp"
  description               = "MySQL protocol from management server"
  from_port                 = 3306
  to_port                   = 3306
  security_group_id         = aws_security_group.sbcntr_sg_db.id
  referenced_security_group_id  = aws_security_group.sbcntr_sg_management.id
}

## Management server -> Internal LB
resource "aws_vpc_security_group_ingress_rule" "sbcntr_sg_internal_from_sg_management_tcp" {
  ip_protocol               = "tcp"
  description               = "HTTP for management server"
  from_port                 = 80
  to_port                   = 80
  security_group_id         = aws_security_group.sbcntr_sg_internal.id
  referenced_security_group_id  = aws_security_group.sbcntr_sg_management.id
}
