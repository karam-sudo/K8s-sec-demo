FROM  openjdk:21-slim-buster
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN groupadd  pipeline && adduser  k8s-pipeline  pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
USER k8s-pipeline
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]


    