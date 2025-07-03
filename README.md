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
- [⭐️ show your support](#support)
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

</details>

<details>
  <summary>Monitoring Module (`./modules/monitoring`)</summary>

</details>

<details>
  <summary>App Service Module (`./modules/app-service`)</summary>

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
###"Ansible Integration"
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

ansible/
├── inventory.ini            # Generated by Terraform
├── vm_ssh _key               # Auto-generated ssh  key
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

Rotate ssh  keys periodically

Implement Vault for sensitive variables

Enable host checking in production

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
Troubleshooting
Common Issues:

MySQL connection failures: Verify security group rules

Permission denied: Check app_user ownership

Package installation errors: Update apt cache

Debug Commands:

```
ANSIBLE_DEBUG=1 ansible-playbook -i inventory.ini deploy-api.yml -vvv
<p align="right">(<a href="#readme-top">back to top</a>)</p>
```
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
   ${control.name} ansible_host=${control.ip} ansible_user=${ssh _user} 

   [nodes]
   %{for node in nodes ~}
   ${node.name} ansible_host=${node.ip} ansible_user=${ssh _user} 
   %{endfor ~}

   [all:vars]
   ansible_ssh _common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
   ansible_ssh _private_key_file=${ssh _private_key_path}
Terraform Resources (in vms.tf):

Generates ssh  key pair for VM access

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
ansible_ssh _common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_ssh _private_key_file=./ansible/vm_ssh _key
Key Features
Automatic IP Discovery: Dynamically captures public IPs of provisioned VMs

Secure ssh  Access:

Auto-generated 4096-bit RSA key pair

Private key saved with strict 0600 permissions

Disables strict host key checking for initial setup

Environment-Aware:

Includes environment prefix in node names

Uses consistent admin username across hosts

Ready for Ansible:

Properly formatted inventory groups (control/nodes)

Pre-configured ssh  connection parameters

Includes all necessary connection variables

Usage
After Terraform applies the infrastructure:

The inventory file is generated at ./ansible/inventory.ini

The ssh  private key is saved at ./ansible/vm_ssh _key

Run Ansible playbooks using:

```sh 
ansible-playbook -i ansible/inventory.ini ansible/setup.yml
```
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
```
The project includes GitHub Actions workflows for CI/CD. Push to the main branch to trigger the deployment pipeline.

For manual deployment:

Build and deploy frontend:

```sh 
cd frontend && npm run build
az webapp up --name your-frontend-app --resource-group epamqarg --runtime "NODE|14-lts"
```
Deploy backend API:

```sh 
cd backend
az webapp up --name your-backend-api --resource-group epamqarg --runtime "NODE|14-lts"
```
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
⭐️ show your support <a name="support"></a>
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

<p align="right">(<a href="#readme-top">back to top</a>)</p>
