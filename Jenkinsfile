pipeline {
  agent any

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
          sh "mvn clean verify sonar:sonar -Dsonar.projectKey=devopsddddddddsadasdasdadasdadad -Dsonar.projectName='devops'"
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
        "Trivy Scan":{
          sh "bash trivy-docker-image-scan.sh"
        },
        "OPA Conftest":{
             sh 'sudo -S docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
          }   	
        )
        }
      }
 



      stage('Docker Build and Push') {
        steps {
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh 'sudo -S docker build -t kalhalabi/numeric-app:""$GIT_COMMIT"" .'
            // sh 'sudo docker push kalhalabi/numeric-app:""$GIT_COMMIT""'
          }
        }
      }

      stage('Vulnerability Scan - Kubernetes') {
            steps {
            sh 'sudo -S docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            }
      }

      stage('Kubernetes Deployment - DEV') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh "sed -i 's#replace#kalhalabi/numeric-app:$GIT_COMMIT#g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
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