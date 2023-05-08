pipeline {
  agent any
 environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "kalhalabi/numeric-app:${GIT_COMMIT}"
    applicationURL="http://devsecops-demo.eastus.cloudapp.azure.com"
    applicationURI="/increment/99"
    }
  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
      stage('Unit Tests , JUnit and Jacoco') {
            steps {
              sh "mvn test"   
            }
      }

      stage('Mutation Test - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage" 
            }
      }
      
   
      stage('SonarQube Analysis') {
      
        steps {
          withSonarQubeEnv(installationName: 'sonarqube'){
          sh "mvn clean verify sonar:sonar -Dsonar.projectKey=devsecops -Dsonar.projectName='devops'"
          }
          // timeout(time:2, unit:MINUTES){
          //   script{
          //     waitForQualityGate abortPipeline: true, credentialsId: 'jenkinsCred'
          //   }
          // }
        }
    
      }

      // stage('Vulnerability Scan - Docker') {
      //       steps {
      //         sh "mvn dependency-check:check"
      //       }
      // }

      stage('Vulnerability Scan - Docker') {
        steps {
          parallel(
            "Dependency Scan": {
              sh "mvn dependency-check:check"
        },
        // "Trivy Scan":{
        //   sh "bash trivy-docker-image-scan.sh"
        // },
        "OPA Conftest":{
             sh ' sudo docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
          }   	
        )
        }
      }
 

      stage('Docker Build and Push') {
        steps {
          withCredentials([string(credentialsId: "dockerhub", variable: "TOKEN")]) {
            sh 'printenv'
            sh 'sudo docker login -u kalhalabi -p $TOKEN'
            sh 'sudo docker build -t kalhalabi/numeric-app:""$GIT_COMMIT"" .'
            sh 'sudo docker push kalhalabi/numeric-app:""$GIT_COMMIT""'
          }
        }
      }

      stage('Vulnerability Scan - Kubernetes') {
            steps {
            sh 'sudo docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            }
      }

      stage('Kubernetes Deployment - DEV') {
        steps {
          withKubeConfig([credentialsId: 'minikube-configfile']) {
            sh "sed -i 's#replace#kalhalabi/numeric-app:$GIT_COMMIT#g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
    //   stage('K8S Deployment - DEV') {
    //   steps {
    //     parallel(
    //       "Deployment": {
    //         withKubeConfig([credentialsId: 'minikube-configfile']) {
    //           sh "bash k8s-deployment.sh"
    //         }
    //       },
    //       "Rollout Status": {
    //         withKubeConfig([credentialsId: 'minikube-configfile']) {
    //           sh "bash k8s-deployment-rollout-status.sh"
    //         }
    //       }
    //     )
    //   }
    // }

}
  post{
        always{
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
      }
}