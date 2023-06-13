# tf-destroy-state-test
Testing how latest (2023_jun_13) Terraform cleans the state on destroy

# Idea

In one of the discussion that broke outside of work, person noted that `terraform destroy` removes  state file, while it is probably simply cleaning it. 


# Test 

- Created simple Terraform code 


```terraform
resource "random_string" "random" {
  length = 8
  special = true
  override_special = "/@£$"
  keepers = {
        timest = timestamp()
 }
}


output "random" {
 value = random_string.random.result
}
```


- `terraform init`

```bash
Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/random...
- Installing hashicorp/random v3.5.1...
- Installed hashicorp/random v3.5.1 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
...
````

- `terraform apply`

```bash
terraform apply --auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_string.random will be created
  + resource "random_string" "random" {
      + id               = (known after apply)
      + keepers          = {
          + "timest" = (known after apply)
        }
      + length           = 8
      + lower            = true
      + min_lower        = 0
      + min_numeric      = 0
      + min_special      = 0
      + min_upper        = 0
      + number           = true
      + numeric          = true
      + override_special = "/@£$"
      + result           = (known after apply)
      + special          = true
      + upper            = true
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + random = (known after apply)
random_string.random: Creating...
random_string.random: Creation complete after 0s [id=oKP9@4�g]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

random = "oKP9@4�g"
```

-- State file contesnts currently is : 

```json
{
  "version": 4,
  "terraform_version": "1.4.6",
  "serial": 12,
  "lineage": "ad7f294b-478b-14d9-8bd9-398418fd577a",
  "outputs": {
    "random": {
      "value": "oKP9@4�g",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "random_string",
      "name": "random",
      "provider": "provider[\"registry.terraform.io/hashicorp/random\"]",
      "instances": [
        {
          "schema_version": 2,
          "attributes": {
            "id": "oKP9@4\ufffdg",
            "keepers": {
              "timest": "2023-06-13T09:48:51Z"
            },
            "length": 8,
            "lower": true,
            "min_lower": 0,
            "min_numeric": 0,
            "min_special": 0,
            "min_upper": 0,
            "number": true,
            "numeric": true,
            "override_special": "/@£$",
            "result": "oKP9@4\ufffdg",
            "special": true,
            "upper": true
          },
          "sensitive_attributes": []
        }
      ]
    }
  ],
  "check_results": null
}
```

-- Perfoming destroy :

```bash
terraform destroy --auto-approve
random_string.random: Refreshing state... [id=oKP9@4�g]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # random_string.random will be destroyed
  - resource "random_string" "random" {
      - id               = "oKP9@4�g" -> null
      - keepers          = {
          - "timest" = "2023-06-13T09:48:51Z"
        } -> null
      - length           = 8 -> null
      - lower            = true -> null
      - min_lower        = 0 -> null
      - min_numeric      = 0 -> null
      - min_special      = 0 -> null
      - min_upper        = 0 -> null
      - number           = true -> null
      - numeric          = true -> null
      - override_special = "/@£$" -> null
      - result           = "oKP9@4�g" -> null
      - special          = true -> null
      - upper            = true -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  - random = "oKP9@4�g" -> null
random_string.random: Destroying... [id=oKP9@4�g]
random_string.random: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

- State file contents after destroy : 

```json
{
  "version": 4,
  "terraform_version": "1.4.6",
  "serial": 14,
  "lineage": "ad7f294b-478b-14d9-8bd9-398418fd577a",
  "outputs": {},
  "resources": [],
  "check_results": null
}
```

So yes, it's simply cleaned of resources.

