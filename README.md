<a name="readme-top"></a>

<div align="center">
  <img src="azure_logo.png" alt="Azure Cloud Logo" width="120" />
  <h3><b>Cloud Web App Deployment on Azure</b></h3>
</div>

# 📗 Table of Contents

- [📖 About the Project](#about-project)
  - [🛠 Built With](#built-with)
    - [Tech Stack](#tech-stack)
    - [Key Features](#key-features)
  - [🚀 Live Demo](#live-demo)
- [💻 Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Provision Infrastructure (Terraform)](#terraform)
  - [Configure Services (Ansible)](#ansible)
  - [Deployment](#deployment)
- [🔧 Customizing Variables](#custom-variables)
- [☁️ Remote Terraform State in Azure](#️remote-terraform-state-in-azure)
- [👥 Authors](#authors)
- [🔭 Future Features](#future-features)
- [🤝 Contributing](#contributing)
- [⭐️ Show your support](#support)
- [🙏 Acknowledgements](#acknowledgements)
- [❓ FAQ](#faq)
- [📝 License](#license)

---

# 📖 Azure Cloud Web App Deployment <a name="about-project"></a>

This project automates the provisioning and deployment of a scalable cloud application on Microsoft Azure. It uses **Terraform** to create infrastructure, and **Ansible** to configure services like a backend API running on 2 VMs behind a Load Balancer, connected to an **Azure MySQL** database, along with a frontend deployed on **Azure Web App**.

<img width="1080" height="503" alt="architecture diagram" src="https://github.com/user-attachments/assets/a66138ba-d8e5-48d2-9e0e-0f6b2160ce37" />
<p align="center">Architecture Diagram</p>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
## 🛠 Built With <a name="built-with"></a>

### Tech Stack <a name="tech-stack"></a>

<details>
  <summary>Infrastructure as Code</summary>
  <ul>
    <li><a href="https://www.terraform.io/">Terraform</a></li>
  </ul>
</details>

<details>
  <summary>Configuration Management</summary>
  <ul>
    <li><a href="https://www.ansible.com/">Ansible</a></li>
  </ul>
</details>

<details>
  <summary>Cloud Platform</summary>
  <ul>
    <li><a href="https://azure.microsoft.com/">Microsoft Azure</a></li>
  </ul>
</details>

<details>
<summary>Database</summary>
  <ul>
    <li><a href="https://learn.microsoft.com/en-us/azure/mysql/">Azure Database for MySQL</a></li>
  </ul>
</details>

<details>
  <summary>Deployment Targets</summary>
  <ul>
    <li>Azure Virtual Machines</li>
    <li>Azure Load Balancer</li>
    <li>Azure App Service (Web App)</li>
  </ul>
</details>

### Key Features <a name="key-features"></a>

- 🔧 Automated infrastructure provisioning with Terraform  
- 📦 Service configuration and app deployment using Ansible  
- 🐘 MySQL database initialized via Ansible using `ansible/files/mysql/movie_db.sql`
- 🌐 Scalable API on 2 Azure VMs behind a Load Balancer  
- 💾 Managed Azure MySQL integration  
- 🚀 Web frontend deployed using Azure Web App  
- 🔐 Service Principal authentication using Client Secret  
- ⚙️ Fully automated deployment workflow with CI/CD integration  
- 🏗️ End-to-end Terraform deployment from scratch included in workflow  
- 🧹 Automated environment teardown using `terraform-destroy.yml`  
- 💸 Uses Azure Web App **F1 Free Tier** for cost-effective deployment  

<div align="center">
<img width="1007" height="877" alt="Get Movies in Postman (Base Address LB IP)  " src="https://github.com/user-attachments/assets/52775015-3816-484f-8efc-9a14546a8b1f" />
<p align="center">Load Balancer API (Backend)</p>
</div>

<div align="center">
<img width="1001" height="697" alt="Azure secrets" src="https://github.com/user-attachments/assets/6252116c-f71a-41cd-b4a7-5528cc219a3c" />
<p align="center">Azure Secrets</p>
</div>

<div align="center">
<img width="760" height="647" alt="SSH App Service" src="https://github.com/user-attachments/assets/eeb418df-f4b8-4c9a-8a46-0f2f81600618" />
<p align="center">App Service</p>
</div>
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<div align="center">
<img width="970" height="887" alt="Workflow" src="https://github.com/user-attachments/assets/b5112807-1e02-4558-a972-facba34dd5f0" />
<p align="center">GH Actions Workflow</p>
</div>
---

## 🚀 Live Demo <a name="live-demo"></a>

- [Frontend Web App](https://softdefault-movies-app.azurewebsites.net/)
- [API Endpoint (behind Load Balancer)](http://my-movie-analyst-lb.westus2.cloudapp.azure.com:8080/health)

<div align="center">
<img width="778" height="590" alt="Movie Analyst main page" src="https://github.com/user-attachments/assets/e804228f-3930-4fa1-bd6f-1106f811d83c" />
<p align="center">Movie Analyst main page</p>
</div>

<div align="center">
<img  width="773" height="820" alt="Our Movies Critics" src="https://github.com/user-attachments/assets/1f495fae-c29d-4ce6-a87c-d0ec9636dbc9" />
<p align="center">Our Movies Critics</p>
</div>

<div align="center">
<img  width="917" height="967" alt="Latest Movie Reviews" src="https://github.com/user-attachments/assets/c17f90c8-6720-4357-a275-639deecca0ed" />
<p align="center">Latest Movie Reviews</p>
</div>

<div align="center">
<img width="771" height="827" alt="Our Publication Partners" src="https://github.com/user-attachments/assets/67478e8b-b0e5-4a5f-88ec-3de129e9bf6f" />
<p align="center">Our Publication Partners</p>
</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 💻 Getting Started <a name="getting-started"></a>

To get a local copy up and running, follow these instructions.

### Prerequisites

Most dependencies are installed automatically in the GitHub Actions workflow. However, for local development or debugging, ensure you have the following:

- 🖥️ Azure CLI (`az`)
- 📦 Terraform ≥ 1.5
- ⚙️ Ansible ≥ 2.15
- 🔐 SSH key pair for accessing virtual machines
- 📦 Node.js ≥ 14 and npm (required for both frontend and backend)
- 📚 `zip` utility (used to package the frontend app)
- ☁️ Azure Service Principal credentials (used by the workflow):
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`
  - `ARM_TENANT_ID`
  - `ARM_SUBSCRIPTION_ID`
- 💡 *(Optional)* GitHub CLI (`gh`) – useful for managing secrets or manually triggering workflows


### 🔧 Setup

```bash
# Clone this repository
git clone https://github.com/NeckerFree/azure-fullstack-automation.git
cd azure-fullstack-automation
```
create a file 
## 📦 Provision Infrastructure (Terraform) <a name="terraform"></a>

Infrastructure provisioning is fully automated and triggered via **GitHub Actions** on every push or pull request to the `master` branch.

- Terraform is initialized and executed within the workflow using predefined variables.
- The deployment includes:
  - A MySQL database on Azure
  - A Load Balancer with 2 backend VMs
  - Network and security resources
- The entire infrastructure is provisioned from scratch via `terraform.yml`.

## ⚙️ Configure Services (Ansible) <a name="ansible"></a>
</div>
<div align="center">
<img width="2216" height="1205" alt="Jumpbox NSG diagram" src="https://github.com/user-attachments/assets/8a402bc6-5bb5-4070-98cc-6a13babf379a" />
<p align="center">Ansible Jumpbox Configuration</p>
</div>

Once the infrastructure is up, **Ansible playbooks** are automatically triggered within the same CI/CD workflow to:

- Configure the VMs with the required packages
- Deploy the Node.js API to both backend nodes
- Apply application settings
- Validate MySQL schema creation and data population

This configuration is handled through the `deploy-api.yml` GitHub Actions workflow.

## 🚢 Deployment <a name="deployment"></a>

- 🎯 **Trigger**: Every push or pull request to `master` kicks off a full deployment pipeline.
- 🌐 **API** is publicly reachable via the Load Balancer’s IP address.
- 💻 **Frontend** is deployed to Azure Web App using the **F1 Free Tier**.
- 🔐 **Secure integration** between services via environment variables and Azure-managed credentials.
- 🧨 A separate `terraform-destroy.yml` workflow is available to automatically destroy all infrastructure when needed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---
## 🔧 Customizing Variables <a name="custom-variables"></a>

You can modify the following variables to adapt the deployment to your needs. These are defined in the Terraform configuration files:

### infra/terraform.tfvars:

```hcl
allowed_ssh_ip        = "xxx.xxx.xxx.xxx/32"         # IP allowed to access VMs via SSH
mysql_user            = "mysqladmin"                # MySQL admin user
mysql_admin_password  = "Sec#reP@ssword123!"        # MySQL admin password
```
### infra\variables.tf:
```hcl
variable "location" {
  default = "westus2"                               # Azure region to deploy resources
}

variable "admin_username" {
  default = "myadminuser"                                # Admin username for virtual machines
}

variable "lb_api_port" {
  default = 8080                                    # API port exposed by Load Balancer
}
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>
---

## ☁️ Remote Terraform State in Azure <a name="remote-state"></a>

Terraform uses remote state storage to persist infrastructure state across executions and team members.

This project stores the Terraform state file (`terraform.tfstate`) securely in an **Azure Storage Account** using a backend configuration like the following:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "my-resource-group"
    storage_account_name = "myterraformstate"
    container_name       = "tfstate"
    key                  = "infrastructure.tfstate"
  }
}
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>
---

## 👥 Authors <a name="authors"></a>

👤 **Elio Cortés**

- GitHub: [@NeckerFree](https://github.com/NeckerFree)
- Twitter: [@ElioCortesM](https://twitter.com/ElioCortesM)
- LinkedIn: [elionelsoncortes](https://www.linkedin.com/in/elionelsoncortes/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🔭 Future Features <a name="future-features"></a>
- [ ] Enable autoscaling for the API tier
- [ ] Implement managed identity-based DB auth

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues, and feature requests are welcome!

Feel free to open an issue, or request features.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## ⭐️ Show your support <a name="support"></a>

If you like this project, please ⭐️ the repository and share it with others!

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🙏 Acknowledgements <a name="acknowledgements"></a>

- [Microsoft Azure documentation](https://learn.microsoft.com/en-us/azure/)
- [Ansible Azure Collection](https://galaxy.ansible.com/azure/azcollection) contributors
- [HashiCorp Terraform Modules](https://registry.terraform.io/)
- [devops-rampup](https://github.com/aljoveza/devops-rampup) — Backend & frontend prototype used as base for this project
- [EPAM DevOps Campus](https://campus.epam.com/en/training) — Cloud and DevOps learning program
- [ChatGPT](https://chatgpt.com/) — Assistance in automation, CI/CD, and documentation
- [DeepSeek](https://chat.deepseek.com/) — Assistance in automation, CI/CD, and documentation
<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## ❓ FAQ <a name="faq"></a>

### 🔐 Where are secrets like passwords and keys stored?
Secrets are securely stored as GitHub Actions secrets and injected at runtime into the workflows.

### 🧪 Can I test changes before deploying to Azure?
Yes! You can test locally using `terraform plan` and `ansible-playbook` in dry-run mode before committing changes.

### 🌎 Where is the infrastructure deployed?
By default, all resources are deployed to the `westus2` Azure region. You can change this in `infra/variables.tf`.

### 🛠 What if I want to destroy all resources?
You can run the `terraform-destroy.yml` GitHub Actions workflow to safely destroy the provisioned infrastructure.

### 🐘 How is the database created?
The Azure MySQL database is provisioned with Terraform and initialized using `movie_db.sql` from Ansible.

### 🌐 What is the default URL for the frontend?
The frontend is hosted on Azure Web App. The exact URL depends on the generated Azure App Service name. Check the Azure Portal or output logs.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 📝 License <a name="license"></a>

This project is licensed under the [MIT License](./LICENSE).

<p align="right">(<a href="#readme-top">back to top</a>)</p>
