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

        stage('Debug Branch') {
            steps {
                echo "Current branch is: ${env.BRANCH_NAME}"
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

        stage('Terraform Init') {
            steps {
                bat 'terraform init'
            }
        }

        stage('Terraform Plan - Dev') {
            when {
                expression { env.BRANCH_NAME == 'dev' }
            }
            steps {
                bat "terraform plan -var-file=%TF_VAR_FILE%"
            }
        }

        stage('Terraform Plan - Prod') {
            when {
                expression { env.BRANCH_NAME == 'prod' }
            }
            steps {
                bat "terraform plan -var-file=%TF_VAR_FILE%"
            }
        }

        stage('Terraform Plan - Main') {
            when {
                expression { env.BRANCH_NAME == 'main' }
            }
            steps {
                bat "terraform plan -var-file=%TF_VAR_FILE%"
            }
        }
    }
}
