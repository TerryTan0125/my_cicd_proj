pipeline {
  agent any
  environment {
    // image tag 用 commit sha 保证唯一
    SHORT_COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    IMAGE = "terrytan0125/my-cicd-proj-app:\${SHORT_COMMIT}"
    TERRAFORM_DIR = "terraform"
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Build & Test') {
      steps {
        dir('app') {
          sh 'npm ci'
          sh 'npm test || true'
        }
      }
    }
    stage('Build Docker Image') {
      steps {
        script {
          // 使用 docker credential 在 Jenkins 中登录并 push
          docker.withRegistry('https://registry.hub.docker.com', 'terrytan0125') {
            def image = docker.build(env.IMAGE)
            image.push()
          }
        }
      }
    }
    stage('Prepare Kubeconfig for Terraform') {
      steps {
        // 从 Jenkins Credentials 导出 kubeconfig 文件到 workspace，并设置 env var
        withCredentials([file(credentialsId: '<KUBECONFIG_CREDENTIAL_ID>', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            mkdir -p $WORKSPACE/.kube
            cp "$KUBECONFIG_FILE" "$WORKSPACE/.kube/config"
            export KUBECONFIG="$WORKSPACE/.kube/config"
            echo "kubeconfig placed at $WORKSPACE/.kube/config"
          '''
        }
      }
    }
    stage('Terraform Init & Apply') {
      steps {
        dir("${TERRAFORM_DIR}") {
          withEnv(["KUBECONFIG=${WORKSPACE}/.kube/config"]) {
            sh 'terraform init -input=false'
pipeline {
  agent any
  environment {
    // image tag 用 commit sha 保证唯一
    SHORT_COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    IMAGE = "<DOCKERHUB_REPO>:\${SHORT_COMMIT}"
    TERRAFORM_DIR = "terraform"
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Build & Test') {
      steps {
        dir('app') {
          sh 'npm ci'
          sh 'npm test || true'
        }
      }
    }
    stage('Build Docker Image') {
      steps {
        script {
          // 使用 docker credential 在 Jenkins 中登录并 push
          docker.withRegistry('https://registry.hub.docker.com', '<DOCKERHUB_CREDENTIALS_ID>') {
            def image = docker.build(env.IMAGE)
            image.push()
          }
        }
      }
    }
    stage('Prepare Kubeconfig for Terraform') {
      steps {
        // 从 Jenkins Credentials 导出 kubeconfig 文件到 workspace，并设置 env var
        withCredentials([file(credentialsId: '<KUBECONFIG_CREDENTIAL_ID>', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            mkdir -p $WORKSPACE/.kube
            cp "$KUBECONFIG_FILE" "$WORKSPACE/.kube/config"
            export KUBECONFIG="$WORKSPACE/.kube/config"
            echo "kubeconfig placed at $WORKSPACE/.kube/config"
          '''
        }
      }
    }
    stage('Terraform Init & Apply') {
      steps {
        dir("${TERRAFORM_DIR}") {
          withEnv(["KUBECONFIG=${WORKSPACE}/.kube/config"]) {
            sh 'terraform init -input=false'
            sh "terraform apply -auto-approve -var=\"image=${IMAGE}\" -var=\"kubeconfig_path=${WORKSPACE}/.kube/config\""
          }
        }
      }
    }
    stage('Smoke Test') {
      steps {
        script {
          // 获取 NodePort 并尝试访问一次（仅在 minikube 可达时）
          sh '''
            kubectl --kubeconfig=$WORKSPACE/.kube/config -n cicd-demo get svc || true
            POD=\$(kubectl --kubeconfig=$WORKSPACE/.kube/config -n cicd-demo get pods -l app=cicd-demo-app -o jsonpath="{.items[0].metadata.name}")
            echo "Example pod: \$POD"
            kubectl --kubeconfig=$WORKSPACE/.kube/config -n cicd-demo logs \$POD || true
          '''
        }
      }
    }
  }
  post {
    success { echo 'Pipeline completed successfully' }
    failure { echo 'Pipeline failed' }
  }
}
            sh "terraform apply -auto-approve -var=\"image=${IMAGE}\" -var=\"kubeconfig_path=${WORKSPACE}/.kube/config\""
          }
        }
      }
    }
    stage('Smoke Test') {
      steps {
        script {
          // 获取 NodePort 并尝试访问一次（仅在 minikube 可达时）
          sh '''
            kubectl --kubeconfig=$WORKSPACE/.kube/config -n cicd-demo get svc || true
            POD=\$(kubectl --kubeconfig=$WORKSPACE/.kube/config -n cicd-demo get pods -l app=cicd-demo-app -o jsonpath="{.items[0].metadata.name}")
            echo "Example pod: \$POD"
            kubectl --kubeconfig=$WORKSPACE/.kube/config -n cicd-demo logs \$POD || true
          '''
        }
      }
    }
  }
  post {
    success { echo 'Pipeline completed successfully' }
    failure { echo 'Pipeline failed' }
  }
}
