pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id') 
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {
        stage('Terraform Init') {
            steps {
                dir('infastructura/terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan & Apply') {
            steps {
                dir('infastructura/terraform') {
                    sh '''
                        terraform plan -var="aws_access_key=$AWS_ACCESS_KEY_ID" -var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" -no-color
                        terraform apply -var="aws_access_key=$AWS_ACCESS_KEY_ID" -var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" -no-color -auto-approve
                    '''
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('infastructura/ansible') {
                    sh '''
                        ansible-playbook -i ../terraform/aws_hosts --key-file Key_For_CI-CD-proj.pem grafana.yml
                    '''
                }
            }
        }
    }
