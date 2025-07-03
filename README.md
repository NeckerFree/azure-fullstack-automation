<a name="readme-top"></a>

<div align="center">
  
   # Azure Full Stack Automation
</div>

<!-- TABLE OF CONTENTS -->

# 📗 Table of Contents

- [📖 About the Project](#about-project)
  - [🌦️ Cloud Diagram](#cloud-diagram)
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
- [⭐️ Show your support](#support)
- [🙏 Acknowledgements](#acknowledgements)
- [❓ FAQ](#faq)
- [📝 License](#license)

<!-- PROJECT DESCRIPTION -->

# 📖 Azure Full Stack Automation <a name="about-project"></a>

**Azure Full Stack Automation** is a project to deploy a full stack application (frontend and backend) to Azure using Terraform for infrastructure provisioning, Ansible for configuration management, and CI/CD pipelines for automated deployment.

## 🌦️ Cloud Diagram <a name="cloud-diagram"></a>
![architecture diagram](https://github.com/user-attachments/assets/2133893e-3ed1-4f2f-b36f-73754dbdfc31)

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
  <summary>Network Module (`./modules/mysql-database`)</summary>

</details>

<details>
  <summary>MySQL Database Module (`./modules/mysql-database`)</summary>
 
</details>

<details>
  <summary>Load Balancer Module (`./modules/load-balancer`)</summary>

- **Purpose**: Manages traffic distribution and high availability
- **Features**:
  - Deploys Azure Load Balancer with public IP
  - Configures health probes for backend services
  - Sets up load balancing rules
  - Integrates with backend pools
  - Supports SSL termination (if configured)
- **Outputs**:
  - Load Balancer ID
  - Public IP address
  - Backend pool configuration

The Load Balancer module implements a highly available, scalable traffic distribution solution for backend application servers.

### Core Components

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

### Key Features

1. **High Availability**:
   - Two backend instances in load-balanced pool
   - Automatic health monitoring
   - Traffic distribution based on availability

2. **Security**:
   - 4096-bit SSH key pair auto-generated
   - Private key stored with 0600 permissions
   - Standard SKU for enhanced security features

3. **Integration Ready**:
   - Automatic Ansible inventory generation
   - Pre-configured SSH access for automation
   - Dynamic IP address handling

4. **Cost Optimization**:
   - Free-tier eligible VM sizes
   - Efficient health checking (15s interval)
   - Standard LB with basic features

### Module Outputs

This module provides:
- Load Balancer public IP address
- Backend pool ID for service registration
- Health probe configuration
- Generated SSH key pair (for Ansible)

### Usage Example

```hcl
module "load-balancer" {
  source              = "./modules/load-balancer"
  location            = var.location
  env_prefix          = local.name_prefix
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  backend_subnet_id   = module.network.backend_subnet_id
  admin_username      = var.admin_username
}
Ansible Integration
The module automatically generates:

inventory.ini with:

ini
[control]
control.example.com ansible_host=<PUBLIC_IP> ansible_user=adminuser

[nodes]
epamqa-vm-api-0 ansible_host=<PUBLIC_IP_0> ansible_user=adminuser
epamqa-vm-api-1 ansible_host=<PUBLIC_IP_1> ansible_user=adminuser

[all:vars]
ansible_ssh_private_key_file=./ansible/vm_ssh_key
Private key file at ./ansible/vm_ssh_key

Maintenance Notes
Scaling:

Add/remove VMs by adjusting the count parameter

Backend pool automatically updates

Monitoring:

Health probe failures indicate service issues

Consider Azure Monitor for metrics

Upgrades:

Change VM image references for OS updates

Rotate SSH keys periodically

<p align="right">(<a href="#readme-top">back to top</a>)</p> ```
This section provides:

Clear technical specifications

Architecture diagram in text form

Integration points with other modules

Operational considerations

Ready-to-use examples

Automation details

The content maintains consistency with your existing documentation style while thoroughly covering the load balancer implementation. You can place this under "Infrastructure Modules" or similar section in your README.
</details>

<details>
  <summary>Monitoring Module (`./modules/monitoring`)</summary>
- **Purpose**: Implements observability and alerting
- **Features**:
  - Creates Azure Monitor components
  - Sets up diagnostic settings for resources
  - Configures alerts for critical metrics
  - Establishes log analytics workspace
  - Implements dashboard for operational visibility
- **Outputs**:
  - Alert rule IDs
  - Dashboard URLs
  - Metric configuration
## Monitoring Module <a name="monitoring-module"></a>

This module implements a cost-optimized monitoring solution for Azure resources with both free-tier and enhanced monitoring options.

### Core Components

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

### Key Features

1. **Cost Optimization**:
   - Free tier compliant by default
   - Pay-as-you-go logging (after 5GB)
   - Configurable retention period

2. **Flexible Monitoring**:
   - Toggle between free and full monitoring
   - Environment-aware configuration
   - Centralized log management

3. **Integration Ready**:
   - Pre-configured for load balancer
   - Extensible to other resources
   - Workspace shared across services

### Module Configuration

```hcl
module "monitoring" {
  source              = "./modules/monitoring"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  lb_id               = module.load-balancer.lb_id
  env_prefix          = local.name_prefix
  enable_free_monitoring = true # Set false for production
}
Monitoring Tiers
Feature	Free Tier	Enhanced Tier
Metrics Collection	Basic	Comprehensive
Log Categories	Limited	All
Cost Impact	$0 (first 5GB)	Variable
Retention	30 days	Configurable
Recommended Setup
Development/QA:

hcl
enable_free_monitoring = true
Production:

hcl
enable_free_monitoring = false
retention_in_days = 90 # Recommended for production
Operational Insights
Accessing Logs:

Navigate to Azure Portal → Log Analytics workspace

Use KQL queries for analysis

Set up basic alerts

Cost Control:

Monitor "Usage and estimated costs"

Set daily caps if needed

Consider archive tier for old logs

Upgrade Path:

Enable Application Insights for apps

Add Azure Monitor alerts

Implement log-based alerts

text
Sample KQL query for LB health:
AzureDiagnostics
| where ResourceType == "LOADBALANCERS"
| summarize count() by bin(TimeGenerated, 1h)
<p align="right">(<a href="#readme-top">back to top</a>)</p> ```
This section provides:

Clear tier comparison

Environment-specific recommendations

Cost optimization details

Practical usage examples

Operational guidance

Ready-to-use configuration snippets
</details>

<details>
  <summary>App Service Module (`./modules/app-service`)</summary>

- **Purpose**: Deploys and manages the application services
- **Features**:
  - Provisions Azure App Service plans
  - Deploys Web Apps for frontend and backend
  - Configures auto-scaling rules
  - Manages deployment slots
  - Sets up continuous deployment integration
- **Outputs**:
  - App Service URLs
  - Deployment credentials
  - Scaling configuration

This module deploys and manages an Azure Linux Web App for hosting the application frontend with integration to backend services.

### Core Components

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

### Key Features

1. **Cost Optimization**:
   - Free tier service plan
   - Shared compute resources
   - Automatic scaling prevention (Free tier)

2. **Environment Ready**:
   - Node.js runtime pre-configured
   - Environment variables injection
   - Port mapping (3000) for application

3. **Integration Features**:
   - Load balancer endpoint configuration
   - System-assigned identity for secure access
   - Automatic app settings management

4. **Deployment Friendly**:
   - Ready for CI/CD pipeline integration
   - Supports deployment slots (when upgraded)
   - Built-in logging and diagnostics

### Module Configuration

```hcl
module "app-service" {
  source              = "./modules/app-service"
  resource_group_name = azurerm_resource_group.main.name
  lb_public_ip        = module.load-balancer.lb_public_ip
  env_prefix          = local.name_prefix
  app_name            = "movies"
  environment         = local.environment
  location            = var.location
}
Application Settings
Setting	Value	Purpose
API_BASE_URL	http://[LB_IP]/api	Backend API endpoint
NODE_ENV	Environment name	Runtime environment
WEBSITES_PORT	3000	Application listening port
WEBSITES_ENABLE_APP_SERVICE_STORAGE	false	Disables persistent storage
Limitations & Considerations
Free Tier Restrictions:

No custom domains

No SSL certificates

No deployment slots

No AlwaysOn feature

Scaling:

Upgrade to Basic/Standard tier for:

Multiple instances

Custom domains

Deployment slots

AlwaysOn capability

Monitoring:

Basic metrics available

Consider Application Insights for advanced monitoring

Upgrade Path
To enable production-grade features:

hcl
resource "azurerm_service_plan" "main" {
  sku_name = "B1" # Basic tier
  # ... other configuration ...
}

resource "azurerm_linux_web_app" "main" {
  site_config {
    always_on = true # Now available
  }
  # ... other configuration ...
}
<p align="right">(<a href="#readme-top">back to top</a>)</p> ```
This section provides:

Clear technical specifications

Free tier limitations

Integration details

Ready-to-use examples

Upgrade guidance

Operational considerations
</details>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
### Tech Stack <a name="tech-stack"></a>

<details>
  <summary>Client</summary>
  <ul>
    <li><a href="https://reactjs.org/">React.js</a></li>
  </ul>
</details>

<details>
  <summary>Server</summary>
  <ul>
    <li><a href="https://expressjs.com/">Express.js</a></li>
    <li><a href="https://nodejs.org/">Node.js</a></li>
  </ul>
</details>

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
- **Modular Architecture**: Separate Terraform modules for networking, database, load balancing, and monitoring
- **CI/CD Pipeline**: Automated deployment process for both frontend and backend components
- **Environment Separation**: Support for multiple environments (dev, qa, staging, prod) using Terraform workspaces
- **Monitoring Integration**: Built-in Azure monitoring for the deployed application

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LIVE DEMO -->

## 🚀 Live Demo <a name="live-demo"></a>

- [Live Demo Link](https://your-azure-app-url.azurewebsites.net)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## 💻 Getting Started <a name="getting-started"></a>

To get a local copy up and running, follow these steps.

### Prerequisites

Before you begin, ensure you have the following installed:
- Terraform (>= 1.0.0)
- Azure CLI
- Ansible (>= 2.9)
- Node.js (for local development)
- MySQL client
###"Ansible Integration"
## Ansible Configuration <a name="ansible-configuration"></a>

This project uses Ansible for automated configuration management and application deployment across all infrastructure components.

### Playbook Structure

#### 1. Infrastructure Setup (`setup-infra.yml`)
- **Hosts**: All nodes (control + backend)
- **Purpose**: Baseline system configuration
- **Key Tasks**:
  - Updates `/etc/hosts` for all nodes
  - Configures SSH access from control node
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
   - SSH strict host checking disabled only for internal nodes

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

bash
ansible-playbook -i inventory.ini setup-infra.yml
API Deployment:

bash
ansible-playbook -i inventory.ini deploy-api.yml \
  -e mysql_host=epamqa-mysql-eastus \
  -e mysql_user=adminuser \
  -e mysql_password=$DB_PASSWORD \
  -e mysql_database=movie_analyst
Verification:

bash
ansible nodes -i inventory.ini -m shell -a "systemctl status movie-api"
File Structure
text
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
Customization Points
Database Configuration:

Modify templates/config.js.j2 for application-specific settings

Update mysql_script_path for custom schema

Service Management:

Edit movie-api.service.j2 for process arguments

Adjust PM2 configuration in deployment tasks

Security:

Rotate SSH keys periodically

Implement Vault for sensitive variables

Enable host checking in production

Best Practices
Secret Management:

bash
ansible-vault encrypt_string '$DB_PASSWORD' --name 'mysql_password'
Dry-Run Verification:

bash
ansible-playbook -i inventory.ini deploy-api.yml --check --diff
Tagged Execution:

bash
ansible-playbook -i inventory.ini deploy-api.yml --tags "db,config"
Troubleshooting
Common Issues:

MySQL connection failures: Verify security group rules

Permission denied: Check app_user ownership

Package installation errors: Update apt cache

Debug Commands:

bash
ANSIBLE_DEBUG=1 ansible-playbook -i inventory.ini deploy-api.yml -vvv
<p align="right">(<a href="#readme-top">back to top</a>)</p> ```
This section provides:

Clear playbook documentation

Execution workflow

Security considerations

Customization guidance

Troubleshooting tips

Best practices
### Configuration management or 
## Ansible Inventory Generation <a name="ansible-inventory"></a>

This project automatically generates an Ansible inventory file (`inventory.ini`) from Terraform outputs, enabling seamless configuration management of provisioned VMs.

### Inventory Generation Process

The system creates a dynamic inventory using:
1. **Terraform Template File** (`inventory.tmpl`):
   ```ini
   [control]
   ${control.name} ansible_host=${control.ip} ansible_user=${ssh_user} 

   [nodes]
   %{for node in nodes ~}
   ${node.name} ansible_host=${node.ip} ansible_user=${ssh_user} 
   %{endfor ~}

   [all:vars]
   ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
   ansible_ssh_private_key_file=${ssh_private_key_path}
Terraform Resources (in vms.tf):

Generates SSH key pair for VM access

Provisions control plane and backend nodes

Captures VM IP addresses and names

Renders the final inventory.ini file

Generated Inventory Structure
The resulting inventory.ini contains:

ini
[control]
control.example.com ansible_host=<PUBLIC_IP> ansible_user=adminuser

[nodes]
epamqa-vm-api-0 ansible_host=<PUBLIC_IP_0> ansible_user=adminuser
epamqa-vm-api-1 ansible_host=<PUBLIC_IP_1> ansible_user=adminuser

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_ssh_private_key_file=./ansible/vm_ssh_key
Key Features
Automatic IP Discovery: Dynamically captures public IPs of provisioned VMs

Secure SSH Access:

Auto-generated 4096-bit RSA key pair

Private key saved with strict 0600 permissions

Disables strict host key checking for initial setup

Environment-Aware:

Includes environment prefix in node names

Uses consistent admin username across hosts

Ready for Ansible:

Properly formatted inventory groups (control/nodes)

Pre-configured SSH connection parameters

Includes all necessary connection variables

Usage
After Terraform applies the infrastructure:

The inventory file is generated at ./ansible/inventory.ini

The SSH private key is saved at ./ansible/vm_ssh_key

Run Ansible playbooks using:

sh
ansible-playbook -i ansible/inventory.ini ansible/setup.yml
Security Notes
The generated private key should be:

Securely stored (consider using a secrets manager)

Rotated regularly in production

Not committed to version control

Host key checking is disabled for initial setup only

Production deployments should implement proper host verification

<p align="right">(<a href="#readme-top">back to top</a>)</p> ```
This section explains:

The complete inventory generation workflow

The template structure and variables

The resulting inventory file format

Security considerations

Practical usage instructions
### Setup

1. Clone the repository:
```sh
git clone https://github.com/aljoveza/devops-rampup.git
cd devops-rampup

Initialize Terraform:

sh
terraform init
Create a Terraform workspace (for example, for QA environment):

sh
terraform workspace new qa
Install
Install Azure CLI and login:

sh
az login
Install required Ansible roles:

sh
ansible-galaxy install -r ansible/requirements.yml
Usage
Plan the Terraform deployment:

sh
terraform plan -var-file=environments/qa.tfvars
Apply the changes:

sh
terraform apply -var-file=environments/qa.tfvars
Run Ansible playbook to configure servers:

sh
ansible-playbook ansible/setup.yml -i ansible/inventory/qa
Run tests
Run infrastructure tests:

sh
terraform validate
Run application tests:

sh
cd frontend && npm test
cd ../backend && npm test
Deployment
## Terraform State Management in Azure <a name="terraform-state"></a>

This project securely stores Terraform state files in Azure Blob Storage, providing a centralized and reliable state management solution with the following features:

- **Dedicated Storage Account**: 
  - Created in resource group `elio-tfstate-rg`
  - Premium tier Block Blob Storage account (`epamqatfstate`)
  - Locally redundant storage (LRS) for cost efficiency
  - Minimum TLS 1.2 enforced for security

- **State Container**:
  - Private container named `tfstate`
  - Access restricted to authorized users only

- **Data Protection**:
  - 7-day retention policy for both blob deletions and container deletions
  - Public access explicitly disabled
  - Tagged with environment and cost-center metadata

- **Benefits**:
  - Enables team collaboration with shared state
  - Provides state locking to prevent conflicts
  - Maintains state history for recovery
  - Secures sensitive values in the state file

The configuration ensures state files are:
✓ Versioned and protected from accidental deletion  
✓ Accessible only to authorized personnel  
✓ Stored in compliance with security best practices  

To initialize Terraform with this backend:
```sh
terraform init -backend-config="storage_account_name=epamqatfstate" \
               -backend-config="container_name=tfstate" \
               -backend-config="key=terraform.tfstate" \
               -backend-config="resource_group_name=elio-tfstate-rg"
The project includes GitHub Actions workflows for CI/CD. Push to the main branch to trigger the deployment pipeline.

For manual deployment:

Build and deploy frontend:

sh
cd frontend && npm run build
az webapp up --name your-frontend-app --resource-group epamqarg --runtime "NODE|14-lts"
Deploy backend API:

sh
cd backend
az webapp up --name your-backend-api --resource-group epamqarg --runtime "NODE|14-lts"
<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- AUTHORS -->
👥 Authors <a name="authors"></a>
👤 Author Name

GitHub: @githubhandle

Twitter: @twitterhandle

LinkedIn: LinkedIn

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- FUTURE FEATURES -->
🔭 Future Features <a name="future-features"></a>
Auto-scaling: Implement auto-scaling for both frontend and backend components

Blue-Green Deployment: Add support for blue-green deployments

Enhanced Monitoring: Integrate Application Insights for deeper performance monitoring

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- CONTRIBUTING -->
🤝 Contributing <a name="contributing"></a>
Contributions, issues, and feature requests are welcome!

Feel free to check the issues page.

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- SUPPORT -->
⭐️ Show your support <a name="support"></a>
If you like this project, please give it a ⭐️ on GitHub!

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- ACKNOWLEDGEMENTS -->
🙏 Acknowledgements <a name="acknowledgements"></a>
Hat tip to anyone whose code was used

Inspiration

etc

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- FAQ -->
❓ FAQ <a name="faq"></a>
How do I switch between environments?

Use Terraform workspaces: terraform workspace select qa or terraform workspace select prod

Where are the database credentials stored?

Database credentials are managed through Azure Key Vault and injected as environment variables during deployment.

<p align="right">(<a href="#readme-top">back to top</a>)</p><!-- LICENSE -->
📝 License <a name="license"></a>
This project is MIT licensed.

<p align="right">(<a href="#readme-top">back to top</a>)</p> ```
To download this as a file:

Copy all the content above

Open a text editor (VS Code, Notepad++, etc.)

Paste the content

Save the file as README.md

Place it in your project's root directory

The README includes:

Complete project documentation

Installation and setup instructions

Deployment procedures

Technology stack details

Future roadmap

All necessary sections from your template

You may want to customize:

Author information

Live demo URL

Acknowledgements section

Any project-specific details
