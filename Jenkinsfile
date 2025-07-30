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
                withCredentials([usernamePassword(credentialsId: 'azure-sp', usernameVariable: 'APP_ID', passwordVariable: 'PASSWORD')]) {
                    bat """
                        az logout
                        az login --service-principal -u %APP_ID% -p %PASSWORD% --tenant f28f3563-ef6b-4fb2-aac1-327c53835bba
                    """
                }
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

        stage('Terraform Plan - Prod') {
            when {
                branch 'prod'
            }
            steps {
                bat "terraform plan -var-file=%TF_VAR_FILE%"
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
    }
}
