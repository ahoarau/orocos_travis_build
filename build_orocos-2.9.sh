#/usr/bin/env sh

STARTPOINT=$(pwd)
echo "Starting point : " $(pwd)

mkdir -p ~/orocos-2.9_ws/src

wstool init ~/orocos-2.9_ws/src
wstool merge https://raw.githubusercontent.com/kuka-isir/rtt_lwr/rtt_lwr-2.0/lwr_utils/config/orocos_toolchain-2.9.rosinstall -t ~/orocos-2.9_ws/src
wstool update -t ~/orocos-2.9_ws/src

# Get the latest updates

cd ~/orocos-2.9_ws/src/orocos_toolchain
git submodule foreach git checkout toolchain-2.9
git submodule foreach git pull

# Configure the workspaces

catkin config --init -w ~/orocos-2.9_ws/ --install --extend /opt/ros/$ROS_DISTRO
catkin config -w ~/orocos-2.9_ws/ --cmake-args -DCMAKE_BUILD_TYPE=Release

source /opt/ros/$ROS_DISTRO/setup.bash
rosdep install -q --from-paths ~/orocos-2.9_ws/src --ignore-src --rosdistro $ROS_DISTRO -y -r 

# Build
catkin build -w ~/orocos-2.9_ws/ --summarize  --no-status

tar -czf ~/orocos_toolchain-release.tar.gz ~/orocos-2.9_ws/install

git config --global user.email "hoarau.robotics@gmail.com"
git config --global user.name "Antoine Hoarau - Travis-CI"

git clone https://ahoarau:$API_TOKEN@github.com/ahoarau/orocos_travis_build
cd orocos_travis_build
git checkout -b $(lsb_release -cs)-release
cp ~/orocos_toolchain-release.tar.gz .
git add orocos_toolchain-release.tar.gz
git commit -m "Travis-CI build $(date)"
git push origin $(lsb_release -cs)-release
#curl --data '{"tag_name": "v2.9.0","target_commitish": "master","name": "v2.9.0","body": "Release of version 2.9.0","draft": false,"prerelease": false}' https://api.github.com/repos/:ahoarau/:orocos_travis_build/releases?access_token=:$API_TOKEN

#mkdir -p ~/rtt_ros-2.9_ws/src
#wstool init ~/rtt_ros-2.9_ws/src
#wstool merge https://github.com/kuka-isir/rtt_lwr/raw/rtt_lwr-2.0/lwr_utils/config/rtt_ros-2.9.rosinstall -t ~/rtt_ros-2.9_ws/src
#wstool update -t ~/rtt_ros-2.9_ws/src

#catkin config -w ~/rtt_ros-2.9_ws/ --init --install --extend ~/orocos-2.9_ws/install
#catkin config -w ~/rtt_ros-2.9_ws/ --cmake-args -DCMAKE_BUILD_TYPE=Release 

#source ~/orocos-2.9_ws/install/setup.bash
#rosdep install -q --from-paths ~/rtt_ros-2.9_ws/src --ignore-src --rosdistro $ROS_DISTRO -y -r 

#catkin build -w ~/rtt_ros-2.9_ws/ --summarize  --no-status

#tar -czf ~/rtt_ros-release.tar.gz ~/rtt_ros-2.9_ws/install 

#source ~/rtt_ros-2.9_ws/install/setup.bash

#cd $STARTPOINT
