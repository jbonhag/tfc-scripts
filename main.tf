terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.40.0"
    }
  }
}

provider "tfe" {
  # Configuration options
}

variable "organization" {
  type = string
}

variable "project_name" {
  type = string
}

resource "tfe_project" "this" {
  organization = var.organization
  name         = var.project_name
}

data "tfe_workspace_ids" "this" {
  organization = var.organization
  names        = ["*app*"]
}

resource "local_file" "this" {
  content = "${join("\n", [for workspace in data.tfe_workspace_ids.this.full_names : workspace])}\n"

  filename = "${path.module}/workspaces.txt"

  provisioner "local-exec" {
    command = "./move-workspaces ${tfe_project.this.id}"
  }
}

output "project_id" {
  value = tfe_project.this.id
}
