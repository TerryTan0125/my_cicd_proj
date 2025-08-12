# 使用官方 Tomcat 和 OpenJDK 11
FROM tomcat:9.0-jdk11-openjdk

# 删除默认 webapps 下内容（可选）
RUN rm -rf /usr/local/tomcat/webapps/*

# 拷贝构建好的 war 到 ROOT.war
COPY app/target/my_cicd_proj.war /usr/local/tomcat/webapps/ROOT.war

# 容器暴露端口
EXPOSE 8080

# 启动 tomcat（镜像已有 entrypoint）
