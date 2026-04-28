@Library('my-shared-library') _
def failedStage = "Unknown"

pipeline {
    agent { label 'linux-agent' }

    environment {
        SLACK_WEBHOOK = credentials('slack-webhook')
    }

    stages {
        stage('Checkout') {
            steps {
                script { failedStage = 'Checkout' }
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script { failedStage = 'Build' }
                dir('app') {
                    sh 'docker build -t my-app-image .'
                }
            }
        }

        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        script { failedStage = 'Unit Tests' }
                        dir('app') {
                            sh 'npm install'
                            sh 'npm run test:unit'
                            junit 'junit-unit.xml'
                        }
                    }
                }
                stage('Integration Tests') {
                    steps {
                        script { failedStage = 'Integration Tests' }
                        dir('app') {
                            sh 'npm install'
                            sh 'npm run test:integration'
                            junit 'junit-integration.xml'
                        }
                    }
                }
            }
        }

        stage('Package') {
            steps {
                script { failedStage = 'Package' }
                dir('app') {
                    sh 'docker tag my-app-image my-app-image:latest'
                }
            }
        }

        stage('Deploy') {
            steps {
                script { failedStage = 'Deploy' }
                echo 'Deploying...'
            }
        }
    }

    post {
        always {
            notifySlack(message: "Build ${currentBuild.fullDisplayName} finished with status: ${currentBuild.currentResult}")
        }
    }
}
