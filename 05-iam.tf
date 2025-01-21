resource "aws_iam_openid_connect_provider" "github_actions_oidc_provider" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_ecr" {
  name = "finalproject-github-actions-ecr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_organization}/*:*"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "finalproject-ecr-rw"
  description = "Policy to manage ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "ecr:PutImageTagMutability",
          "ecr:StartImageScan",
          "ecr:DescribeImageReplicationStatus",
          "ecr:ListTagsForResource",
          "ecr:UploadLayerPart",
          "ecr:BatchDeleteImage",
          "ecr:ListImages",
          "ecr:BatchGetRepositoryScanningConfiguration",
          "ecr:DeleteRepository",
          "ecr:CompleteLayerUpload",
          "ecr:TagResource",
          "ecr:DescribeRepositories",
          "ecr:BatchCheckLayerAvailability",
          "ecr:ReplicateImage",
          "ecr:GetLifecyclePolicy",
          "ecr:PutLifecyclePolicy",
          "ecr:DescribeImageScanFindings",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:PutImageScanningConfiguration",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DeleteLifecyclePolicy",
          "ecr:PutImage",
          "ecr:UntagResource",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:StartLifecyclePolicyPreview",
          "ecr:InitiateLayerUpload",
          "ecr:GetRepositoryPolicy"
        ],
        Resource = [
          "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/*",
        ]
      },
      {
        Sid    = "VisualEditor1",
        Effect = "Allow",
        Action = [
          "ecr:DescribeRepositoryCreationTemplate",
          "ecr:GetRegistryPolicy",
          "ecr:CreateRepository",
          "ecr:DescribeRegistry",
          "ecr:DescribePullThroughCacheRules",
          "ecr:GetAuthorizationToken",
          "ecr:PutRegistryScanningConfiguration",
          "ecr:CreatePullThroughCacheRule",
          "ecr:DeletePullThroughCacheRule",
          "ecr:GetRegistryScanningConfiguration",
          "ecr:ValidatePullThroughCacheRule",
          "ecr:CreateRepositoryCreationTemplate",
          "ecr:BatchImportUpstreamImage",
          "ecr:DeleteRepositoryCreationTemplate",
          "ecr:UpdatePullThroughCacheRule",
          "ecr:PutReplicationConfiguration"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ssm_read_only_github_actions" {
  role       = aws_iam_role.github_actions_ecr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "finalproject_ecr_read_write" {
  role       = aws_iam_role.github_actions_ecr.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}