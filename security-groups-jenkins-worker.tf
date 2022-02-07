# ---------------------------------------------------------------------------------------------------------------------
# Security Groups and Rules
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "jenkins-worker" {
  name        = "${var.environment.resource_name_prefix}-jenkins-worker"
  description = "jenkins-worker"
  vpc_id      = var.vpc.vpc_id
  tags = {
    Name            = "${var.environment.resource_name_prefix}-jenkins-worker"
    Application     = "jenkins-controller"
    ApplicationName = var.name_suffix
  }
}
# All ingress to custom port 2022 (ssh)
resource "aws_security_group_rule" "jenkins-worker-allow-ingress-ssh" {
  type              = "ingress"
  description       = "ssh"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ingress_cidrs.ssh
  security_group_id = aws_security_group.jenkins-worker.id
}

# --------------------------------------- egress ------------------------------------------------------------------
# For yum updates
resource "aws_security_group_rule" "jenkins-worker-allow-egress-http" {
  type              = "egress"
  description       = "http"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.http
  security_group_id = aws_security_group.jenkins-worker.id
}
# For yum updates
resource "aws_security_group_rule" "jenkins-worker-allow-egress-https" {
  type              = "egress"
  description       = "https"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.https
  security_group_id = aws_security_group.jenkins-worker.id
}
# For publish artifacts to our Nexus
resource "aws_security_group_rule" "jenkins-worker-allow-egress-nexus-http" {
  type              = "egress"
  description       = "http to our Nexus"
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.nexus
  security_group_id = aws_security_group.jenkins-worker.id
}
resource "aws_security_group_rule" "jenkins-worker-allow-egress-telegraf-influxdb" {
  type              = "egress"
  description       = "telegraf agent to influxdb"
  from_port         = 8086
  to_port           = 8086
  protocol          = "tcp"
  cidr_blocks       = var.allowed_egress_cidrs.telegraf_influxdb
  security_group_id = aws_security_group.jenkins-worker.id
}
