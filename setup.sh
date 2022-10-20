nvidia-smi
conda install pytorch==1.12.0 cudatoolkit=11.3 -c pytorch -c conda-forge
python -m pip install -e .
pip install wheel

git pull
python test_torch.py

cd ./examples
pip install nerfacc
pip install -r requirements.txt
cd ../