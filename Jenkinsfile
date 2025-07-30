pipeline {
    agent any

    environment {
        TF_VAR_FILE = "terraform.tfvars"
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
                    echo Logging into Azure using service principal...
                    az login --service-principal ^
                        -u 766936bf-64f1-49ca-affe-baed2adaa01f ^
                        -p Z7t8Q~w2otLwa5tov-xMDO6rlZF_xNZlQIJgcdyK ^
                        --tenant f28f3563-ef6b-4fb2-aac1-327c53835bba

                    if %ERRORLEVEL% NEQ 0 (
                        echo Azure login failed!
                        exit /b 1
                    )
                    az account show
                '''
            }
        }

        stage('Write Terraform Files') {
            steps {
                writeFile file: 'main.tf', text: '''
provider "azurerm" {
  features {}
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
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "container_name" {
  description = "Name of the storage container"
  type        = string
}
'''

                writeFile file: 'terraform.tfvars', text: '''
resource_group_name   = "jenkins-rg"
storage_account_name  = "jenkinsstorageacct01"
container_name        = "jenkinscontainer"
'''
            }
        }

        stage('Terraform Init') {
            steps {
                bat 'terraform init'
            }
        }

        stage('Terraform Plan - Dev') {
            when {
                branch 'dev'
            }
            steps {
                bat "terraform plan -var-file=%TF_VAR_FILE%"
            }
        }

        stage('Terraform Apply - Dev') {
            when {
                branch 'dev'
            }
            steps {
                bat "terraform apply -auto-approve -var-file=%TF_VAR_FILE%"
            }
        }

        stage('Terraform Plan - Prod') {
            when {
                branch 'prod'
            }
            steps {
                bat "terraform plan -var-file=%TF_VAR_FILE%"
            }
        }

        stage('Terraform Apply - Prod') {
            when {
                branch 'prod'
            }
            steps {
                bat "terraform apply -auto-approve -var-file=%TF_VAR_FILE%"
            }
        }

        stage('Terraform Plan - Main') {
            when {
                branch 'main'
            }
            steps {
                bat "terraform plan -var-file=%TF_VAR_FILE%"
            }
        }

        stage('Terraform Apply - Main') {
            when {
                branch 'main'
            }
            steps {
                bat "terraform apply -auto-approve -var-file=%TF_VAR_FILE%"
            }
        }
    }
}
