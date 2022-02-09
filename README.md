# EFPIA-RWD-SUBMISSION-PILOT
# Docker environment

```
1. Clone this repo to your ~/ directory
2. Run **/.start.sh** for the interactive menu
```

# Vocabularies

# Setup virtual python 2.7 environment for conversion of SynPUF data to OMOP on CentOS platform

1. install virualvenv and dependencies:

pip3 install --user virtualenv-20.8.1-py.py3-none-any.whl 

Dependencies:

platformdirs-2.4.0-py3-none-any.whl <br /> 
six-1.16.0-py2.py3-none-any.whl <br />
zipp-3.5.0-py3-none-any.whl <br />
typing_extensions-3.10.0.2-py3-none-any.whl <br />
distlib-0.3.3-py2.py3-none-any.whl <br />
filelock-3.1.0-py2.py3-none-any.whl <br />
importlib_resources-5.2.2-py3-none-any.whl <br />
backports.entry_points_selectable-1.1.0-py2.py3-none-any.whl <br />
importlib_metadata-4.8.1-py3-none-any.whl <br />

2. Create a project folder and activate the virtual environment:

mkdir project_dir <br />
cd project_dir <br />
virtualenv -p /usr/bin/python2.7 .venv <br />
source .venv/bin/activate <br />

3. Install dependencies for running the CMS_SynPuf_ETL_CDM_v5.py script for conversion of SynPUF to OMOP

pip install click-7.1.2-py2.py3-none-any.whl <br />
pip install python-dotenv-0.1.2.tar.gz <br />

# 
