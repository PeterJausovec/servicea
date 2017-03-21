pipeline {
    agent any
    environment {
        KUBECONFIG = '/home/azureuser/.kube/config'
    }
    stages {
        stage('Build') {
            steps {
                echo "Building change ${env.CHANGE_ID} and creating build: ${env.BUILD_ID}"
                sh '''kubectl config current-context'''
            }
        }
        stage('Test') {
            steps {
                echo 'Testing'
            }
        }
        stage('Manual Intervention') {
            steps {
                input 'Deploy the service?'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying'
            }
        }
    }
}