locals {
  cluster_identifier = var.generator_segment_index_overwrite == null ? ".path.basenameNormalized" : "(index .path.segments ${var.generator_segment_index_overwrite})"
  resource_name      = "${local.cluster_identifier}${var.application_name_suffix != "" ? "-${var.application_name_suffix}" : ""}"
}

resource "argocd_application_set" "this" {
  metadata {
    name      = "${var.project_name}-${var.name}"
    namespace = var.namespace
  }

  spec {
    go_template = true

    generator {
      // if the git block is not null, then we want to add it to the generator
      dynamic "git" {
        for_each = var.generator.git != null ? [var.generator.git] : []
        content {
          repo_url = var.generator.git.repo_url
          revision = var.generator.git.revision
          dynamic "file" {
            for_each = var.generator.git.files != null ? var.generator.git.files : []
            content {
              path = file.value
            }
          }
          dynamic "directory" {
            for_each = var.generator.git.directories != null ? var.generator.git.directories : []
            content {
              path    = directory.value.path
              exclude = directory.value.exclude
            }
          }
        }
      }

      // if the github block is not null, then we want to add it to the generator
      dynamic "pull_request" {
        for_each = var.generator.pull_request != null ? var.generator.pull_request : []
        content {
          requeue_after_seconds = pull_request.value.requeue_after_seconds
          github {
            owner  = "urbanmedia"
            repo   = pull_request.value.repo
            labels = pull_request.value.labels
          }
        }
      }
    }

    template {
      metadata {
        // application names are in the format: <name>-<cluster>
        // e.g. prometheus-staging
        name = "${var.name}-{{ ${local.resource_name} }}"
        annotations = merge(
          var.annotations,
          {
            "managed-by"      = "argo-cd",
            "application-set" = var.name
          },
        )
        labels = merge(
          var.labels,
          {
            "managed-by"      = "argo-cd",
            "application-set" = var.name
          },
        )
      }

      spec {
        project = var.project_name

        // TODO(@tagesspiegel/platform-engineers): We want to add the sync block here so we can support progressive syncs
        // See: https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Progressive-Syncs/

        dynamic "source" {
          for_each = var.manifest_source.helm != null ? ["abc"] : []
          content {
            chart           = "{{ default \"${var.manifest_source.helm.chart}\" .chart.name }}"
            repo_url        = "{{ default \"${var.manifest_source.helm.repo_url}\" .chart.repo }}"
            target_revision = "{{ default \"${var.manifest_source.helm.target_revision}\" .chart.version }}"
            helm {
              release_name = "{{ default \"${var.manifest_source.helm.release_name}\" .chart.release_name }}"
              values       = "{{ .values }}"
            }
          }
        }
        dynamic "source" {
          for_each = var.manifest_source.directory != null ? ["abc"] : []
          content {
            repo_url        = var.manifest_source.directory.repo.url
            target_revision = var.manifest_source.directory.repo.revision
            path            = var.manifest_source.directory.repo.path
            directory {
              include = var.manifest_source.directory.glob_path
              recurse = true
            }
          }
        }

        destination {
          name = "{{ if (eq ${local.cluster_identifier} \"general-purpose\") }}in-cluster{{ else }}{{ ${local.cluster_identifier} }}{{ end }}"
          // if the target_namespace_overwrite is not empty, then we want to use it as the namespace
          // (e.g. ingress-controllers (assuming "ingress-controllers" is the target_namespace_overwrite))
          // otherwise we check if the configuration provided by the developer has a namespace_overwrite
          // if the namespace_overwrite is not set, then we use the namespace based on the project name and git folder name
          // (e.g. background-staging (assuming "background" is the project and "staging" the folder name))
          // otherwise we use the namespace_overwrite provided by the developer
          // (e.g. background-staging-v2 (assuming "background" is the project and "staging-v2" the namespace_overwrite))
          namespace = var.target_namespace_overwrite != "" ? var.target_namespace_overwrite : "{{ if not .namespace_overwrite }}${var.project_name}-{{ ${local.resource_name} }}{{ else }}${var.project_name}-{{ .namespace_overwrite }}{{ end }}"
        }
        sync_policy {
          dynamic "automated" {
            for_each = var.sync_policy != null ? [var.sync_policy] : []
            content {
              prune       = var.sync_policy.prune
              self_heal   = var.sync_policy.self_heal
              allow_empty = var.sync_policy.allow_empty
            }
          }
          managed_namespace_metadata {
            annotations = merge(
              var.namespace_annotations,
              {
                "managed-by" = "argo-cd"
              },
            )
            labels = merge(
              var.namespace_labels,
              {
                "managed-by" = "argo-cd"
              },
            )
          }
          # Only available from ArgoCD 1.5.0 onwards
          sync_options = var.sync_options
          retry {
            limit = var.sync_retries.limit
            backoff {
              duration     = var.sync_retries.duration
              max_duration = var.sync_retries.max_duration
              factor       = var.sync_retries.factor
            }
          }
        }
      }
    }
  }
}
