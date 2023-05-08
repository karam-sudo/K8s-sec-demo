FROM  openjdk:21-slim-buster
EXPOSE 8080
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /home/devops/app.jar
USER devops
ENTRYPOINT ["java","-jar","/home/devops/app.jar"]


    