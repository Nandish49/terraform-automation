pipeline {
    agent any

    environment {
        TF_VAR_FILE = "terraform.tfvars"
        AZURE_SUBSCRIPTION_ID = "cd70a161-3537-4b00-bb7b-13e422cbcc98"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Branch') {
            steps {
                script {
                    env.ACTUAL_BRANCH = (env.GIT_BRANCH ?: env.BRANCH_NAME).replaceFirst(/^origin\//, '').toLowerCase()
                    echo "Detected branch: ${env.ACTUAL_BRANCH}"
                }
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

                    echo Setting Azure subscription...
                    az account set --subscription %AZURE_SUBSCRIPTION_ID%
                    az account show
                '''
            }
        }

        stage('Write Terraform Files') {
            steps {
                writeFile file: 'main.tf', text: '''
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

        stage('Terraform Plan and Apply') {
            when {
                expression {
                    def branch = (env.GIT_BRANCH ?: env.BRANCH_NAME)?.replaceFirst(/^origin\//, '')?.toLowerCase()
                    return ['dev', 'main', 'prod'].contains(branch)
                }
            }
            steps {
                script {
                    echo "Running Terraform on branch: ${env.ACTUAL_BRANCH}"
                    bat "terraform plan -var-file=%TF_VAR_FILE%"
                    bat "terraform apply -auto-approve -var-file=%TF_VAR_FILE%"
                }
            }
        }
    }
}
