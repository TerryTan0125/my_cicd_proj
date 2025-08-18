def tag = ""
pipeline {
    agent { label 'cicd-agent' } // 替换成你已有 agent 的 label
    
    environment {
      SONARQUBE_ENV = 'SonarQube'
      IMG_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/terrytan0125/my_cicd_proj.git'
            }
        }
	stage('Code Analysis (SonarQube)') {
	    steps {
	        container('maven-container') {
	            withSonarQubeEnv('MySonarQube') {
	                sh 'mvn -f app/pom.xml clean verify sonar:sonar -Dsonar.projectKey=my_cicd_proj'
	            }
	        }
	    }
	}
	stage('Run Unit Tests') {
	    steps {
	        container('maven-container') {
	            sh 'mvn -f app/pom.xml test'
	        }
	    }
	}

        stage('Build WAR') {
            steps {
                container('maven-container') {
                    sh 'mvn -f app/pom.xml clean package -DskipTests'
                }
            }
        }

        stage('Build & Push Image (kaniko)') {
            steps {
                container('kaniko-container') {
                    script {
                        tag = env.GIT_COMMIT ? env.GIT_COMMIT.take(6) : "latest" + "-${env.BUILD_NUMBER}"
                        //def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        //def tag = commitId ?: "TERRY" + "-${env.BUILD_NUMBER}"
			//env.IMG_TAG = tag
                        sh """
                          /kaniko/executor \
                            --context=dir://${WORKSPACE} \
                            --dockerfile=${WORKSPACE}/Dockerfile \
                            --destination=terrytan0125/my_cicd_proj:${tag} \
                            --verbosity=info \
                            --cleanup
                        """
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                container('jnlp') {
                    sh """
                      cd terraform
                      terraform init -input=false
		      # terraform refresh -var="image=terrytan0125/my_cicd_proj:${env.IMG_TAG}"  # 同步远程 state
                      terraform apply -auto-approve -var="image=terrytan0125/my_cicd_proj:${tag}"
                    """
                }
            }
        }

        stage('Done') {
            steps {
                echo "Pipeline finished. If everything OK, service should be created in namespace my-cicd."
            }
        }
    }
}
