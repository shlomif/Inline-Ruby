FROM ubuntu:22.04
ARG GIT_ARCH
SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
        DEBIAN_FRONTEND="noninteractive" apt-get install -y \
        build-essential curl g++ git \
        vim sudo wget ruby-dev cpanminus
ARG user=docker-user
ARG home=/home/$user
ARG repo_dir=Inline-Ruby
RUN useradd --create-home -s /bin/bash $user \
        && echo $user:ubuntu | chpasswd \
        && adduser $user sudo
WORKDIR $home
USER $user
# ADD --chown=$user  does not work with tarball, see: https://stackoverflow.com/a/58493733/2173773
# So just add as root and chown later
ADD ${GIT_ARCH} $repo_dir
USER root
RUN chown -R $user:$user $repo_dir
USER $user
ENV USER=$user
ENV SHELL=/bin/bash
ENV REPO_DIR=$repo_dir
COPY entrypoint.sh $home
ENTRYPOINT ["./entrypoint.sh"]
