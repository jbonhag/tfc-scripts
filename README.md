# Terraform Cloud Scripts

> Note: These scripts are under active development, subject to change, and not
> officially supported by HashiCorp.

## Bulk Move Workspaces

This script is made up of two parts:

1. a Terraform config to fetch a set of workspaces and write them to a local
   file
2. a script to bulk move those workspaces to the specified project

In `main.tf`, Update the `tfe_workspace_ids` data source to select a list of
workspaces you want to move to the project. Refer to the [workspace_ids argument reference](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/workspace_ids#argument-reference)
for possible workspace filters.

```hcl
data "tfe_workspace_ids" "this" {
  organization = var.organization
  names        = ["*app*"]
}
```

Set the local environment variable `TFE_TOKEN` to a Terraform Cloud token with
sufficent access to move workspaces from their source project(s) to the
destination project. Run `terraform apply`. You will be prompted for an
organization name and a project name.

The Terraform run will create the new project and write a list of workspace
ids matching the filter to a file called `workspace_ids.txt`.

It will then call `move-workspaces` to move all the workspaces to the newly
created project.

If you want to move another set of workspaces, simply delete the
`terraform.tfstate`, update the workspaces filter and run `terraform apply`
again.

### Example Output

```
$ TFE_TOKEN=abcdf terraform apply
var.organization
  Enter a value: jbonhag

var.project_name
  Enter a value: cool-apps

data.tfe_workspace_ids.this: Reading...
data.tfe_workspace_ids.this: Read complete after 1s [id=jbonhag/1857849518]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.this will be created
  + resource "local_file" "this" {
      + content              = <<-EOT
            jbonhag/another-app
            jbonhag/my-app
            jbonhag/terraform-workspace-simple-app
        EOT
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./workspaces.txt"
      + id                   = (known after apply)
    }

  # tfe_project.this will be created
  + resource "tfe_project" "this" {
      + id           = (known after apply)
      + name         = "cool-apps"
      + organization = "jbonhag"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + project_id = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

tfe_project.this: Creating...
tfe_project.this: Creation complete after 1s [id=prj-ZETwvxPcyjQLYCqD]
local_file.this: Creating...
local_file.this: Provisioning with 'local-exec'...
local_file.this (local-exec): Executing: ["/bin/sh" "-c" "./move-workspaces prj-ZETwvxPcyjQLYCqD"]
local_file.this (local-exec): Workspace jbonhag/another-app was moved.
local_file.this (local-exec): Workspace jbonhag/my-app was moved.
local_file.this (local-exec): Workspace jbonhag/terraform-workspace-simple-app was moved.
local_file.this (local-exec): Success! 3 workspaces moved.
local_file.this: Creation complete after 1s [id=abfd091d9c7410264eb03224d7961b22c057c5f6]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

project_id = "prj-ZETwvxPcyjQLYCqD"
```
