variable "autoscale_max_replicas" {
  description = "Max VM count"
  type        = number
  default     = 3
}

variable "autoscale_min_replicas" {
  description = "Min VM count"
  type        = number
  default     = 3
}

variable "autoscale_cpu_threshold" {
  description = "CPU usage percentage threshold to trigger autoscaling"
  type        = number
  default     = 50
}

variable "disk_size_gb" {
  description = "Runner VM disk size"
  type        = number
  default     = 50
}

variable "gce_instance_labels" {
  description = "Additional labels"
  type        = map(string)
  default     = {}
}

variable "image" {
  description = "GCE Image to deploy runners with"
  type        = string
}

variable "machine_type" {
  description = "GCE Machine type to use for runners"
  type        = string
  default     = "e2-highmem-4"
}

variable "network" {
  description = "Network to deploy the instance group in"
  type        = string
}

variable "preemptible" {
  description = "Make VMs preemptible"
  type        = bool
}

variable "runner_labels" {
  description = "Additional labels to pass the runner and VM network tags"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "repositories" {
  description = "List of repositories allowed to use these runners"
  type        = list(string)
  default     = []
}

variable "scaling_schedules" {
  description = "Use a pre-determined scaling schedule instead of metric-based autoscaling"
  type = list(
    object({
      # Cron schedule that will trigger a scaling event
      cron_trigger = string
      # Number of hours to keep autoscaled VMs up for
      duration_hours = number
      # schedule name
      name = string
    })
  )
  default = []
}

variable "service_account" {
  description = "Runner service account"
  type        = string
}

variable "team" {
  description = "Team name"
  type        = string
}

variable "time_zone" {
  description = "Time Zone"
  type        = string
  default     = "America/Vancouver"
}