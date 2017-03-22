
pipeline {
    agent any
    parameters {
        string(name:'REGISTRY_URL', defaultValue: 'acrfznilp.azurecr.io', description: 'docker image repository')
        string(name:'IMAGE_NAME', defaultValue: 'peterj/service-a', description: 'image name')
        string(name:'IMAGE_TAG', defaultValue:'1', description: 'image tag (should be build number)')
    }
    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }
    stages {
        stage ('Deploy prerequisites (l5d)') {
            steps {
                echo "Check if l5d is deployed yet"
                // Check if l5d is already deployed and 
                // deploy it if it isn't
            }
        }
        stage ('Deploy to Dev namespace') {
            steps {
                echo "Preparing YAML file"
                sh "sed -ie 's~IMAGENAME~${params.REGISTRY_URL}/${params.IMAGE_NAME}:${params.IMAGE_TAG}~g' servicea.yaml"

                echo "Deploying image ${params.REGISTRY_URL}/${params.IMAGE_NAME}:${params.IMAGE_TAG}"
                sh '''kubectl apply -f servicea.yaml'''

                script {
                    env.DEPLOY_TO_PROD = input message: 'Should continue deploying to Prod?', ok: 'Yes',
                                parameters: [choice(name: 'SHOULD_CONTINUE', choices: 'yes\nno', description: 'Should continue?')]
                }
                echo "${env.DEPLOY_TO_PROD}"
            }
        }
        stage ('Deploy to Prod namespace') {
            when {
                environment name: 'DEPLOY_TO_PROD', value: 'yes'
            }
            steps {
                echo 'deploying to prod'
            }
        }
    }
    post {
        always {
            echo "Deployment completed."
        }
        success {
            echo "Deployment succeeded."
        }
    }
}