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

                    echo Azure login succeeded!
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
  name     = "jenkins-demo-rg"
  location = "East US"
}
'''
                writeFile file: 'terraform.tfvars', text: ''
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
