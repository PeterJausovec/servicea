properties([parameters([string(defaultValue: 'Hello', description: 'How should I greet the world?', name: 'Greeting')])])

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo "Building change ${env.CHANGE_ID} and creating build: ${env.BUILD_ID}"
                echo "${Greeting} World!"
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