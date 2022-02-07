locals {
  bucket_name = "${var.org_domain_name}-${local.name}-files"
}
# S3 bucket to allow us to pass jenkins config files (configuration-as-code yaml) to jenkins but files too large to pass via ec2 user-data.
resource "aws_s3_bucket" "jenkins-config-files" {
  bucket        = local.bucket_name
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        Sid       = "Deny ALL access to all except Jenkins Controller Role and cloud admins",
        Effect    = "Deny"
        Principal = "*"
        //          AWS = [
        //            "arn:aws:iam::${var.environment.account_id}:root"
        //          ]
        //        }
        Action = [
          "s3:List*",
          "s3:GetObject*"
        ]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*",
        ]
        Condition = {
          StringNotLike = {
            "aws:userId" = [
              # Restrict access to jenkins ec2 instance, admins and OrganizationAccountAccessRole
              "${data.aws_iam_role.admin-role.unique_id}:*",
              "${data.aws_iam_role.OrganizationAccountAccessRole.unique_id}:*",
              "${data.aws_iam_role.jenkins-controller.unique_id}:*",
              var.environment.account_id
            ]
          }
        }
      }
    ]
  })
  lifecycle {
    prevent_destroy = false
    # cant use variable here for resource_deletion_protection :(
  }
  tags = merge(var.global_default_tags, var.environment.default_tags, {
    Name = local.bucket_name
  })
}
data "aws_iam_instance_profile" "jenkins-controller" {
  name = var.iam_instance_profile
}
data "aws_iam_role" "jenkins-controller" {
  name = data.aws_iam_instance_profile.jenkins-controller.role_name
}
data "aws_iam_role" "admin-role" {
  name = "${var.environment.resource_name_prefix}-admin"
}
data "aws_iam_role" "OrganizationAccountAccessRole" {
  name = "OrganizationAccountAccessRole"
}
//resource "aws_s3_bucket_object" "jenkins-config-files-upload" {
//  for_each = fileset("${path.module}/", "jenkins.yaml")
//
//  bucket  = aws_s3_bucket.jenkins-config-files.id
//  key     = each.value
//  source  = "${path.module}/${each.value}"
//  etag    = filemd5("${path.module}/${each.value}")
//}
//resource "aws_s3_bucket_object" "jenkins-config-files-upload" {
//  count  = length(var.jenkins_config_file_pathnames)
//
//  bucket  = aws_s3_bucket.jenkins-config-files.id
//  key     = var.jenkins_config_file_pathnames[count.index]
//  source  = var.jenkins_config_file_pathnames[count.index]
//  etag    = filemd5(var.jenkins_config_file_pathnames[count.index])
//}
resource "aws_s3_bucket_object" "jenkins-config-files-upload" {
  count          = length(var.jenkins_config_files)
  bucket         = aws_s3_bucket.jenkins-config-files.id
  key            = var.jenkins_config_files[count.index].filename
  content_base64 = var.jenkins_config_files[count.index].contents_base64
  etag           = var.jenkins_config_files[count.index].contents_md5_hash
}