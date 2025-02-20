pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "rishabh0205/apache-laravel"
        DOCKER_IMAGE_TAG = '1.0'
        DOCKER_HUB_CREDENTIAL_ID = "81a2124b-a0e6-497d-8053-04ea733ed7ed"
        
        PROJECT_CONTAINER_NAME = "laravel_crud_project"
        MYSQL_CONTAINER_NAME = "laravel_crud_mysql"
        
        GIT_CREDENTIAL_ID = "f08df267-9e79-4788-afa1-5e5deca96b63"
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
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIAL_ID}", 
                                                     passwordVariable: 'DOCKER_PASSWORD', 
                                                     usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}"
                    }
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

        stage('Install Dependencies') {
            steps {
                script {
                    // This ensures that if a volume mount overrides your code, the container installs the vendor dependencies.
                    sh "docker exec -i ${PROJECT_CONTAINER_NAME} composer install --ignore-platform-reqs --no-dev"
                }
            }
        }

        stage('Run Migrations & Clear Cache') {
            steps {
                script {
                    sh "docker exec -i ${PROJECT_CONTAINER_NAME} php artisan migrate --force"
                    sh "docker exec -i ${MYSQL_CONTAINER_NAME} php artisan cache:clear"
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
