# terraform-module-template

A template repository to provide a basic setup for Terraform modules.

## Module structure

The module structure is based on the [Terraform module documentation](https://www.terraform.io/docs/modules/index.html#standard-module-structure). The following tree shows the structure of the module.

```txt
├── .gitignore
├── LICENSE
├── README.md
├── docs
│ └── README.md
├── examples
│ ├── complete
│ │ ├── main.tf
│ │ ├── outputs.tf
│ │ ├── variables.tf
│ │ └── versions.tf
│ ├── minimal
│ │ ├── main.tf
│ │ ├── outputs.tf
│ │ ├── variables.tf
│ │ └── versions.tf
├── main.tf
├── outputs.tf
├── variables.tf
└── versions.tf
```

## Working with this template

In order to use this template, you can use the GitHub template feature. This will create a new repository based on this template. After that, you can clone the repository and start working on it.

### Creating a new repository based on this template

To get started with this template, you have to navigate https://github.com/new and select the Tagesspiegel organization. After that, you can select the `terraform-module-template` repository, enter a name for your new repository and click on `Create repository`. Please note that you have to define a name for your new repository that is not already taken and follows the naming conventions (`terraform-<provider>-<name>`).

![Create GitHub repository based on template](docs/github_create_repository.png)

If everything worked as expected, you should now have a new repository based on this template. You can now clone the repository and start working on it.
