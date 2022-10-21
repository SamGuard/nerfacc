
FROM nvidia/cuda:11.7.1-devel-ubuntu20.04

# Remove any third-party apt sources to avoid issues with expiring keys.
RUN rm -f /etc/apt/sources.list.d/*.list

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    ca-certificates \
    git \
    wget \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*




WORKDIR /tmp/
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

ENV PATH=$CONDA_DIR/bin:$PATH

ENV TF_FORCE_GPU_ALLOW_GROWTH=true
ENV PATH=/usr/local/cuda-11.4/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.4/lib64:$LD_LIBRARY_PATH

# Create a working directory
WORKDIR /
RUN mkdir /app
WORKDIR /app
RUN git clone https://github.com/SamGuard/nerfacc.git
WORKDIR /app/nerfacc/


RUN mkdir /home/ruilongli/
COPY data /home/ruilongli/data
RUN cd /home/ruilongli/data && unzip *

RUN conda create -n nerf python=3.9

SHELL ["conda", "run", "-n", "nerf", "/bin/bash", "-c"]

CMD [ "conda", "run", \
    "--no-capture-output", "-n", "nerf", \
    "/bin/bash -c './setup.sh'"]

    #"python", "examples/train_mlp_nerf.py", \
    #"--train_split" ,"train", "--scene", "lego"]