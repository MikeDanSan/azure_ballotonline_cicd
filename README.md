# BallotOnline Azure PoC

Welcome to the `azure_ballotonline_cicd` repository! This project is a capstone demonstration of implementing Continuous Integration and Continuous Deployment (CI/CD) pipelines using Azure services.

BallotOnline is a fictional company created for the purpose of this proof of concept. The goal of this project is to showcase the integration and deployment of both Infrastructure as a Service (IaaS) and Platform as a Service (PaaS) on Azure.

Within this repository, you'll find:
- Infrastructure as Code (IaC) scripts to provision Azure resources.
- Source code for the web application.
- Configuration files and scripts for the CI/CD pipeline.
- Documentation to guide you through the setup and deployment process.

This project highlights best practices for deploying and managing cloud resources in a modern DevOps environment, aiming to provide a comprehensive understanding of Azure's capabilities in supporting robust CI/CD workflows.

### Terraform

Terraform is an open-source Infrastructure as Code (IaC) tool developed by HashiCorp. It allows users to define and provision data center infrastructure using a high-level configuration language. Terraform manages external resources (such as public cloud infrastructure, private cloud infrastructure, and service providers) with a single, consistent workflow. It enables the safe and efficient building, change, and versioning of infrastructure, simplifying the deployment and scaling of infrastructure.

In this project we will be using the Azure CLI with Terraform, but there are other options and we will not be exploring those at this time. Here is a link to the Terraform Azure Provider [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).

### Azure Command Line Interface (CLI)

Azure CLI is a command-line tool provided by Microsoft that allows users to manage Azure resources and services. It enables the automation of various tasks through simple, text-based commands, and supports multiple operating systems, including Windows, macOS, and Linux. With Azure CLI, users can efficiently create, modify, and manage Azure resources from a terminal or command prompt.


## Prerequisites

Here you will find required accounts,software,etc. to be able to run the project yourself.

- Azure subscription
- Azure CLI
- Terraform

## Proof of Concept (PoC) Examples

> Each Poc example aligns with a specific folder.

### Azure Virtual Machine with Nginx configured

This example can be found in the `tf_bo_nginx_webserver` directory.

In this PoC terraform is used to create a linux vm that installs and configures nginx using custom and user data to automate everything.

In the next example the Azure machine image (AMI) is created based on the virutal machine created in this example PoC.

### Azure Virtual Machine Scale Set with Load Balancer

***IMPORTANT***: The Azure machine image (AMI) was created from the example above `tf_bo_nginx_webserver`

This example can be found in the `tf_bo_nginx_scaleset` directory.

In this PoC terrform is used to create a scale set of the AMI BallotOnline Web Server to create two replicas with a load balancer. 

### Azure Web Application Service

This example can be found in the `tf_bo_web_app_srv` directory.


## Common Usage instructions

1. Log into your Azure account through Azure CLI.
    > Choose your preferred method.

2. Change directory to the Poc you want to use

    ```bash
    cd [specify_PoC_dir]
    ```

3. (Optional) Use terraform plan and validate 

    ```bash
    # Optional format terraform
    terraform fmt

    terraform plan
    ```
4. Use terraform apply to create resources

    ```bash
    # Optional: -auto-approve (skips approval)
    terraform apply
    ```