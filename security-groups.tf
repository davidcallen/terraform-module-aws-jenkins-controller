# ---------------------------------------------------------------------------------------------------------------------
# Security Groups and Rules
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "jenkins-controller" {
  name        = local.name
  description = "jenkins-controller"
  vpc_id      = var.vpc.vpc_id
  tags = {
    Name            = local.name
    Application     = "jenkins-controller"
    ApplicationName = var.name_suffix
  }
}
resource "aws_security_group_rule" "jenkins-controller-allow-ingress-app-http" {
  type              = "ingress"
  description       = "http"
  from_port         = var.server_listening_port
  to_port           = var.server_listening_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ingress_cidrs.http
  security_group_id = aws_security_group.jenkins-controller.id
}
# All ingress to custom port 2022 (ssh)
resource "aws_security_group_rule" "jenkins-controller-allow-ingress-ssh" {
  type              = "ingress"
  description       = "ssh"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ingress_cidrs.ssh
  security_group_id = aws_security_group.jenkins-controller.id
}

# --------------------------------------- egress ------------------------------------------------------------------
resource "aws_security_group_rule" "jenkins-controller-allow-egress-app-http" {
  type              = "egress"
  description       = "http for the app"
  from_port         = var.server_listening_port
  to_port           = var.server_listening_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.http
  security_group_id = aws_security_group.jenkins-controller.id
}
resource "aws_security_group_rule" "jenkins-controller-allow-egress-ssh-to-workers" {
  type              = "egress"
  description       = "SSH to Jenkins Worker Nodes"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.http
  security_group_id = aws_security_group.jenkins-controller.id
}
# For yum updates
resource "aws_security_group_rule" "jenkins-controller-allow-egress-http" {
  type              = "egress"
  description       = "http"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.http
  security_group_id = aws_security_group.jenkins-controller.id
}
resource "aws_security_group_rule" "jenkins-controller-allow-egress-https" {
  type              = "egress"
  description       = "https"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.https
  security_group_id = aws_security_group.jenkins-controller.id
}
# For publish artifacts to our Nexus
resource "aws_security_group_rule" "jenkins-controller-allow-egress-nexus-http" {
  type              = "egress"
  description       = "http to our Nexus"
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.nexus
  security_group_id = aws_security_group.jenkins-controller.id
}
resource "aws_security_group_rule" "jenkins-controller-allow-egress-telegraf-influxdb" {
  type              = "egress"
  description       = "telegraf agent to influxdb"
  from_port         = 8086
  to_port           = 8086
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.telegraf_influxdb
  security_group_id = aws_security_group.jenkins-controller.id
}
