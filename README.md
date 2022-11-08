# Github Actions Self-hosted Runners Module
This module simplifies the creation of managed instance VMs based on the runner image dedicated to a team/project


Example
```hcl
module "github-actions-runners" {
  source          = "git@github.com:dapperlabs-platform/terraform-github-actions-runners.git?ref=<latest-tag>"

  image           = "github-actions-runner-xyz"
  network         = "dedicated-github-actions-network"
  region          = "network-region"
  runner_count    = 10
  service_account = "serviceAccount:project-service-account@<gcp-project>.iam.gserviceaccount.com"
  labels = [
    "project-name"
  ]
}
```
## Resources created

- 1 GCE Managed Instance Group
- `runner_count` GCE instances

## Variables

| name          | description                                                                       |                                   type                                   | required |                     default                      |
| ------------- | --------------------------------------------------------------------------------- | :----------------------------------------------------------------------: | :------: | :----------------------------------------------: |
| autoscale_max_replicas            | Max amount of VMs to have                                                                     |                       number                       |         |                      3                            |
| autoscale_min_replicas    | Min amount of VMs to have                                                              |                       number                       |         |                   3                               |
| autoscale_cpu_threshold | CPU usage percentage threshold to trigger autoscaling                                        |                       number                       |          | 50 |
| disk_size_gb      | What size of disk to configure VM with                                   |                       number                       |          |          50            |
| gce_instance_labels         | Additional labels to be added to the VMs                                       | map(string) |          |             {}             |
| image        | Name of the image to create the VM from                                       | string |     ✓     |                          |
| machine_type      | GCE Machine type to use for runners                                            |           string           |          |             e2-highmem-4             |
| network    | Network to deploy the instance group in |                       string                       |     ✓     |                            |
| preemptible    | Make VMs preemptible |                       bool                       |     ✓     |                            |
| runner_labels    | Additional labels to pass the runner and VM network tags |                       list(string)                       |          |                            |
| region    | GCP region for the VM to be created in |                       string                       |     ✓     |                            |
| repositories    | List of repositories allowed to use these runners |                       list(string)                       |     ✓     |                            |
| scaling_schedules    | Use a pre-determined scaling schedule instead of metric-based autoscaling |                       list(object({cron_trigger = string duration_hours = number name = string })|          |              []              |
| service_account    | Runner Service account to use |                       string                       |     ✓     |                            |
| team    | Team name to use |                       string                       |     ✓     |                            |
| time_zone    | Time zone to use for schedules |                       string                       |          |             "America/Vancouver"               |