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
                        tag = env.GIT_COMMIT ? env.GIT_COMMIT.take(6) : "latest"
			tag = "${tag}-${env.BUILD_NUMBER}"
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

        stage('Terraform Apply to dev') {
            steps {
                container('jnlp') {
		  script {	
		    def statetf = "/home/jenkins/terraform-state/dev/terraform.tfstate"
                    sh """
                      cd terraform
                      terraform init -backend-config="path=${statetf}" -input=false
		      # terraform refresh -var="image=terrytan0125/my_cicd_proj:${env.IMG_TAG}"  # 同步远程 state
                      terraform apply -auto-approve -var="namespace=dev" -var="nodeport=30082" -var="image=terrytan0125/my_cicd_proj:${tag}"
                    """
		  }
                }
            }
        }
        stage('Terraform Apply to QA') {
            steps {
                container('jnlp') {
		  script {
		    def statetf = "/home/jenkins/terraform-state/qa/terraform.tfstate"
                    sh """
                      cd terraform
                      terraform init -backend-config="path=${statetf}" -input=false
                      # terraform refresh -var="image=terrytan0125/my_cicd_proj:${env.IMG_TAG}"  # 同步远程 state
                      terraform apply -auto-approve -var="namespace=qa"  -var="nodeport=30085" -var="image=terrytan0125/my_cicd_proj:${tag}"
                    """
		  }
                }
            }
        }
        stage('Terraform Apply to prod') {
            steps {
                container('jnlp') {
		  script {
		    def statetf = "/home/jenkins/terraform-state/prod/terraform.tfstate"
                    sh """
                      cd terraform
                      terraform init -backend-config="path=${statetf}" -input=false
                      # terraform refresh -var="image=terrytan0125/my_cicd_proj:${env.IMG_TAG}"  # 同步远程 state
                      terraform apply -auto-approve -var="namespace=prod" -var="nodeport=30090" -var="image=terrytan0125/my_cicd_proj:${tag}"
                    """
		  }
                }
            }
        }
        stage('Done') {
            steps {
                echo "Pipeline finished. service should be created in namespace dev/QA/Prod."
            }
        }
    }
}
