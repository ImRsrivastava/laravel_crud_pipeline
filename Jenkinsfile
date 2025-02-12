pipeline {
    agent any

    environment {
        DEPLOY_DIR = "/var/www/html/Laravel_crud/"
        GIT_BRANCH = "master"
        GIT_URL="git@github.com:ImRsrivastava/laravel_crud_pipeline.git"
        SSH_CREDENTIALS_ID="1bc17c08-fe4d-44c8-a122-d87fbcc4b8e1"
        EC2_SERVER_IP="65.0.87.60"
        DB_ROOT_PASSWORD="root"
        DB_NAME="laravel_crud"
        DB_USER = "root"
        DB_PASSWORD = "root"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: "${GIT_BRANCH}", url: "${GIT_URL}"
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'composer install --no-dev --optimize-autoloader'
            }
        }

        stage('Run Tests') {
            steps {
                sh './vendor/bin/phpunit'
            }
        }

        stage('Database Setup') {
            steps {
                sshagent(credentials: ["${SSH_CREDENTIALS_ID}"]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} << EOF
                        echo "Setting up MySQL database..."
                        mysql -u root -p'${DB_ROOT_PASSWORD}' -e "
                        CREATE DATABASE IF NOT EXISTS ${DB_NAME};
                        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
                        GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
                        FLUSH PRIVILEGES;"
                        EOF
                    """
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: ["${SSH_CREDENTIALS_ID}"]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} << EOF
                        echo "Deploying Laravel application..."
                        cd ${DEPLOY_DIR} || exit
                        git pull
                        composer install --no-dev --optimize-autoloader
                        php artisan migrate --force
                        php artisan config:cache
                        php artisan route:cache
                        php artisan view:cache
                        sudo service apache2 restart
                        EOF
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed. Check the logs for more details."
        }
    }
}

// https://www.youtube.com/watch?v=5GtH-nDEEK8