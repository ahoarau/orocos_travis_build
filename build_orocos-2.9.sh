#/usr/bin/env sh

STARTPOINT=$(pwd)
echo "Starting point : " $(pwd)

mkdir -p ~/orocos-2.9_ws/src

wstool init ~/orocos-2.9_ws/src
wstool merge https://raw.githubusercontent.com/kuka-isir/rtt_lwr/rtt_lwr-2.0/lwr_utils/config/orocos_toolchain-2.9.rosinstall -t ~/orocos-2.9_ws/src
wstool update -j2 -t ~/orocos-2.9_ws/src

mkdir -p ~/rtt_ros-2.9_ws/src
wstool init ~/rtt_ros-2.9_ws/src
wstool merge https://github.com/kuka-isir/rtt_lwr/raw/rtt_lwr-2.0/lwr_utils/config/rtt_ros-2.9.rosinstall -t ~/rtt_ros-2.9_ws/src
wstool update -j2 -t ~/rtt_ros-2.9_ws/src

# Get the latest updates

cd ~/orocos-2.9_ws/src/orocos_toolchain
git submodule foreach git checkout toolchain-2.9
git submodule foreach git pull

# Configure the workspaces

catkin config --init -w ~/orocos-2.9_ws/ --install --extend /opt/ros/$ROS_DISTRO
catkin config -w ~/orocos-2.9_ws/ --cmake-args -DCMAKE_BUILD_TYPE=Release

catkin config --init --install --extend ~/orocos-2.9_ws/install -w ~/rtt_ros-2.9_ws/
catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -w ~/rtt_ros-2.9_ws/


rosdep install -q --from-paths ~/orocos-2.9_ws/src --ignore-src --rosdistro $ROS_DISTRO -y
rosdep install -q --from-paths ~/rtt_ros-2.9_ws/src --ignore-src --rosdistro $ROS_DISTRO -y


# Build
catkin build -w ~/orocos-2.9_ws/src
catkin build -w ~/orocos-2.9_ws/

source ~/rtt_ros-2.9_ws/install/setup.bash

cd $STARTPOINT