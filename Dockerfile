FROM debian:stable
LABEL maintainer="lucas"

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone && \
  apt-get update && apt-get upgrade -y && apt-get install -y build-essential git cmake ninja-build libssl-dev libsdl-dev libavcodec-dev libavutil-dev libsrtp2-dev ffmpeg && \
  mkdir /root/src && cd /root/src && \
  git clone --depth 1 https://gitee.com/xia-chu/ZLMediaKit && cd ZLMediaKit && git submodule update --init && \
  mkdir build && cd build && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. && ninja && cp -r ../release/linux/Release /usr/local/lib/ZLMediaKit && cd /usr/local/bin && ln -sf ../lib/ZLMediaKit/MediaServer .