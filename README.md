## Terraform Workspaces

Workspaces in terraform are a great way to use the same code but with different values for your variables, this is a simple example to show they work. Two workspaces are created in this example, created the workspace is straight forward, in the folder where your terraform code is at the cli, the commands to type are

terraform workspace new "name of the workspace"
 eg terraform workspace new prod  - creates the workspace prod

In this example we are using the two workspaces "dev" and "prod"

Once created the workspaces can be viewed using the following command

terraform workspace list

The workspace that is currently being used will have an asterisk against it. To move between the workspaces a select command must be used

terraform workspace select "workspace to be selected"
 eg terraform workspace select dev  - moves to the workspace dev

 The example creates a Resource Group, Virtual Network, Subnet, Appropriate Number of Interfaces and the Appropriate Number of Virtual Machines

### Variables 

To pass in variables for this example a locals block was created and objects created that contain multiple values

<pre><code>
locals {
  #fills the variable env with the currently used workspace  
  env = terraform.workspace

  #fills the variable counts with the two possible answers for count  
  counts = {
    "dev"   = 1
    "prod"  = 2
  }

  #fills the variable locations with the two possible answers for count  
  locations = {
    "dev"   = "uksouth"
    "prod"  = "westeurope"
  }

  #looks up the relevant values and fills the count and location variable depending on the value of the variable env  
  count    = "${lookup(local.counts, local.env)}"
  location = "${lookup(local.locations, local.env)}"
}

</code></pre>

### Running the code

A tip here is that you don't need to initialise more than once, the .terraform folder will be available for all workspaces.

To run the code to create the two different environments

1. terraform init                   # initialise the project
2. terraform workspace new dev      # create the dev workspace 
3. terraform workspace new prod     # create the prod workspace
4. terraform workspace select dev   # move into the dev workspace
5. terraform plan                   # run plan
6. terraform apply                  # apply the code
7. terraform workspace select prod  # move into the prod workspace
8. terraform plan                   # run plan
9. terraform apply                  # apply the code

Two resource groups will be created and teh appropriate number of machines built into the RG, in the different locations

terraform.tfstate is kept for both workspaces in a sub folder of the project called terraform.tfstate.d, in this folder is a folder for each workspace with the state and backup files in.

### Destroying the resources.

Exactly like actioning the build, you will have to enter each workspace in turn and run the destroy command.

