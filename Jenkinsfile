
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
                    env.STABLE_SERVICE_EXISTS = false;
                    try {
                        env.EXISTING_SERVICE_NAME = sh "kubectl get --selector=run=${params.SERVICE_NAME}-stable -o jsonath='{.items[0].metadata.name}'"
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
                    sleep(120000)

                    echo "Rolling out canary version to 10% of users..."
                    sh "kubectl annotate --overwrite service ${params.SERVICE_NAME} l5d=\"90*/label/track/stable/${params.SERVICE_NAME} & 10*/label/track/canary/${params.SERVICE_NAME}\""
                    sleep(120000)

                    echo "Rolling out canary version to 25% of users..."
                    sh "kubectl annotate --overwrite service ${params.SERVICE_NAME} l5d=\"75*/label/track/stable/${params.SERVICE_NAME} & 25*/label/track/canary/${params.SERVICE_NAME}\""
                    sleep(120000)

                    echo "Rolling out canary version to 50% of users..."
                    sh "kubectl annotate --overwrite service ${params.SERVICE_NAME} l5d=\"50*/label/track/stable/${params.SERVICE_NAME} & 50*/label/track/canary/${params.SERVICE_NAME}\""
                    sleep(120000)

                    echo "Rolling out canary version to 100% of users..."
                    sh "kubectl annotate --overwrite service ${params.SERVICE_NAME} l5d=/svc/${params.SERVICE_NAME}-${params.IMAGE_TAG}"

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
            sh "kubectl delete deployment,service -l run=${params.SERVICE_NAME}-canary"
        }
        success {
            echo "Deployment succeeded."
        }
        failure {
            echo "Failure - removing all services (logical, canary, stable)"
            sh "kubectl delete deployment,service -l run=${params.SERVICE_NAME}"
            sh "kubectl delete deployment,service -l run=${params.SERVICE_NAME}-canary"
            sh "kubectl delete deployment,service -l run=${params.SERVICE_NAME}-stable"
        }
    }
}


// 1. Create a logical service over the linkerd service: 
// kubectl expose deployment l5d --name=service-b --port=80
// export SERVICE_B=$(kubectl get service service-b -o go-template={{.spec.clusterIP}})

// 2. Deploy and expose a version of the service:
// kubectl run service-b-STABLE --image=[imagename] --port=80 && \
// kubectl expose deployment service-b-STABLE -l via=service-b,track=stable,run=service-b-STABLE --port=80 && \
// export SERVICE_B_STABLE=$(kubectl get service servie-b-STABLE -o go-template={{.spec.clusterIP}})
// WAIT FOR SERVICE TO BE EXPOSED - you can curl now to the SERVICE_B_STABLE 

// 3. Annotate the logical service with the service we deployed 
// kubectl annotate service service-b l5d=/svc/service-b-STABLE

// Now you can curl to the logical service: curl SERVICE_B

// 4. Deploy the canary (just like step 2 above) version:
// kubectl run service-b-CANARY --image=[image] --port=80 &&\
// kubectl expose deployment service-b-CANARY -l via=service-b,track=canary,run=serviec-b-CANARY --port=80 && \
// export SERVICE_B_CANARY =...


// 5. curl to logical service and pass in a special linkerd header:
// curl $SERVICE_B -H "l5d-dtab: /host/service-b => /svc/service-b-CANARY"  
//                  or
// curl $SERVICE_B -H "l5d-dtab: /host => /label/track/canary"


// %-based rollouts 
// 1. rollout canary version to 5% of users:
// kubectl annotate --overwrite service service-b l5d="95*/label/track/stable/service-b & 5*/label/track/canary/service-b"

// 2. complete the rollout:
// kubectl annotate --overwrite service sevrvice-b l5d=/svc/service-b-CANARY

// 3. Delete the original deployment and service
// kubectl delete deployment, service -l run=service-b-STABLE 

// 4. Re-label the canary as stable track:
// kubectl label --overwrite service service-b-CANARY track=stable
