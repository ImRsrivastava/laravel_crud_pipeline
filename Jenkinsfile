pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "rishabh0205/apache-laravel"
        PROJECT_CONTAINER_NAME = "laravel_crud_project"
        MYSQL_CONTAINER_NAME = "laravel_crud_mysql"
        GIT_CREDENTIAL_ID = "5a46ae81-2440-482a-9298-ae51ee245343"
        GIT_BRANCH = 'master'
        GIT_REPO_URL = 'https://github.com/ImRsrivastava/laravel_crud_pipeline.git'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: "${GIT_BRANCH}", credentialsId: "${GIT_CREDENTIAL_ID}", url: "${GIT_REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    sh "echo '${env.DOCKER_HUB_PASSWORD}' | docker login -u '${env.DOCKER_HUB_USERNAME}' --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    sh "docker-compose down"
                    sh "docker-compose up --build -d"
                }
            }
        }

        stage('Run Migrations & Clear Cache') {
            steps {
                script {
                    sh "docker exec -i ${CONTAINER_NAME} php artisan migrate --force"
                    sh "docker exec -i ${CONTAINER_NAME} php artisan cache:clear"
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed! Check logs."
        }
    }
}
