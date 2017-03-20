pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building ${env.BUILD.NUMBER}'
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

2B3CA2CV1AH317989