RUN nvidia-smi
RUN conda install pytorch==1.12.0 cudatoolkit=11.3 -c pytorch -c conda-forge
RUN python -m pip install -e .

RUN git pull
RUN python test_torch.py

RUN cd ./examples && \
    pip install nerfacc && \
    pip install -r requirements.txt