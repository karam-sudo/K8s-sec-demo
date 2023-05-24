FROM  openjdk:21-slim-buster
EXPOSE 8090
ARG JAR_FILE=target/*.jar
RUN addgroup  pipeline && useradd  k8s-pipeline -G pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
USER k8s-pipeline
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]


    