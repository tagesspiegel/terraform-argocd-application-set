variable "name" {
  type        = string
  description = "The name of the application set"
}

variable "namespace" {
  type        = string
  description = "The namespace the application set should be deployed to."
  default     = "argo-system"
}

variable "project_name" {
  type        = string
  description = "The name of the ArgoCD project to use for this application set. If not set, this application set is special. Special application sets are managed by the platform team and therefore the ArgoCD project reference is handled differently to normal application sets. A major difference is that the ArgoCD project is not statically defined as reference but dynamically via the config directory name."
  validation {
    condition     = length(var.project_name) > 0
    error_message = "project_name must be set"
  }
}

variable "annotations" {
  type        = map(string)
  description = "Annotations to apply to the application set"
  default     = {}
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the application set"
  default     = {}
}

variable "manifest_source" {
  type = object({
    helm = optional(object({
      chart           = string
      repo_url        = string
      target_revision = string
      release_name    = string
    }))
    directory = optional(object({
      repo = object({
        url      = string
        revision = string
        path     = string
      })
      glob_path = optional(string)
    }))
  })

  validation {
    condition     = var.manifest_source.helm != null ? var.manifest_source.directory == null : true
    error_message = "Only one manifest source can be used at a time. Either helm or directory."
  }
}

variable "sync_retries" {
  type = object({
    duration     = string
    max_duration = string
    factor       = number
    limit        = number
  })
  description = "The retry configuration for the sync policy"
  default = {
    duration     = "30s"
    max_duration = "2m"
    factor       = 2
    limit        = 5
  }
  validation {
    condition     = can(regex("^[0-9]+[smh]$", var.sync_retries.duration))
    error_message = "sync_retries.duration must be a string in the format of <number><s|m|h>"
  }
  validation {
    condition     = can(regex("^[0-9]+[smh]$", var.sync_retries.max_duration))
    error_message = "sync_retries.max_duration must be a string in the format of <number><s|m|h>"
  }
}

variable "sync_options" {
  type        = list(string)
  description = "The sync options to use"
  default     = ["Validate=false", "ApplyOutOfSyncOnly=true", "CreateNamespace=true"]
}

variable "namespace_labels" {
  type        = map(string)
  description = "Labels to apply to the namespace. Only used if sync_options.* CreateNamespace=true is set."
  default     = {}
}

variable "namespace_annotations" {
  type        = map(string)
  description = "Annotations to apply to the namespace. Only used if create_namespace is set to true."
  default     = {}
}

variable "generator" {
  type = object({
    git = optional(object({
      repo_url = string
      revision = string
      files    = optional(list(string))
      directories = optional(list(object({
        path    = string
        exclude = bool
      })))
    }))
    pull_request = optional(list(object({
      requeue_after_seconds = number
      repo                  = string
      labels                = list(string)
    })))
  })
  description = "The generator configuration. Only one generator can be used at a time."
  validation {
    condition     = var.generator.git != null ? var.generator.pull_request == null : true
    error_message = "Only one generator can be used at a time. Either git or pull_request."
  }
  validation {
    condition     = var.generator.git != null ? var.generator.git.files != null ? var.generator.git.directories == null : true : true
    error_message = "Only one of git.files or git.directories can be used at a time."
  }
  validation {
    condition     = var.generator.pull_request != null ? length(var.generator.pull_request) > 0 : true
    error_message = "At least one pull_request generator must be defined."
  }
}

variable "target_namespace_overwrite" {
  type        = string
  description = "The target namespace to use. If not set, the namespace is derived from the application set and git folder name."
  default     = ""
}

variable "generator_segment_index_overwrite" {
  type        = number
  description = "Optional generator setting to override the index path segment during path selection. This option should only be set if generator.git.directories is used. Otherwise it should be left empty as it may affect the behavior. If this option is set in combination with generator.git.directories and your repository contains the cluster folder name in its root directory, this option should be set to 0. In all other cases, this option should reflect the index segment level to the directory corresponding to the cluster name."
  default     = null
}

variable "application_name_suffix" {
  type        = string
  description = "Optional suffix to add to the application name. This is useful if you want to deploy the same application multiple times to the same cluster. The suffix is added to the application name after the cluster name. e.g. prometheus-staging-<suffix>. ArgoCD based gotemplating is supported. e.g. {{ index .path.segments 2 }}"
  default     = null
}

variable "sync_policy" {
  type = object({
    prune       = bool
    self_heal   = bool
    allow_empty = bool
  })
  description = "ArgoCD sync policy configuration"
  default     = null
}

variable "ignore_difference" {
  type = list(object({
    group               = optional(string)
    jq_path_expressions = optional(list(string))
    json_pointers       = optional(list(string))
    kind                = optional(string)
    name                = optional(string)
    namespace           = optional(string)
  }))
  description = "A list of object kinds to ignore during the diff process. This is useful if you want to ignore certain differences between the application set and the cluster. e.g. if you want to ignore differences in the namespace labels."
  default     = []
}
