pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo "Building change ${env.CHANGE_ID} and creating build: ${env.BUILD_ID}"
                sh returnStdout: true, script: '''kubectl get pods
                '''
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