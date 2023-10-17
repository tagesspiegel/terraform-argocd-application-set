module "example" {
  source = "../"

  name = "example"
  project_name = "example"
  generator = {
    git = {
      repo_url = "https://github.com/urbanmedia/example-deployment.git"
      revision = "main"
      files = [
        "argo/*/*/example.yaml"
      ]
    }
  }
  manifest_source = {
    helm = {
      chart = "example"
      release_name = "example"
      repo_url = "ghcr.io/urbanmedia/example-deployment"
      target_revision = "1.1.16"
    }
  }
  generator_segment_index_overwrite = 1
  application_name_suffix = "{{ index .path.segments 2 }}"
  annotations = {
    "argocd.argoproj.io/sync-wave" = "2",
  }
  sync_options = [
    "Validate=false",
    "ApplyOutOfSyncOnly=true",
  ]
  sync_policy = {
    prune       = true
    self_heal   = true
    allow_empty = true
  }
}
