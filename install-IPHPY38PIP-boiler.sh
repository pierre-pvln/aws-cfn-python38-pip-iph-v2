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
wget -O /home/ubuntu/requirements.txt "https://raw.githubusercontent.com/pierre-pvln/aws-cfn-python38-pip-iph-v2/master/requirements.txt"

echo [INFO ] Installing python ...
sudo apt-get install python3-pip -y
sudo apt-get install python3-venv -y
python3 -m pip install --user --upgrade pip
python3 -m venv env
source env/bin/activate
python3 -m pip install -r /home/ubuntu/requirements.txt
python3 -m pip freeze >/home/ubuntu/as_build.txt
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
