# 实现从git拉取代码，maven构建工程 jre打包成镜像的功能  后续可使用gitadd 修改clone地址
#代码clone
FROM sombralibre/gitclient AS clonePro
RUN git config --global user.name "XXX" && git config --global user.email "XX@qq.com" && mkdir -p /app
WORKDIR /app
ARG gitadd="https://github.com/li-vc/demo.git"
RUN git clone ${gitadd} . && ls -l /app

#maven打包
FROM maven:3.6.1-jdk-8-alpine as buildapp
RUN mkdir -p /app
#从上一阶段复制工程文件  同一阶段改变目录使用RUN cp
COPY --from=clonePro /app/ /app/
WORKDIR /app
RUN mvn clean \
    install \
    package -Dmaven.test.skip=true

#可执行镜像
FROM openjdk:8-jre-alpine
#时区设置
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
LABEL maintainer="XXX"
#从打包阶段复制jar包到当前阶段
COPY --from=buildapp /app/target/*.jar /app.jar

ENV JAVA_OPTS=""
ENV PARAMS=""
# 运行jar包
ENTRYPOINT [ "sh", "-c", "java -Djava.security.egd=file:/dev/./urandom $JAVA_OPTS -jar /app.jar $PARAMS" ]