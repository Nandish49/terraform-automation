pipeline {
    agent any

    environment {
        AZURE_SUBSCRIPTION_ID = "cd70a161-3537-4b00-bb7b-13e422cbcc98"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Azure Login') {
            steps {
                bat '''
                    az login --service-principal ^
                        -u 766936bf-64f1-49ca-affe-baed2adaa01f ^
                        -p Z7t8Q~w2otLwa5tov-xMDO6rlZF_xNZlQIJgcdyK ^
                        --tenant f28f3563-ef6b-4fb2-aac1-327c53835bba

                    az account set --subscription %AZURE_SUBSCRIPTION_ID%
                '''
            }
        }

        stage('Write Terraform Files') {
            steps {
                writeFile file: 'main.tf', text: '''
terraform {
  backend "azurerm" {
    resource_group_name  = "jenkins-rg"
    storage_account_name = "jenkinsstorageacct01"
    container_name       = "jenkinscontainer"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "cd70a161-3537-4b00-bb7b-13e422cbcc98"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "East US"
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}
'''

                writeFile file: 'variables.tf', text: '''
variable "resource_group_name" { type = string }
variable "storage_account_name" { type = string }
variable "container_name" { type = string }
'''

                writeFile file: 'dev.tfvars', text: '''
resource_group_name   = "jenkins-rg-dev"
storage_account_name  = "jenkinsstorageacctdev"
container_name        = "jenkinscontainerdev"
'''

                writeFile file: 'main.tfvars', text: '''
resource_group_name   = "jenkins-rg-main"
storage_account_name  = "jenkinsstorageacctmain"
container_name        = "jenkinscontainermain"
'''

                writeFile file: 'prod.tfvars', text: '''
resource_group_name   = "jenkins-rg-prod"
storage_account_name  = "jenkinsstorageacctprod"
container_name        = "jenkinscontainerprod"
'''
            }
        }

        stage('Terraform Init') {
            steps {
                bat 'terraform init'
            }
        }

        // ===========================
        // DEV Branch
        // ===========================
        stage('Terraform Plan - Dev') {
            when { branch 'dev' }
            steps {
                bat "terraform plan -var-file=dev.tfvars"
            }
        }

        stage('Terraform Apply - Dev') {
            when { branch 'dev' }
            steps {
                bat "terraform apply -auto-approve -var-file=dev.tfvars"
            }
        }

        stage('Terraform Destroy - Dev') {
            when { branch 'dev' }
            steps {
                bat "terraform destroy -auto-approve -var-file=dev.tfvars"
            }
        }

        // ===========================
        // MAIN Branch
        // ===========================
        stage('Terraform Plan - Main') {
            when { branch 'main' }
            steps {
                bat "terraform plan -var-file=main.tfvars"
            }
        }

        stage('Approval - Main') {
            when { branch 'main' }
            steps {
                input message: 'Approve deployment to MAIN?', ok: 'Deploy'
            }
        }

        stage('Terraform Apply - Main') {
            when { branch 'main' }
            steps {
                bat "terraform apply -auto-approve -var-file=main.tfvars"
            }
        }

        stage('Terraform Destroy - Main') {
            when { branch 'main' }
            steps {
                bat "terraform destroy -auto-approve -var-file=main.tfvars"
            }
        }

        // ===========================
        // PROD Branch
        // ===========================
        stage('Terraform Plan - Prod') {
            when { branch 'prod' }
            steps {
                bat "terraform plan -var-file=prod.tfvars"
            }
        }

        stage('Approval - Prod') {
            when { branch 'prod' }
            steps {
                input message: 'Approve deployment to PROD?', ok: 'Deploy'
            }
        }

        stage('Terraform Apply - Prod') {
            when { branch 'prod' }
            steps {
                bat "terraform apply -auto-approve -var-file=prod.tfvars"
            }
        }
    }
}
