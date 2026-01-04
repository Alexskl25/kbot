pipeline {
    agent any
    
    environment {
        REPO = 'https://github.com/Alexskl25/kbot'
        BRANCH = 'main'
        GITHUB_TOKEN = credentials('G_PSW')
    }

    stages {

        stage('clone') {
            steps {
                echo 'Clone Repository'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }

        stage('test') {
            steps {
                echo 'Testing started'
                sh "make test"
            }
        }

        stage('build') {
            steps {
                echo "Building binary started"
                sh "make build"
            }
        }

        stage('image') {
            steps {
                echo "Building image started"
                sh "make image"
            }
        }

        stage('login to GHCR') {
            steps {
                sh "echo $GITHUB_TOKEN | docker login ghcr.io -u Alexskl25 --password-stdin"
            }
        }
        
        stage('push image') {
            steps {
              sh "make push"
            }
        } 
    }
}