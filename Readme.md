# ⚙️ Zero-Touch, Zero-Worries: How I Automated CyPerf Deployment & Testing in AWS With Just Terraform & Python

Manual deployments are a thing of the past — especially when testing high-performance applications like **CyPerf**.

In this project, I built a **Zero-Touch automation pipeline** using **Terraform** and **Python** to deploy a complete **CyPerf-CE** test environment across multiple **AWS regions**.

---

## 🚀 Key Features

- 🌐 Custom **VPCs and subnets** with full routing and **VPC peering**
- 🖥️ EC2 instances optimized for **high throughput** with **Enhanced Networking (ENA)**
- 🔐 Fully configured **Security Groups** and **User Data scripts**
- 🧪 Python-based **Test Runner** with a config file for end-to-end automation

---

## ✅ Benefits

- One-command deployment of your **CyPerf testbed**
- No manual steps ❌
- No configuration drift ⚠️
- No waiting around ⏳
- Fully repeatable and scalable 💥

Whether you're:
- Validating **application throughput**
- Simulating **real-world traffic**
- Running **continuous performance benchmarks**

This setup gives you **speed, confidence, and consistency**.

---

## 🛠️ How to Run

### Step 1: Deploy Infrastructure

```bash
terraform init
terraform plan -out tfplan
terraform apply tfplan
