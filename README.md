<a name="readme-top"></a>

<div align="center">
  
   # Azure Full Stack Automation
</div>

<!-- TABLE OF CONTENTS -->

# 📗 Table of Contents

- [📖 About the Project](#about-project)
  - [🌦️ Cloud Diagram](#cloud-diagram)
  - [🌦️ Azure Deployment](#azure-deployment)
  - [🌦️ Estimated Cost](#estimated-cost)
  - [🛠 Built With](#built-with)
    - [Tech Stack](#tech-stack)
    - [Key Features](#key-features)
  - [🚀 Live Demo](#live-demo)
- [💻 Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Install](#install)
  - [Usage](#usage)
  - [Run tests](#run-tests)
  - [Deployment](#deployment)
- [👥 Authors](#authors)
- [🔭 Future Features](#future-features)
- [🤝 Contributing](#contributing)
- [⭐️ show your support](#support)
- [🙏 Acknowledgements](#acknowledgements)
- [❓ FAQ](#faq)
- [📝 License](#license)

<!-- PROJECT DESCRIPTION -->

# 📖 Azure Full Stack Automation <a name="about-project"></a>

**Azure Full Stack Automation** is a project to deploy a full stack application (frontend and backend) to Azure using Terraform for infrastructure provisioning, Ansible for configuration management, and CI/CD pipelines for automated deployment.

## 🌦️ Cloud Diagram <a name="cloud-diagram"></a>
![architecture diagram](https://github.com/user-attachments/assets/2133893e-3ed1-4f2f-b36f-73754dbdfc31)

## Azure Deployment <a name="azure-deployment"></a>
![Recursos 1](https://github.com/user-attachments/assets/04af5b7b-5872-432d-8289-10d62402f937)

![Recursos 2](https://github.com/user-attachments/assets/2f3a0567-e8d2-4e05-86e9-4486ddfa3a9d)

## Azure Monthtly Estimated Cost <a name="estimated-cost"></a>
![monthly cost](https://github.com/user-attachments/assets/6d7ee748-1487-44d6-886c-37130aeefc62)

## 🛠 Built With <a name="built-with"></a>
<details>
  <summary>Infrastructure as Code</summary>
  <ul>
    <li>Terraform</li>
  </ul>
</details>
<details>
  <summary>Configuration Management</summary>
  <ul>
    <li>Ansible</li>
  </ul>
</details>
<details>
  <summary>CI/CD</summary>
  <ul>
    <li>GH Actions</li>
  </ul>
</details>

## 🛠 Terraform Modules Overview <a name="terraform-modules"></a>
This project uses a modular Terraform architecture with the following components:

<details>
  <summary> Network Module (`./modules/mysql-database`)</summary>

#### Virtual Network (VNet)
- **CIDR Block**: `10.0.0.0/16`
- **Subnets**:
  - **Backend Subnet** (`10.0.2.0/24`):
    - Hosts application servers
    - Associated with backend NSG
    - Connected to NAT Gateway
  - **Database Subnet** (`10.0.3.0/24`):
    - Isolated subnet for database services
    - Microsoft.Storage service endpoints enabled
    - Restricted access to backend subnet only


#### Network Security Groups (NSGs)
- **Backend NSG**:
  - Allows SSH access from any IP (port 22)
  - Permits internal HTTP traffic on port 8080
  - Default Azure rules for outbound traffic
- **Database NSG**:
  - Restricts MySQL access (port 3306) to backend subnet only
  - Explicitly denies all other inbound traffic
  - Implements zero-trust model for database layer

#### NAT Gateway (Standard SKU)
- **Features**:
  - Provides outbound internet connectivity for backend resources
  - Uses static public IP address
  - Deployed in availability zone 1
  - 4-minute idle timeout (minimum for cost optimization)
- **Environment Awareness**:
  - Currently deployed in all environments (commented conditional logic available)

</details>

<details>
  <summary>MySQL Database Module (`./modules/mysql-database`)</summary>

 #### MySQL Flexible Server
- **Environment-Aware Configuration**:
  - **Production**: GP_Standard_D2ds_v4 SKU with 256GB storage
  - **Non-Production**: B_Standard_B1ms SKU with 20GB storage (free-tier eligible)
- **Authentication**:
  - Custom administrator username/password
  - MySQL 8.0.21 version
- **Storage**:
  - UTF8MB4 charset with Unicode collation
  - Auto-growing storage (up to 16TB)

#### Database Instance
- Pre-configured `movie_analyst` database
- Optimized character set for multilingual content
- Proper collation for case-insensitive searches

#### Network Integration
- Private Endpoint connectivity
- Isolated within database subnet
- DNS integration via Private DNS Zone
</details>

<details>
  <summary>Load Balancer Module (`./modules/load-balancer`)</summary>

#### Azure Load Balancer (Standard SKU)
- **Frontend Configuration**:
  - Static public IP address (Standard SKU)
  - Listens on port 80 for HTTP traffic
- **Backend Pool**:
  - Contains 2 backend VMs for high availability
  - Auto-registers VM network interfaces
- **Health Probes**:
  - HTTP probe checking `/health` endpoint on port 8080
  - 15-second interval for responsiveness
- **Load Balancing Rules**:
  - Port 80 → 8080 forwarding
  - TCP protocol for optimal performance
  - Health probe integration

#### Virtual Machine Infrastructure
- **Backend VMs**:
  - 2 Ubuntu 18.04 LTS instances (Standard_B1ls)
  - Each with:
    - Dynamic private IP in backend subnet
    - Basic SKU public IP (dynamic)
    - 30GB standard OS disk
- **Control VM**:
  - Ubuntu 22.04 LTS instance
  - Static public IP (Standard SKU)
  - Used for management/administration
</details>

<details>
  <summary>Monitoring Module (`./modules/monitoring`)</summary>

#### Log Analytics Workspace
- **SKU**: PerGB2018 (First 5GB/month free)
- **Retention**: 30 days (free tier maximum)
- **Features**:
  - Centralized log collection
  - Basic metrics storage
  - Resource-agnostic logging

#### Diagnostic Settings
- **Free Tier Configuration**:
  - Minimal metrics collection
  - Load balancer basic health metrics
  - No additional storage costs
- **Enhanced Configuration**:
  - Full metrics collection
  - Comprehensive log capture
  - All categories enabled
</details>

<details>
  <summary>App Service Module (`./modules/app-service`)</summary>

#### App Service Plan
- **Tier**: Free (F1 SKU)
- **OS**: Linux
- **Scaling**: Manual (single instance)
- **Compute**: Shared infrastructure

#### Web Application
- **Runtime**: Node.js 14 LTS
- **Configuration**:
  - AlwaysOn disabled (Free tier limitation)
  - System-assigned managed identity
  - Custom application settings
- **Networking**:
  - Integrated with Load Balancer backend
  - Automatic HTTPS redirection
</details>

### Tech Stack <a name="tech-stack"></a>
<details>
<summary>Database</summary>
  <ul>
    <li><a href="https://www.mysql.com/">MySQL</a></li>
  </ul>
</details>

<details>
<summary>Infrastructure</summary>
  <ul>
    <li><a href="https://www.terraform.io/">Terraform</a></li>
    <li><a href="https://docs.microsoft.com/en-us/azure/">Azure Cloud</a></li>
    <li><a href="https://www.ansible.com/">Ansible</a></li>
  </ul>
</details>

<!-- Features -->

### Key Features <a name="key-features"></a>

- **Infrastructure as Code**: Entire Azure infrastructure defined and managed using Terraform
- **Team remote State**: Terraform State Management in Azure
- **Modular Architecture**: Separate Terraform modules for networking, database, load balancing, and monitoring
- **Environment Separation**: Support for multiple environments (dev, qa, staging, prod) using Terraform workspaces
- **CI/CD Pipeline**: Automated deployment process for both frontend and backend components
- **Monitoring Integration**: Built-in Azure monitoring for the deployed application
- **Configuration Management**: Use of Ansible for automated configuration and deployment.
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LIVE DEMO -->

## 🚀 Live Demo <a name="live-demo"></a>

- [Live Demo Link](https://your-azure-app-url.azurewebsites.net)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 💻 Getting Started <a name="getting-started"></a>

To get a local copy up and running, follow these steps.

### Prerequisites

Before you begin, ensure you have the following installed:
- Terraform (>= 1.0.0)
- Azure CLI
- Ansible (>= 2.9)

## Ansible Configuration <a name="ansible-configuration"></a>

This project uses Ansible for automated configuration management and application deployment across all infrastructure components.

### Playbook Structure

#### 1. Infrastructure Setup (`setup-infra.yml`)
- **Hosts**: All nodes (control + backend)
- **Purpose**: Baseline system configuration
- **Key Tasks**:
  - Updates `/etc/hosts` for all nodes
  - Configures ssh  access from control node
  - Sets up passwordless authentication
  - Disables strict host checking for internal nodes

#### 2. API Deployment (`deploy-api.yml`)
- **Hosts**: Backend nodes
- **Purpose**: Full application deployment
- **Key Tasks**:
  - Installs system dependencies (Node.js, npm, MySQL client)
  - Clones application repository
  - Configures database connection
  - Initializes MySQL database schema
  - Sets up PM2 process manager
  - Creates systemd service for automatic startup

### Configuration Highlights

1. **Secure Deployment**:
   - Database credentials injected via variables
   - Limited file permissions (config.js: 0640)
   - No-log for sensitive database operations
   - ssh  strict host checking disabled only for internal nodes

2. **Idempotent Operations**:
   - Conditional database initialization
   - Changed-when clauses for accurate reporting
   - Atomic file operations

3. **Environment Variables**:
   ```yaml
   mysql_config:
     host: "{{ mysql_host }}"
     user: "{{ mysql_user }}"
     password: "{{ mysql_password }}"
     database: "{{ mysql_database }}"
     port: 3306
Execution Workflow
First-Time Setup:

```
ansible-playbook -i inventory.ini setup-infra.yml
```
API Deployment:

```
ansible-playbook -i inventory.ini deploy-api.yml \
  -e mysql_host=epamqa-mysql-eastus \
  -e mysql_user=adminuser \
  -e mysql_password=$DB_PASSWORD \
  -e mysql_database=movie_analyst
```
Verification:

```
ansible nodes -i inventory.ini -m 
shell -a "systemctl status movie-api"
```

File Structure

```
ansible/
├── inventory.ini            # Generated by Terraform
├── vm_ssh_key               # Auto-generated SSH key
├── files/
│   └── mysql/
│       └── movie_db.sql     # Database schema
├── templates/
│   ├── config.js.j2         # DB config template
│   └── movie-api.service.j2 # Systemd template
├── deploy-api.yml           # Main deployment playbook
└── setup-infra.yml          # Infrastructure setup
```


Best Practices
Secret Management:

```
ansible-vault encrypt_string '$DB_PASSWORD' --name 'mysql_password'
```
Dry-Run Verification:

```
ansible-playbook -i inventory.ini deploy-api.yml --check --diff
```
Tagged Execution:

```
ansible-playbook -i inventory.ini deploy-api.yml --tags "db,config"
```

## Ansible Inventory Generation <a name="ansible-inventory"></a>

This project automatically generates an Ansible inventory file (`inventory.ini`) from Terraform outputs, enabling seamless configuration management of provisioned VMs.

### Inventory Generation Process

The system creates a dynamic inventory using:
1. **Terraform Template File** (`inventory.tmpl`):
   ```ini
   [control]
   ${control.name} ansible_host=${control.ip} ansible_user=${ssh _user} 

   [nodes]
   %{for node in nodes ~}
   ${node.name} ansible_host=${node.ip} ansible_user=${ssh _user} 
   %{endfor ~}

   [all:vars]
   ansible_ssh _common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
   ansible_ssh _private_key_file=${ssh _private_key_path}
   
<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Setup

1. Clone the repository:
sh
git clone https://github.com/aljoveza/devops-rampup.git
cd devops-rampup

Initialize Terraform:

```sh 
terraform init
```
Create a Terraform workspace (for example, for QA environment):

```sh 
terraform workspace new qa
```
Install
Install Azure CLI and login:

```sh 
az login
```
Install required Ansible roles:

```sh 
ansible-galaxy install -r ansible/requirements.yml
```
Usage
Plan the Terraform deployment:

```sh 
terraform plan -var-file=environments/qa.tfvars
```
Apply the changes:

```sh 
terraform apply -var-file=environments/qa.tfvars
```
Run Ansible playbook to configure servers:

```sh 
ansible-playbook ansible/setup.yml -i ansible/inventory/qa
```
Run tests
Run infrastructure tests:

```sh 
terraform validate
```
Run application tests:

```sh 
cd frontend && npm test
cd ../backend && npm test
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- AUTHORS -->

## 👥 Authors <a name="authors"></a>
👤 **Elio Cortés**

- GitHub: [@NeckerFree](https://github.com/NeckerFree)
- Twitter: [@ElioCortesM](https://twitter.com/ElioCortesM)
- LinkedIn: [elionelsoncortes](https://www.linkedin.com/in/elionelsoncortes/)

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- FUTURE FEATURES -->
🔭 Future Features <a name="future-features"></a>
Auto-scaling: Implement auto-scaling for both frontend and backend components

Blue-Green Deployment: Add support for blue-green deployments

Enhanced Monitoring: Integrate Application Insights for deeper performance monitoring

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- CONTRIBUTING -->

## 🤝 Contributing <a name="contributing"></a>
Contributions, issues, and feature requests are welcome!

Feel free to check the issues page.

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- SUPPORT -->
⭐️ show your support <a name="support"></a>
If you like this project, please give it a ⭐️ on GitHub!

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- ACKNOWLEDGEMENTS -->

## 🙏 Acknowledgements <a name="acknowledgements"></a>
Hat tip to anyone whose code was used

Inspiration

etc

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- FAQ -->

## ❓FAQ <a name="faq"></a>
How do I switch between environments?

Use Terraform workspaces: terraform workspace select qa or terraform workspace select prod

Where are the database credentials stored?

Database credentials are managed through Azure Key Vault and injected as environment variables during deployment.

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- LICENSE -->

## 📝 License <a name="license"></a>
This project is MIT licensed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
