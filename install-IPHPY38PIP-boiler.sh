#!/usr/bin/env bash
#
# boilerplate install script
#
cd /home/ubuntu
touch $(date '+%Y-%m-%d_%H-%M-%S')_start_of_install

su ubuntu

# Python Install
# ==============
# get requirements.txt file from repository
#wget -O /home/ubuntu/requirements.txt "https://raw.githubusercontent.com/pierre-pvln/aws-cfn-python38-pip-iph-v2/master/requirements.txt"
#aws s3 cp s3://iph-code-repository/json-to-csv/code/app/requirements.txt /home/ubuntu/requirements.txt

# copy all the versions of the requirements file
aws s3 cp s3://iph-code-repository/json-to-csv/code/app/ /home/ubuntu/ --recursive --exclude "*" --include "requirements*.txt"

echo [INFO ] Installing python ...
sudo apt-get install python3-pip -y
sudo apt-get install python3-venv -y
python3 -m pip install --user --upgrade pip
python3 -m venv env
source env/bin/activate

# Detect the Python minor version (e.g. "3.12", "3.8") and pick the matching
# requirements file. Falls back to the generic requirements.txt for any
# other version.
PY_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}".strip())')
echo "Detected Python ${PY_VERSION}"
 
if [ "$PY_VERSION" = "3.12" ]; then
    REQ_FILE="$HOME/requirements_py312.txt"
    BLD_FILE="$HOME/as_build_py312.txt"
elif [ "$PY_VERSION" = "3.8" ]; then
    REQ_FILE="$HOME/requirements_py38.txt"
    BLD_FILE="$HOME/as_build_py38.txt"
else
    REQ_FILE="$HOME/requirements.txt"
    BLD_FILE="$HOME/as_build.txt"
fi

echo "Installing from ${REQ_FILE}"
echo "Saving package versions to ${BLD_FILE}"
python3 -m pip install -r "${REQ_FILE}"
python3 -m pip freeze >"${BLD_FILE}"

deactivate

# Polygon Install
# ===============

echo [INFO ] Cloning polygons from public github ...
# get the polygons
git clone https://github.com/pierre-pvln/myPolygons.git /home/ubuntu/polygons

# App Install
# ===========
echo [INFO ] Cloning app ...
DIR="/home/ubuntu/json-to-csv/"
if [ ! -d "$DIR" ]; then
  # Take action if $DIR does not exist. #
  mkdir --parents "$DIR"
fi
aws s3 cp s3://iph-code-repository/json-to-csv/ /home/ubuntu/json-to-csv --recursive

cp /home/ubuntu/json-to-csv/run_ec2/run-python-script.sh /home/ubuntu/run-python-script.sh

# and finalize
cd /home/ubuntu
chmod +x /home/ubuntu/*.sh

touch $(date '+%Y-%m-%d_%H-%M-%S')_end_of_install
