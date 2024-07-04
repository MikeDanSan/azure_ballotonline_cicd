/*
A terraform block is used in a Terraform configuration to specify the required version of Terraform and other global settings.
The required_providers block within it declares the providers needed for the configuration, ensuring Terraform downloads and uses 
the correct versions of these providers.
*/
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.110.0"
    }
  }
}

/*
The provider block in Terraform is used to configure settings for a specific provider, which is responsible for managing a set of resources. 
This block specifies the provider (e.g., AWS, Azure) and any necessary configuration options like authentication details and region settings.
*/
provider "azurerm" {
  features {}
}


/*
The resource block in Terraform defines a resource that Terraform will manage. In the case of azurerm_resource_group, 
it specifies an Azure Resource Group. This block includes the resource type (azurerm_resource_group), a name, and configuration 
options such as the name and location of the resource group. This tells Terraform to create and manage an Azure Resource Group with the 
specified settings.

Azure resource group: a logical container that holds related resources for an Azure solution. It provides a way to manage and organize 
resources such as virtual machines, storage accounts, and databases as a single entity, making it easier to deploy, monitor, 
and maintain the infrastructure.
*/
resource "azurerm_resource_group" "BallotOnline-rg" {
  name     = "BallotOnline-resources"
  location = "East Us"

  tags = {
    environment = "dev"
  }
}

/*
An Azure Virtual Network (VNet) is a network resource in Microsoft Azure that allows users to securely connect Azure resources and services. 
It acts as an isolated network within the Azure cloud, providing segmentation and control over network traffic. Users can define IP address ranges, 
subnets, route tables, and network security groups within the VNet, enabling customized network configurations tailored to specific application requirements.
*/
resource "azurerm_virtual_network" "BallotOnline-vn" {
  name                = "BallotOnline-network"
  resource_group_name = azurerm_resource_group.BallotOnline-rg.name
  location            = azurerm_resource_group.BallotOnline-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

/*
subnet is a subdivision of an Azure Virtual Network (VNet) that allows you to segment the network into smaller, manageable sections. 
Each subnet can contain a range of IP addresses and hosts specific resources, such as virtual machines. Subnets help organize and 
secure network traffic by isolating different parts of the application or service within the VNet.
*/
resource "azurerm_subnet" "BallotOnline-subnet" {
  name                 = "BallotOnline-subnet"
  resource_group_name  = azurerm_resource_group.BallotOnline-rg.name
  virtual_network_name = azurerm_virtual_network.BallotOnline-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

/*
A security group in Azure, known as a Network Security Group (NSG), is a set of security rules that control inbound and outbound network traffic 
to Azure resources. It acts as a virtual firewall, allowing or denying traffic based on factors like source and destination IP addresses, ports, and protocols. 
NSGs can be applied to individual network interfaces, virtual machines, and subnets to enhance security and manage access.
*/
resource "azurerm_network_security_group" "BallotOnline-sg" {
  name                = "BallotOnline-sg"
  location            = azurerm_resource_group.BallotOnline-rg.location
  resource_group_name = azurerm_resource_group.BallotOnline-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "BallotOnline-dev-nsr" {
  name                        = "BallotOnline-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.BallotOnline-rg.name
  network_security_group_name = azurerm_network_security_group.BallotOnline-sg.name
}

/*
A subnet network security group (NSG) association in Azure links a Network Security Group to a specific subnet within a Virtual Network (VNet). 
This association ensures that the security rules defined in the NSG are applied to all resources within the subnet, controlling the inbound and 
outbound traffic according to the specified rules and enhancing the overall security of the subnet.
*/
resource "azurerm_subnet_network_security_group_association" "BallotOnline-sga" {
  subnet_id                 = azurerm_subnet.BallotOnline-subnet.id
  network_security_group_id = azurerm_network_security_group.BallotOnline-sg.id
}

/*
An azurerm_public_ip in Terraform is a resource that creates and manages a public IP address in Azure. This public IP address can be assigned 
to various Azure resources, such as virtual machines or load balancers, allowing them to communicate with the internet or other external networks. 
The resource includes configuration options for IP address allocation, DNS settings, and IP version.
*/
resource "azurerm_public_ip" "BallotOnline-ip" {
  name                = "BallotOnline-ip"
  resource_group_name = azurerm_resource_group.BallotOnline-rg.name
  location            = azurerm_resource_group.BallotOnline-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

/*
An azurerm_network_interface in Terraform is a resource that creates and manages a network interface in Azure. This network interface connects 
virtual machines to a virtual network (VNet), enabling communication within the network and with external resources. It includes settings for IP configurations, 
such as private IP addresses, public IP addresses, and associated security groups.
*/
resource "azurerm_network_interface" "BallotOnline-nic" {
  name                = "BallotOnline-nic"
  location            = azurerm_resource_group.BallotOnline-rg.location
  resource_group_name = azurerm_resource_group.BallotOnline-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.BallotOnline-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.BallotOnline-ip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "BallotOnline-vm" {
  name                  = "BallotOnline-vm"
  resource_group_name   = azurerm_resource_group.BallotOnline-rg.name
  location              = azurerm_resource_group.BallotOnline-rg.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.BallotOnline-nic.id]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/auth_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
