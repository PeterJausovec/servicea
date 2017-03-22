
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
                echo "Deploy L5D"
                sh 'kubectl apply -f https://raw.githubusercontent.com/stepro/k8s-l5d/master/l5d.yaml'

                // Check if l5d is already deployed and 
                // deploy it if it isn't
            }
        }
        // stage ('Deploy to Dev namespace') {
        //     steps {
        //         echo "Preparing YAML file"
        //         sh "sed -ie 's~IMAGENAME~${params.REGISTRY_URL}/${params.IMAGE_NAME}:${params.IMAGE_TAG}~g' servicea.yaml"

        //         echo "Deploying image ${params.REGISTRY_URL}/${params.IMAGE_NAME}:${params.IMAGE_TAG}"
        //         sh '''kubectl apply -f servicea.yaml'''

        //         script {
        //             env.DEPLOY_TO_PROD = input message: 'Manual Judgement', ok:'Submit', parameters: [choice(name: 'Deploy to production?', choices: 'yes\nno', description: '')]
        //         }
        //         echo "${env.DEPLOY_TO_PROD}"
        //     }
        // }
        // stage ('Deploy to Prod namespace') {
        //     when {
        //         environment name: 'DEPLOY_TO_PROD', value: 'yes'
        //     }
        //     steps {
        //         echo 'deploying to prod'
        //     }
        // }
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
