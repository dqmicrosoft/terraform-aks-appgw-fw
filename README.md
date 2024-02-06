# Terraform AKS, AppGW, Firewall, Deployment

This project deploys an environment with AKS with AGIC on a vnet, and App Gateway and Azure Firewall in another one using Terraform.

## Prerequisites

- Azure account
- Azure CLI installed
- Terraform installed

## Steps

1. **Create Azure Containers**

   Open your terminal and run the following commands to create four containers in your Azure account:

   ```bash
   az storage container create --name container1
   az storage container create --name container2
   az storage container create --name container3
   az storage container create --name container4
   ```
These containers are for storing the state of the terraform of each folder. So you must create one for each.
They will need to pull outputs from each other.

## Terraform Deployment Order

To deploy the infrastructure, follow the below order:

1. Netcore Folder: Run `terraform apply` in the `netcore` folder.
2. Core Folder: Run `terraform apply` in the `core` folder.
3. Firewall Folder: Run `terraform apply` in the `firewall`.
4. AKS Folder: Run `terraform apply` in the `aks` folder..

Make sure to wait for each deployment to complete before moving on to the next folder.

## Usage

1. Clone this repository:

    ```bash
    git clone https://github.com/your-username/your-repo.git
    ```

2. Change into the cloned directory:

    ```bash
    cd your-repo
    ```

3. Follow the deployment order mentioned above.

## Cleanup

To clean up the deployed resources, run `terraform destroy` in each folder in reverse order.

## License

This project is licensed under the [MIT License](LICENSE).
