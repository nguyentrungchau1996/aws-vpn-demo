resource "aws_acm_certificate" "demoVPNServer" {
  private_key       = file("~/cert/server.key")
  certificate_body  = file("~/cert/server.crt")
  certificate_chain = file("~/cert/ca.crt")

  tags = {
    "Name" = "demoVPNServer"
  }
}

resource "aws_acm_certificate" "demoClientVPN" {
  private_key       = file("~/cert/client.key")
  certificate_body  = file("~/cert/client.crt")
  certificate_chain = file("~/cert/ca.crt")

  tags = {
    "Name" = "demoClientVPN"
  }
}

resource "aws_security_group" "demoVPNAccessSG" {
  vpc_id = aws_vpc.demoVPC.id
  name   = "demoVPNAccessSG"

  ingress {
    from_port   = 443
    protocol    = "UDP"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Incoming VPN connection"
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "demoVPNAccessSG"
  }
}

resource "aws_ec2_client_vpn_endpoint" "demoClientVPNEndpoint" {
  description            = "Client VPN endpoint"
  server_certificate_arn = aws_acm_certificate.demoClientVPN.arn
  client_cidr_block      = "10.2.0.0/16"
  split_tunnel           = true
  vpc_id = aws_vpc.demoVPC.id
  security_group_ids     = [aws_security_group.demoVPNAccessSG.id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.demoClientVPN.arn
  }

  connection_log_options {
    enabled = false
  }

  tags = {
    "Name" = "demoClientVPNEndpoint"
  }
}

resource "aws_ec2_client_vpn_network_association" "demoClientVPNNetworkAssociation" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.demoClientVPNEndpoint.id
  subnet_id              = aws_subnet.demoPublicSubnet.id

  lifecycle {
    ignore_changes = [subnet_id]
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "demoClientVPNAuthorizationRule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.demoClientVPNEndpoint.id
  target_network_cidr    = aws_vpc.demoVPC.cidr_block
  authorize_all_groups   = true
}
