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

#可执行镜像 考虑到线上bug调优，可使用jdk
FROM openjdk:8-jre-alpine
#从打包阶段复制jar包到当前阶段
COPY --from=buildapp /app/target/*.jar /app.jar
#时区设置 touch后可保留复制的时间
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && touch /app.jar
LABEL maintainer="XXX"

# java虚拟机命令
ENV JAVA_OPTS=""
#可以传spring 和shell命令
ENV PARAMS=""
#docker run -e JAVA_OPTS="-Xms512m -Xms33" -e  PARAMS="--spring.profiles.active=prod >/dev/null 2>&1 &"
# 运行jar包
ENTRYPOINT [ "sh", "-c", "java -Djava.security.egd=file:/dev/./urandom $JAVA_OPTS -jar /app.jar $PARAMS" ]