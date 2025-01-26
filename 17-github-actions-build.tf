# resource "null_resource" "trigger_build" {
#   depends_on = [
#     github_repository.repos,
#     github_actions_secret.secret,
#     github_actions_variable.variable,
#     null_resource.repo_clone,
#     helm_release.gha_actions_runner_controller,
#     helm_release.gha_actions_runner_scale_set,
#     aws_iam_role.github_actions_ecr,
#     aws_iam_role_policy_attachment.ssm_read_only_github_actions,
#     aws_iam_role_policy_attachment.finalproject_ecr_read_write,
#     aws_iam_openid_connect_provider.github_actions_oidc_provider
#   ]

#   for_each = {
#     for key, value in var.repositories : key => value
#     if value.clone_url != null
#   }

#   triggers = {
#     repo_name = each.key
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#       # Clone the repo
#       git clone https://github.com/${var.github_organization}/${self.triggers.repo_name}.git /tmp/${self.triggers.repo_name}
#       cd /tmp/${self.triggers.repo_name}

#       # Configure git
#       git config user.email "terraform@example.com"
#       git config user.name "Terraform"

#       # Make an empty commit and push to trigger GitHub Actions
#       git commit --allow-empty -m "Trigger initial build"
#       git push origin main

#       # Cleanup
#       cd ..
#       rm -rf /tmp/${self.triggers.repo_name}
#     EOT
#   }
# }
