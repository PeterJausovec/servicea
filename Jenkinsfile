pipeline {
    agent any
    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }
    stages {
        stage('Deploy') {
            steps {
                echo "Deplying to Kubernetes"
                sh '''kubectl apply servicea.yaml'''
            }
        }
    }
}