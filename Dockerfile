
FROM nvidia/cuda:11.7.1-base-ubuntu20.04

# Remove any third-party apt sources to avoid issues with expiring keys.
RUN rm -f /etc/apt/sources.list.d/*.list

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    ca-certificates \
    git \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /tmp/
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

ENV PATH=$CONDA_DIR/bin:$PATH

#RUN conda env --name pytorch
#RUN conda activate pytorch
#RUN conda install pytorch==1.12.0 \
# torchvision==0.13.0 torchaudio==0.12.0 cudatoolkit=11.6 -c pytorch -c conda-forge

ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# Create a working directory
WORKDIR /
RUN mkdir /app
WORKDIR /app
RUN git clone https://github.com/KAIR-BAIR/nerfacc.git
WORKDIR /app/nerfacc/


RUN mkdir /home/ruilongli/data
COPY data /home/ruilongli/data
RUN cd /home/ruilongli/data && unzip *

