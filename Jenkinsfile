properties([parameters([string(description: 'Docker image to use', name: 'dockerImage')])])

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo "Building change ${env.CHANGE_ID} and creating build: ${env.BUILD_ID}"
                echo "Using image: ${dockerImage}"
                sh 'kubectl apply -f servicea.yaml'
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