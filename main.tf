# Github actions self-hosted runners
# Creates managed instance group of VMs based on the runner image
# created with Packer using github-actions-runner.json
# Images are created and timestamped automatically when changes are commited to main
# and changes are made by updating random_pet.template.keepers.image in this file

locals {
  # Increment to trigger managed instance group replacement for the same vm image
  iteration = "1"
  # Labels should be comma-separated, no spaces
  runner_labels = replace(join(",", concat(var.runner_labels, [var.team])), " ", "")
}

# Get available zones
data "google_compute_zones" "available" {
  region = var.region
}

# Random generator to trigger template and instance group replacement
resource "random_pet" "template" {
  keepers = {
    "disk_size_gb"      = var.disk_size_gb
    "image"             = var.image,
    "machine_type"      = var.machine_type
    "iteration"         = local.iteration
    "runner_labels"     = local.runner_labels
    "scaling_schedules" = md5(jsonencode(var.scaling_schedules))
  }
}

# Runner instance template
resource "google_compute_instance_template" "runner" {
  name                 = "${var.team}-gha-template-${random_pet.template.id}"
  description          = "This template is used to create github actions runner instances."
  instance_description = "Github actions runner"
  machine_type         = var.machine_type
  can_ip_forward       = false
  # dynamically add labels to the runner by adding a comma-separated list to the file below
  metadata_startup_script = "echo 'ADDITIONAL_LABELS=${var.machine_type},${local.runner_labels}' > /home/runner/env; chmod 755 /home/runner/env"
  tags                    = concat(["github-actions-runner"], var.runner_labels)
  labels = merge(
    var.gce_instance_labels,
    {
      team = var.team
      role = "github-actions-runner"
    }
  )

  scheduling {
    automatic_restart   = !var.preemptible
    on_host_maintenance = var.preemptible ? "TERMINATE" : "MIGRATE"
    preemptible         = var.preemptible
  }

  disk {
    source_image = random_pet.template.keepers.image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.disk_size_gb
  }

  network_interface {
    network = var.network
  }

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Runner instance group manager
resource "google_compute_region_instance_group_manager" "runner" {
  name                      = "${var.team}-gha-igm-${random_pet.template.id}"
  base_instance_name        = "${var.team}-github-actions-runner-${random_pet.template.id}"
  distribution_policy_zones = data.google_compute_zones.available.names
  region                    = var.region

  version {
    instance_template = google_compute_instance_template.runner.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_autoscaler" "default" {
  provider = google-beta

  name   = "${var.team}-gha-autoscaler-${random_pet.template.id}"
  target = google_compute_region_instance_group_manager.runner.id
  region = var.region

  autoscaling_policy {
    # cap replicas at 100
    max_replicas = min(var.autoscale_max_replicas, 100)
    min_replicas = max(var.autoscale_min_replicas, 1)
    # 2 minutes in seconds
    cooldown_period = 120

    dynamic "scaling_schedules" {
      for_each = { for v in var.scaling_schedules : v.name => v }
      iterator = this

      content {
        name                  = this.value.name
        min_required_replicas = var.autoscale_max_replicas
        duration_sec          = this.value.duration_hours * 60 * 60
        schedule              = this.value.cron_trigger
        time_zone             = var.time_zone
      }
    }

    dynamic "cpu_utilization" {
      for_each = length(var.scaling_schedules) > 0 ? [] : [1]

      content {
        target = var.autoscale_cpu_threshold / 100
      }
    }
  }
}