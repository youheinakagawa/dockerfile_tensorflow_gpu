FROM nvidia/cuda:cudnn

RUN /bin/cp -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E1DD270288B4E6030699E45FA1715D88E1DF1F24
RUN echo 'deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main' > /etc/apt/sources.list.d/git.list
RUN apt-get update
RUN apt-get install -y language-pack-ja-base \
                       language-pack-ja \
                       ibus-mozc \
                       man \
                       manpages-ja && \
    update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8
RUN apt-get install -y --no-install-recommends python-pip python-dev
RUN apt-get install -y git curl wget mecab libmecab-dev mecab-ipadic aptitude
RUN aptitude install -y mecab-ipadic-utf8
RUN apt-get install -y python-mecab

RUN pip install --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl

RUN export LD_LIBRARY_PATH=/usr/local/cuda-7.5/targets/x86_64-linux/lib/stubs/:$LD_LIBRARY_PATH

RUN echo "export LD_LIBRARY_PATH=/usr/local/cuda-7.5/targets/x86_64-linux/lib/stubs/:$LD_LIBRARY_PATH" >> ~/.bashrc

RUN apt-get -y update
RUN apt-get -y install vim

RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
