FROM alpine:latest as downloader

WORKDIR /Downloads

ARG TOOLBOX_VER="1.26.0.13072"
RUN wget -q "https://download.jetbrains.com.cn/toolbox/jetbrains-toolbox-${TOOLBOX_VER}.tar.gz"
RUN tar -xzf jetbrains-toolbox-${TOOLBOX_VER}.tar.gz
RUN mv jetbrains-toolbox-${TOOLBOX_VER}/jetbrains-toolbox .

ARG CLION_VER="2022.2.3"
RUN wget -q "https://download.jetbrains.com/cpp/CLion-${CLION_VER}.tar.gz"
RUN tar -xzf CLion-${CLION_VER}.tar.gz
RUN mv clion-${CLION_VER} clion


ARG PYCHARM_VER="2022.2.2"
RUN wget -q "https://download.jetbrains.com/python/pycharm-professional-${PYCHARM_VER}.tar.gz"
RUN tar -xzf pycharm-professional-${PYCHARM_VER}.tar.gz
RUN mv pycharm-${PYCHARM_VER} pycharm




FROM danielguerra/ubuntu-xrdp:20.04

COPY ./aliyun-sources.list /etc/apt/sources.list

# Install Chinese font
RUN apt-get update \
    && apt-get install -y \
    fonts-arphic-ukai \
    libncursesw5-dev \
    autotools-dev \
    autoconf \
    build-essential

# Install Htop
ARG HTOP_VERSION="3.2.1"
RUN wget -q "https://github.com/htop-dev/htop/releases/download/${HTOP_VERSION}/htop-${HTOP_VERSION}.tar.xz" \
    && tar -xf htop-${HTOP_VERSION}.tar.xz \
    && cd htop-${HTOP_VERSION} \
    && ./autogen.sh \
    && ./configure \
    && make install \
    && cd .. \
    && rm -rf htop-${HTOP_VERSION} \
    && rm htop-${HTOP_VERSION}.tar.xz

# Install vscode
RUN wget -q -O code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" \
    && apt-get install -y ./code.deb \
    && rm code.deb

ARG USER="ubuntu"
ARG PASSWORD="ubuntu"
RUN useradd --create-home --shell /bin/bash ${USER} \
    && echo "${USER}:${PASSWORD}" | chpasswd \
    && adduser ${USER} sudo

USER ${USER}
WORKDIR /home/${USER}/Downloads

# Install Jetbrains Toolbox and other products
RUN mkdir /home/${USER}/Apps
COPY --from=downloader /Downloads/jetbrains-toolbox /home/${USER}/Apps
COPY --from=downloader /Downloads/clion /home/${USER}/Apps
COPY --from=downloader /Downloads/pycharm /home/${USER}/Apps

# Install Miniconda
RUN wget -q "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && /home/${USER}/miniconda3/bin/conda init \
    && rm Miniconda3-latest-Linux-x86_64.sh

USER root
