pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building ${env.BUILD_ID}'
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