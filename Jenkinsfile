
pipeline {
    agent any
    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        IMAGE_NAME = 'acrfznilp.azurecr.io/peterj/service-a:'
    }
    stages {
        stage('Prepare yaml file') {
            steps {
                echo "Preparing YAML file"
                sh "sed -ie 's~IMAGENAME~${env.IMAGE_NAME}${env.BUILD_NUMBER}~g' servicea.yaml"
            }
        }
        stage('Deploy') {
            steps {
                echo "Deploying image ${env.IMAGE_NAME}${env.BUILD_NUMBER}"
                sh '''kubectl apply -f servicea.yaml'''
            }
        }
    }
}