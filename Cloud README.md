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
    <li><a href="https://github.com/ansible-collections/azure">azure.azcollection</a></li>
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
- 🌐 Scalable API on 2 Azure VMs behind a Load Balancer
- 💾 Managed Azure MySQL integration
- 🚀 Web frontend deployed using Azure Web App

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🚀 Live Demo <a name="live-demo"></a>

- [Frontend Web App](https://your-frontend-url.azurewebsites.net)
- [API Endpoint (behind Load Balancer)](http://your-lb-ip-or-dns)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 💻 Getting Started <a name="getting-started"></a>

To get a local copy up and running, follow these instructions.

### Prerequisites

- Azure CLI (`az`)
- Terraform ≥ 1.5
- Ansible ≥ 2.15
- Python 3 with `msrestazure`, `azure-cli-core`, `requests`
- SSH key pair

### Setup

```bash
git clone https://github.com/your-username/azure-cloud-webapp-deploy.git
cd azure-cloud-webapp-deploy
```

## 📦 Provision Infrastructure (Terraform) <a name="terraform"></a>

1. Initialize Terraform:

```bash
cd terraform/
terraform init
```

2. Set your variables in `terraform.tfvars` or export them:

```bash
terraform plan -out plan.tfout
terraform apply "plan.tfout"
```

## ⚙️ Configure Services (Ansible) <a name="ansible"></a>

1. Install Azure collection:

```bash
ansible-galaxy collection install azure.azcollection
```

2. Run Ansible Playbooks:

```bash
cd ansible/
ansible-playbook -i inventory.ini site.yml
```

## 🚢 Deployment <a name="deployment"></a>

- API is reachable via Load Balancer Public IP.
- Web frontend is served via Azure Web App.
- All backend components connect to Azure MySQL securely.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 👥 Authors <a name="authors"></a>

👤 **Your Name**

- GitHub: [@yourhandle](https://github.com/yourhandle)
- LinkedIn: [Your Profile](https://linkedin.com/in/yourhandle)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🔭 Future Features <a name="future-features"></a>

- [ ] Add CI/CD pipeline with GitHub Actions
- [ ] Enable autoscaling for the API tier
- [ ] Implement managed identity-based DB auth

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues, and feature requests are welcome!

Feel free to open an issue or submit a pull request.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## ⭐️ Show your support <a name="support"></a>

If you like this project, please ⭐️ the repository and share it with others!

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🙏 Acknowledgements <a name="acknowledgements"></a>

- Microsoft Azure documentation
- Ansible Azure Collection contributors
- HashiCorp Terraform Modules

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## ❓ FAQ <a name="faq"></a>

- **Can I deploy this to a different region?**
  - Yes, update the `location` variable in Terraform and Ansible inventory.

- **What if I want to use a container instead of a VM for the API?**
  - You can replace the VM setup with Azure Container Instances or Azure Kubernetes Service.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 📝 License <a name="license"></a>

This project is licensed under the [MIT License](./LICENSE).

<p align="right">(<a href="#readme-top">back to top</a>)</p>