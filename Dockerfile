FROM danielguerra/ubuntu-xrdp:20.04

COPY ./aliyun-sources.list /etc/apt/sources.list

# Install Chinese font
RUN apt-get update && \
    apt-get install -y \
    fonts-arphic-ukai

# Install vscode
RUN wget -O code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" \
    && apt-get install -y ./code.deb \
    && rm code.deb

ARG USER="ubuntu"
ARG PASSWORD="ubuntu"
RUN useradd --create-home --shell /bin/bash ${USER} \
    && echo "${USER}:${PASSWORD}" | chpasswd \
    && adduser ${USER} sudo

USER ${USER}
WORKDIR /home/${USER}/Downloads

# Install Jetbrains Toolbox
ARG TOOLBOX_VER="1.26.0.13072"
RUN mkdir /home/${USER}/Apps
RUN wget -O toolbox.tar.gz "https://download.jetbrains.com.cn/toolbox/jetbrains-toolbox-${TOOLBOX_VER}.tar.gz" \
    && tar -xzvf toolbox.tar.gz \
    && mv jetbrains-toolbox-${TOOLBOX_VER}/jetbrains-toolbox /home/${USER}/Apps \
    && rm toolbox.tar.gz \
    && rm -r jetbrains-toolbox-${TOOLBOX_VER}

# Install Miniconda
RUN wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && /home/${USER}/miniconda3/bin/conda init

USER root
