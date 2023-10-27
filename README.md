# ArgoCD Application Set

This module creates an applicationSet in an ArgoCD instance.

## Config schema for ApplicationSet

Required fields:

```yaml
values: |
  # Here you can define the values for the chart
```

Optional fields:

```yaml
namespace_overwrite: <namespace>      # e.g. default (default: generated based on the project name + git folder name). Must be set if more than one environment is deployed in the same cluster.
chart:
  repo: <chart_repo_url>               # e.g. registry.hub.docker.com/tagesspiegel
  name: <chart_name>                   # e.g. background
  version: <chart_version>             # e.g. 1.0.0
  release_name: <chart_release_name>   # e.g. background-develop
```

## Usage

```hcl
provider "argocd" {
  server_addr = "argo.example.com"
  auth_token  = "my-token"
  grpc_web    = true
}

module "namespace-management" {
  source  = "tagesspiegel/application-set/argocd"
  version = "1.0.0"
  # insert the required variable here
}
```

## Cluster selection

The cluster selection is based on the ``

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_argocd"></a> [argocd](#requirement\_argocd) | 6.0.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_argocd"></a> [argocd](#provider\_argocd) | 6.0.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [argocd_application_set.this](https://registry.terraform.io/providers/oboukili/argocd/6.0.3/docs/resources/application_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Annotations to apply to the application set | `map(string)` | `{}` | no |
| <a name="input_application_name_suffix"></a> [application\_name\_suffix](#input\_application\_name\_suffix) | Optional suffix to add to the application name. This is useful if you want to deploy the same application multiple times to the same cluster. The suffix is added to the application name after the cluster name. e.g. prometheus-staging-<suffix>. ArgoCD based gotemplating is supported. e.g. {{ index .path.segments 2 }} | `string` | `null` | no |
| <a name="input_env_context_annotations"></a> [env\_context\_annotations](#input\_env\_context\_annotations) | A map of annotations that are rendered via go template. Available variables are cluster, resourceName and applicationName. You can access the variables using go templating. e.g. {{ $cluster }}, {{ $resourceName }}, {{ $applicationName }} | `map(string)` | `{}` | no |
| <a name="input_generator"></a> [generator](#input\_generator) | The generator configuration. Only one generator can be used at a time. | <pre>object({<br>    git = optional(object({<br>      repo_url = string<br>      revision = string<br>      files    = optional(list(string))<br>      directories = optional(list(object({<br>        path    = string<br>        exclude = bool<br>      })))<br>    }))<br>    pull_request = optional(list(object({<br>      requeue_after_seconds = number<br>      repo                  = string<br>      labels                = list(string)<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_generator_segment_index_overwrite"></a> [generator\_segment\_index\_overwrite](#input\_generator\_segment\_index\_overwrite) | Optional generator setting to override the index path segment during path selection. This option should only be set if generator.git.directories is used. Otherwise it should be left empty as it may affect the behavior. If this option is set in combination with generator.git.directories and your repository contains the cluster folder name in its root directory, this option should be set to 0. In all other cases, this option should reflect the index segment level to the directory corresponding to the cluster name. | `number` | `null` | no |
| <a name="input_ignore_difference"></a> [ignore\_difference](#input\_ignore\_difference) | A list of object kinds to ignore during the diff process. This is useful if you want to ignore certain differences between the application set and the cluster. e.g. if you want to ignore differences in the namespace labels. | <pre>list(object({<br>    group               = optional(string)<br>    jq_path_expressions = optional(list(string))<br>    json_pointers       = optional(list(string))<br>    kind                = optional(string)<br>    name                = optional(string)<br>    namespace           = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the application set | `map(string)` | `{}` | no |
| <a name="input_manifest_source"></a> [manifest\_source](#input\_manifest\_source) | n/a | <pre>object({<br>    helm = optional(object({<br>      chart           = string<br>      repo_url        = string<br>      target_revision = string<br>      release_name    = string<br>    }))<br>    directory = optional(object({<br>      repo = object({<br>        url      = string<br>        revision = string<br>        path     = string<br>      })<br>      glob_path = optional(string)<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the application set | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace the application set should be deployed to. | `string` | `"argo-system"` | no |
| <a name="input_namespace_annotations"></a> [namespace\_annotations](#input\_namespace\_annotations) | Annotations to apply to the namespace. Only used if create\_namespace is set to true. | `map(string)` | `{}` | no |
| <a name="input_namespace_labels"></a> [namespace\_labels](#input\_namespace\_labels) | Labels to apply to the namespace. Only used if sync\_options.* CreateNamespace=true is set. | `map(string)` | `{}` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the ArgoCD project to use for this application set. If not set, this application set is special. Special application sets are managed by the platform team and therefore the ArgoCD project reference is handled differently to normal application sets. A major difference is that the ArgoCD project is not statically defined as reference but dynamically via the config directory name. | `string` | n/a | yes |
| <a name="input_sync_options"></a> [sync\_options](#input\_sync\_options) | The sync options to use | `list(string)` | <pre>[<br>  "Validate=false",<br>  "ApplyOutOfSyncOnly=true",<br>  "CreateNamespace=true"<br>]</pre> | no |
| <a name="input_sync_policy"></a> [sync\_policy](#input\_sync\_policy) | ArgoCD sync policy configuration | <pre>object({<br>    prune       = bool<br>    self_heal   = bool<br>    allow_empty = bool<br>  })</pre> | `null` | no |
| <a name="input_sync_retries"></a> [sync\_retries](#input\_sync\_retries) | The retry configuration for the sync policy | <pre>object({<br>    duration     = string<br>    max_duration = string<br>    factor       = number<br>    limit        = number<br>  })</pre> | <pre>{<br>  "duration": "30s",<br>  "factor": 2,<br>  "limit": 5,<br>  "max_duration": "2m"<br>}</pre> | no |
| <a name="input_target_namespace_overwrite"></a> [target\_namespace\_overwrite](#input\_target\_namespace\_overwrite) | The target namespace to use. If not set, the namespace is derived from the application set and git folder name. | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
