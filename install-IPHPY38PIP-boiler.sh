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
# get json file, select only fileContent part, remove quotes, decode base64 and save
aws codecommit get-file --repository-name aws-cfn-iphpy38-pip --file-path requirements.txt --region eu-central-1 | jq .fileContent | tr -d '"'| base64 --decode >/home/ubuntu/requirements.txt

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
