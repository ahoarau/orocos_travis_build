#!/bin/sh

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


# Hack for orogen+rosdep
rm ~/orocos-2.9_ws/src/orocos_toolchain/orogen/manifest.xml

# Configure the workspaces

catkin config --init -w ~/orocos-2.9_ws/ --install --extend /opt/ros/$ROS_DISTRO
catkin config -w ~/orocos-2.9_ws/ --cmake-args -DCMAKE_BUILD_TYPE=Release -DENABLE_CORBA=ON -DCORBA_IMPLEMENTATION=OMNIORB

rosdep install -q --from-paths ~/orocos-2.9_ws/src --ignore-src --rosdistro $ROS_DISTRO -y -r 

if [ "$ROS_DISTRO" = "hydro" ]; then
    apt-get install -q -y ruby1.9.1-dev
    update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 50
    update-alternatives --set ruby /usr/bin/ruby1.9.1
    ruby --version
fi

# Build
catkin build -w ~/orocos-2.9_ws/ --summarize  --no-status


# Upload to github
tar -czf ~/orocos_toolchain-release.tar.gz -C ~/orocos-2.9_ws/install .

git config --global user.email "hoarau.robotics@gmail.com"
git config --global user.name "Antoine Hoarau - Travis-CI"

git clone -q https://ahoarau:$1@github.com/ahoarau/orocos_travis_build -b master
cd orocos_travis_build
git checkout -q -b $ROS_DISTRO-release
rm -rf *
rm .travis.yml
cp ~/orocos_toolchain-release.tar.gz .

echo "
# Orocos Toolchain 2.9

Built on travis-ci.org $(date)

* Ubuntu $(lsb_release -cs)
* ROS $ROS_DISTRO
* Arch $(uname -m)

" >> README.md

git add -A
git commit -m "Travis-CI build $(date)"
git push -q -f origin $ROS_DISTRO-release


cd $STARTPOINT

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
