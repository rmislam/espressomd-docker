FROM python:3.11.9-slim-bookworm

SHELL ["/bin/bash", "-c"]

RUN sed -i -e's/ main/ main contrib non-free/g' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    gcc-11 \
    g++-11 \
    ccache \
    cmake \
    cython3 \
    gdb \
    git \
    libblas-dev \
    libboost-dev libboost-serialization-dev libboost-mpi-dev libboost-filesystem-dev libboost-test-dev \
    libfftw3-dev \
    libhdf5-openmpi-dev \
    liblapack-dev \
    libpython3-dev \
    openmpi-bin \
    freeglut3-dev \
    libgle-dev \
    vim \
    wget

RUN echo 'alias python="python3"' >> ~/.bashrc && source ~/.bashrc

RUN python3 -m pip install MDAnalysis MDAnalysisTests pandas numpy scipy h5py setuptools Cython PyOpenGL PyOpenGL_accelerate \
    && apt-get -y install nvidia-cuda-toolkit

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -rm -d /home/espresso -s /bin/bash -g root -G sudo -u 1001 espresso
USER espresso
WORKDIR /home/espresso
RUN mkdir /home/espresso/volume
RUN chown espresso:root /home/espresso/volume

RUN wget https://github.com/espressomd/espresso/releases/download/4.2.2/espresso-4.2.2.tar.gz
RUN tar -zxvf espresso-4.2.2.tar.gz

RUN cd espresso \
  && mkdir build

COPY myconfig.hpp /home/espresso/espresso/build/

RUN cd espresso && cd build && CC=gcc-11 CXX=g++-11 cmake .. -D WITH_CUDA=ON \
  && make -j 4

RUN python3 -m pip install nbformat nbconvert jupyterlab
RUN python3 -m IPython profile create
# Needed so the espressomd module is in the Jupyter python path
RUN echo "c.InteractiveShellApp.exec_lines = [\"import sys; sys.path.insert(0, '/home/espresso/espresso/build/src/python')\"]" >> /home/espresso/.ipython/profile_default/ipython_config.py

EXPOSE 80
EXPOSE 8888

# NOTE: Setting --ip to 0.0.0.0 is NOT secure -- change it if you're on an unsecure network
CMD ["/home/espresso/.local/bin/jupyter", "lab", "--no-browser", "--ip", "0.0.0.0", "--NotebookApp.token=''", "--NotebookApp.password=''"]

# If using WSL, you may need to replace the ip address in the URL that jupyter produces with the ip from:
# ip addr | grep eth0 | grep inet
# This gives the ip address of WSL relative to the Windows host

# In jupyter, using the file explorer go to doc/tutorials to find the tutorial IPython notebooks
# Whenever importing espressomd, make sure to run this in Python first to add espressomd to the Python path (this has already been added to the jupyter config):
# import sys
# sys.path.insert(0, '/home/espresso/espresso/build/src/python')
