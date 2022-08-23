FROM debian:stable
LABEL maintainer="lucas"

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
  apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends apt-transport-https ca-certificates locales fonts-wqy-microhei fonts-wqy-zenhei build-essential git cmake ninja-build libssl-dev libsdl-dev libavcodec-dev libavutil-dev libsrtp2-dev ffmpeg openjdk-11-jre maven nodejs npm && \
  apt-get autoremove --purge -y && apt-get clean -y && rm -rf /var/lib/apt/lists && \
  sed -i -e 's|^#\s*zh_|zh_|g' -e 's|^#\s*en_US|en_US|g' /etc/locale.gen && \
  locale-gen
RUN mkdir -p /root/src && cd /root/src && \
  git clone --depth 1 https://gitee.com/xia-chu/ZLMediaKit && cd ZLMediaKit && git submodule update --init && \
  mkdir build && cd build && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. && ninja && mv ../release/linux/Release /usr/local/lib/ZLMediaKit && \
  rm -rf /var/www && mv /usr/local/lib/ZLMediaKit/www /var && ln -sf /var/www /usr/local/lib/ZLMediaKit && \
  cd /usr/local/bin && ln -sf ../lib/ZLMediaKit/MediaServer . && \
  rm -rf /root/src
RUN mkdir -p /usr/local/lib/ZLMediaKit/www/record /root/src /usr/local/lib/wvp-assist && cd /root/src && \
  git clone https://gitee.com/pan648540858/wvp-pro-assist && cd wvp-pro-assist && \
  mvn compile && mvn package && mv target/*.jar /usr/local/lib/wvp-assist && \
  rm -rf /root/src
RUN mkdir -p /root/src && cd /root/src && git clone https://gitee.com/pan648540858/wvp-GB28181-pro.git && \
  cd wvp-GB28181-pro/web_src && npm --registry=https://registry.npm.taobao.org install && npm run build && \
  cd /root/src/wvp-GB28181-pro && mvn package && \
  mkdir -p /usr/local/lib/wvp && mv src/main/resources/application-docker.yml /usr/local/lib/wvp/application.yml && \
  mv target/wvp-pro-*.jar /usr/local/lib/wvp && \
  rm -rf /root/src

RUN sed -i -e 's|mediaServerId.*|mediaServerId=zlm-0000|g' /usr/local/lib/ZLMediaKit/config.ini && \
  sed -i -e 's|jdbc:mysql://127\.0\.0\.1:3306|jdbc:mysql://${MYSQL_HOST:127\.0\.0\.1}:${MYSQL_PORT:3306}|g' -e 's|password: root|password: ${MYSQL_PWD:root}|g' -e 's|${REDIS_PWD:root}|${REDIS_PWD:}|g' /usr/local/lib/wvp/application.yml && \
  sed -E -i -e 's|\s{4}id:\s*$|    id: zlm-0000|g' /usr/local/lib/wvp/application.yml

ENV LC_ALL=zh_CN.UTF-8

CMD MediaServer & java -jar /usr/local/lib/wvp-assist/*.jar --userSettings.record=/usr/local/lib/ZLMediaKit/www/record/ & cd /usr/local/lib/wvp && java -jar wvp-pro-*.jar