# This resource clones the Tntk Final Project 2.0 repos into our newly created GitHub Repositories
resource "null_resource" "repo_clone" {
  for_each = {
    for key, value in var.repositories : key => value
    if value.clone_url != null
  }

  triggers = {
    repo_id = github_repository.repos[each.key].id
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -x
      echo "Cloning ${each.value.clone_url} into ${each.key}"
      git clone --mirror ${each.value.clone_url}.git temp_${each.key}
      cd temp_${each.key}
      # Only try to delete pull refs if they exist
      if git show-ref --verify --quiet refs/pull/; then
        git for-each-ref --format='%(refname)' refs/pull/ | xargs -n 1 git update-ref -d
      fi
      git remote set-url origin https://github.com/${var.github_organization}/${each.key}.git
      git config http.postBuffer 524288000
      git push --mirror
      cd ..
      rm -rf temp_${each.key}
    EOT
  }
}