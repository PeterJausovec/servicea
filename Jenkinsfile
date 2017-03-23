
pipeline {
    agent any
    parameters {
        string(name:'REGISTRY_URL', defaultValue: 'acrfznilp.azurecr.io', description: 'docker image repository')
        string(name:'IMAGE_NAME', defaultValue: 'peterj/service-a', description: 'image name')
        string(name:'IMAGE_TAG', defaultValue:'19', description: 'image tag (should be build number)')
        string(name:'SERVICE_NAME', defaultValue:'service-a', description: 'Service name that is being deployed')
    }
    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }
    stages {
        stage ('Deploy prerequisites (l5d)') {
            steps {
                echo "Deploy L5D"
                sh 'kubectl apply -f https://raw.githubusercontent.com/stepro/k8s-l5d/master/l5d.yaml'
            }
        }
        stage ('Create logical service') {
            steps {
                echo "Create a logical service for: ${params.SERVICE_NAME}"
                script {
                    try {
                        sh "kubectl expose deployment l5d --name=${params.SERVICE_NAME} --port=80"
                    } catch (exc) {
                        echo "Logical service ${params.SERVICE_NAME} exists"
                    }
                    env.LOGICAL_SERVICE_IP = sh(returnStdout: true, script: "kubectl get service ${params.SERVICE_NAME} -o go-template={{.spec.clusterIP}}")
                }
                echo "Logical service IP: ${env.LOGICAL_SERVICE_IP}"
            }
        }
        // Check if {service_name}-stable exists - if it doesn't, it's the first deployment
        stage ('Check for existing service') {
            steps {
                script {
                    env.STABLE_SERVICE_EXISTS = true;
                    try {
                        env.EXISTING_SERVICE_NAME = sh(returnStdout: true, script: "kubectl get service --selector=via=${params.SERVICE_NAME},track=stable -o jsonpath='{.items[0].metadata.name}'")
                    } catch (exc) {
                        env.STABLE_SERVICE_EXISTS = false;
                        env.EXISTING_SERVICE_NAME = '';
                    }
                }
            }
        }
        stage ('Check & deploy the stable service') {
            when {
                environment name: 'STABLE_SERVICE_EXISTS', value: 'false'
            }
            steps {
                // Stable service doesn't exist yet (first deployment)
                echo "Deploying the stable service image: ${params.REGISTRY_URL}/${params.IMAGE_NAME}:${params.IMAGE_TAG}"
                sh "kubectl run ${params.SERVICE_NAME}-${params.IMAGE_TAG} --image=${params.REGISTRY_URL}/${params.IMAGE_NAME}:${params.IMAGE_TAG} --port=80"
                sh "kubectl expose deployment ${params.SERVICE_NAME}-${params.IMAGE_TAG} -l via=${params.SERVICE_NAME},track=stable,run=${params.SERVICE_NAME}-${params.IMAGE_TAG} --port=80"
                sh "kubectl annotate service ${params.SERVICE_NAME} l5d=/svc/${params.SERVICE_NAME}-${params.IMAGE_TAG}"
                script {
                    // TODO: Wait for the service IP to become available
                    env.SERVICE_STABLE_IP=sh(returnStdout: true, script: "kubectl get service ${params.SERVICE_NAME}-${params.IMAGE_TAG} -o go-template={{.spec.clusterIP}}")
                }
                echo "STABLE SERVICE IP: ${env.SERVICE_STABLE_IP}"
            }
        }
        stage ('Check & deploy the canary service') {
            when {
                environment name: 'STABLE_SERVICE_EXISTS', value: 'true'
            }
            steps {
                // Stable service exists, deploy to canary
                echo 'Stable service exists - deploy the canary version'
                echo "Deploying the canary service image: ${params.REGISTRY_URL}/${params.IMAGE_NAME}:${params.IMAGE_TAG}"
                sh "kubectl run ${params.SERVICE_NAME}-${params.IMAGE_TAG} --image=${params.REGISTRY_URL}/${params.IMAGE_NAME}:${params.IMAGE_TAG} --port=80"
                sh "kubectl expose deployment ${params.SERVICE_NAME}-${params.IMAGE_TAG} -l via=${params.SERVICE_NAME},track=canary,run=${params.SERVICE_NAME}-${params.IMAGE_TAG} --port=80"
                script {
                    // TODO: Wait for the service IP to become available
                    env.SERVICE_CANARY_IP=sh(returnStdout: true, script: "kubectl get service ${params.SERVICE_NAME}-${params.IMAGE_TAG} -o go-template={{.spec.clusterIP}}")
                }
                echo "CANARY SERVICE IP: ${env.SERVICE_STABLE_IP}"
                script {
                    env.CANARY_ROLLOUT=true;
                }
            }
        }
        stage ('Canary Rollout') {
            when {
                environment name: 'CANARY_ROLLOUT', value: 'true'
            }
            steps {
                echo "Starting Canary Rollout"
                script {
                    echo "Rolling out canary version to 5% of users..."
                    sh "kubectl annotate --overwrite service ${params.SERVICE_NAME} l5d=\"95*/label/track/stable/${params.SERVICE_NAME} & 5*/label/track/canary/${params.SERVICE_NAME}\""
                    sleep 5

                    echo "Rolling out canary version to 10% of users..."
                    sh "kubectl annotate --overwrite service ${params.SERVICE_NAME} l5d=\"90*/label/track/stable/${params.SERVICE_NAME} & 10*/label/track/canary/${params.SERVICE_NAME}\""
                    sleep 5

                    echo "Rolling out canary version to 25% of users..."
                    sh "kubectl annotate --overwrite service ${params.SERVICE_NAME} l5d=\"75*/label/track/stable/${params.SERVICE_NAME} & 25*/label/track/canary/${params.SERVICE_NAME}\""
                    sleep 5

                    echo "Rolling out canary version to 50% of users..."
                    sh "kubectl annotate --overwrite service ${params.SERVICE_NAME} l5d=\"50*/label/track/stable/${params.SERVICE_NAME} & 50*/label/track/canary/${params.SERVICE_NAME}\""
                    sleep 5

                    echo "Rolling out canary version to 100% of users..."
                    sh "kubectl annotate --overwrite service ${params.SERVICE_NAME} l5d=/svc/${params.SERVICE_NAME}-${params.IMAGE_TAG}"

                    env.EXISTING_SERVICE_NAME = sh(returnStdout: true, script:"kubectl get service --selector=via=${params.SERVICE_NAME},track=stable -o jsonpath='{.items[0].metadata.name}'")
                    echo "Delete the original deployment: ${env.EXISTING_SERVICE_NAME}"
                    sh "kubectl delete deployment, service -l run=${env.EXISTING_SERVICE_NAME}"

                    echo "Re-label canary version as stable version"
                    sh "kubectl label --overwrite service ${params.SERVICE_NAME}-${params.IMAGE_TAG} track=stable"

                    // Dummy wait step
                    env.DEPLOY_TO_PROD = input message: 'Manual Judgement', ok:'Submit', parameters: [choice(name: 'Deploy to production?', choices: 'yes\nno', description: '')]
                }
            }
        }
    }
    post {
        always {
            echo "Deployment completed."
            echo "Deleting Canary service"
        }
        success {
            echo "Deployment succeeded."
        }
        failure {
            echo "Failure"
        }
    }
}