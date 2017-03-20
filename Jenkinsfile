pipeline {
    agent { docker 'node:6.3' }
    stages {
        stage('Create Docker Image') {
            steps {
                docker.build 'myimagetest'
            }
        }
    }
}