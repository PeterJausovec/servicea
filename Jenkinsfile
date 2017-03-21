parameters {
    string(name: 'IMAGE_NAME', defaultValue: 'acrfznilp.azurecr.io/peterj/service-a:1', description: 'Image to deploy:')
}
pipeline {
    agent any
    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }
    stages {
        stage('Prepare yaml file') {
            steps {
                echo "Preparing YAML file"
                echo '${params.IMAGE_NAME}'
                echo "${params.IMAGE_NAME}"
                sh """sed -ie 's/IMAGENAME/${params.IMAGE_NAME}/g' servicea.yaml"""
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying image ${params.IMAGE_NAME}'
                sh '''kubectl apply -f servicea.yaml'''
            }
        }
    }
}