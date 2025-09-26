# 🚀 Terraform CI/CD Project: NGINX Web Server

This is a **Terraform** project designed to deploy a basic **NGINX web server** on **AWS**. It sets up the core infrastructure necessary to integrate with a **CI/CD pipeline** (like GitHub Actions).

---

## 💡 Overview

The infrastructure deployed includes:

* **VPC, Subnet, and Internet Gateway:** A complete, isolated network environment for the web server.
* **IAM Role:** An **OpenID Connect (OIDC)** based role (`github-actions-deployer`) configured for secure deployment using **GitHub Actions**.
* **Security Group:** Allows essential inbound traffic: **Port 80 (HTTP)** and **Port 22 (SSH)**.
* **EC2 Instance:** The instance that runs the web server. It uses `user_data` to automatically install and start **NGINX** upon creation.
* **SSH Key Pair:** The `my-ec2-key` is uploaded to AWS for secure SSH access to the instance.

---

## 🛠️ Prerequisites

Before running this project, ensure you have:

1.  **Terraform CLI:** Installed on your local machine.
2.  **AWS CLI:** Installed and configured with a profile that has administrative permissions.
3.  **SSH Key Pair:** A public key file named **`id_rsa.pub`** must be present in this project directory. (You have already done this step!)

---

## 📂 Project Files

| File Name | Description |
| :--- | :--- |
| `main.tf` | The main configuration file defining all AWS resources (VPC, EC2, IAM, Security Group, etc.). |
| `outputs.tf` | Defines the ARN of the IAM role and the Public IP of the web server for easy access after deployment. |
| `variables.tf` | Defines environment-specific inputs like the AWS region and instance type. |
| `README.md` | **This documentation file.** |

---

## ▶️ Usage (Deployment Steps)

Follow these steps to deploy the infrastructure:

### 1. Initialize Terraform

Run this command to initialize the project and download the necessary AWS provider plugins.

```bash
terraform init
