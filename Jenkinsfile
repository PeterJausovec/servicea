pipeline {
    agent { docker 'node:6.3' }
    stages {
        stage('Create Docker Image') {
            steps {
                sh 'docker build -t someImage:${env.BUILD_NUMBER}'
            }
        }
    }
}