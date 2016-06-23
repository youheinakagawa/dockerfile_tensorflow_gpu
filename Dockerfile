FROM ubuntu:14.04

RUN /bin/cp -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E1DD270288B4E6030699E45FA1715D88E1DF1F24
RUN echo 'deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main' > /etc/apt/sources.list.d/git.list
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y language-pack-ja-base \
                       language-pack-ja \
                       ibus-mozc \
                       man \
                       manpages-ja && \
    update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8
RUN apt-get install -y build-essential make git ccache g++ gfortran curl wget mecab libmecab-dev mecab-ipadic aptitude

ENV PATH /usr/lib/ccache:$PATH

RUN apt-get install -y --no-install-recommends python-pip python-dev
RUN aptitude install -y mecab-ipadic-utf8
RUN apt-get install -y python-mecab

WORKDIR /opt/nvidia
RUN mkdir installers

RUN curl -s -o cuda_7.5.18_linux.run http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run

RUN chmod +x cuda_7.5.18_linux.run && sync && \
    ./cuda_7.5.18_linux.run -extract=`pwd`/installers
RUN ./installers/cuda-linux64-rel-7.5.18-19867135.run -noprompt && \
    cd / && \
    rm -rf /opt/nvidia

RUN echo "/usr/local/cuda/lib" >> /etc/ld.so.conf.d/cuda.conf &&     echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf &&     ldconfig

ENV CUDA_ROOT /usr/local/cuda
ENV PATH $PATH:$CUDA_ROOT/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CUDA_ROOT/lib64:$CUDA_ROOT/lib:/usr/local/nvidia/lib64:/usr/local/nvidia/lib
ENV LIBRARY_PATH /usr/local/nvidia/lib64:/usr/local/nvidia/lib:/usr/local/cuda/lib64/stubs$LIBRARY_PATH

ENV CUDA_VERSION 7.5
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="7.5"

WORKDIR /opt/cudnn
RUN curl -s -o cudnn-6.5-linux-x64-v2.tgz http://developer.download.nvidia.com/compute/redist/cudnn/v2/cudnn-6.5-linux-x64-v2.tgz
RUN tar -xzf cudnn-6.5-linux-x64-v2.tgz
RUN rm cudnn-6.5-linux-x64-v2.tgz
RUN cp cudnn-6.5-linux-x64-v2/cudnn.h /usr/local/cuda/include/.
RUN mv cudnn-6.5-linux-x64-v2/libcudnn.so /usr/local/cuda/lib64/.
RUN mv cudnn-6.5-linux-x64-v2/libcudnn.so.6.5 /usr/local/cuda/lib64/.
RUN mv cudnn-6.5-linux-x64-v2/libcudnn.so.6.5.48 /usr/local/cuda/lib64/.
RUN mv cudnn-6.5-linux-x64-v2/libcudnn_static.a /usr/local/cuda/lib64/.
RUN pip install -U "setuptools"
RUN pip install -U "cython"
RUN pip install -U "numpy<1.10"
#RUN pip install -U "h5py<2.6"
RUN pip install -U "nose"
RUN pip install -U "mock"
RUN pip install -U "coverage"
RUN pip install --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl

RUN echo "export LD_LIBRARY_PATH=/usr/local/cuda-7.5/lib64/stubs/:\$LD_LIBRARY_PATH" >> ~/.bashrc && ldconfig

RUN apt-get -y update
RUN apt-get -y install vim

WORKDIR /root/
RUN git clone https://github.com/neologd/mecab-ipadic-neologd
WORKDIR /root/mecab-ipadic-neologd/
RUN ./bin/install-mecab-ipadic-neologd -n -y

RUN wget https://raw.githubusercontent.com/youheinakagawa/vimrc/master/.vimrc -O /root/.vimrc

RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
