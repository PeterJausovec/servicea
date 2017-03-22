
pipeline {
    agent any
    parameters {
        string(name:'IMAGE_NAME', defaultValue: 'peterj/service-a', description: 'image name')
        string(name:'IMAGE_TAG', defaultValue:'1', description: 'image tag (should be build number)')
    }
    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }
    stages {
        stage('Prepare yaml file') {
            steps {
                echo "Preparing YAML file"
                sh "sed -ie 's~IMAGENAME~${params.IMAGE_NAME}:${params.IMAGE_TAG}~g' servicea.yaml"
            }
        }
        stage('Deploy') {
            steps {
                echo "Deploying image ${params.IMAGE_NAME}:${params.IMAGE_TAG}"
                sh '''kubectl apply -f servicea.yaml'''
            }
        }
    }
}