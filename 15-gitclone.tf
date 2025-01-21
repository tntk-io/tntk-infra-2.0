# This resource clones the Tntk Final Project 2.0 repos into our newly created GitHub Repositories
resource "null_resource" "repo_clone" {
  for_each = {
    for key, value in var.repositories : key => value
    if value.clone_url != null
  }

  depends_on = [github_repository.repos]

  provisioner "local-exec" {
    command = <<-EOT
      git clone --mirror ${each.value.clone_url}.git temp_${each.key}
      cd temp_${each.key}
      git remote set-url origin https://github.com/${var.github_organization}/${each.key}.git
      git push --mirror
      cd ..
      rm -rf temp_${each.key}
    EOT
  }
}