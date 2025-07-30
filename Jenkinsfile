pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
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
                bat 'terraform plan -var-file=terraform.tfvars'
            }
        }

        stage('Terraform Plan - Prod') {
            when {
                branch 'prod'
            }
            steps {
                bat 'terraform plan -var-file=terraform.tfvars'
            }
        }

        stage('Terraform Plan - Main') {
            when {
                branch 'main'
            }
            steps {
                bat 'terraform plan -var-file=terraform.tfvars'
            }
        }
    }
}
