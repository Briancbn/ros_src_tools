#!/bin/bash
# Copyright 2020 Chen Bainian
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

dirpath=$(dirname "$0")

function ros_src_tools_configure {
    read -r -e -p "Where is ROS installed? By Default [/opt/ros]: " \
                                                            ros_distro_dir
    if [ "$ros_distro_dir" = "" ]; then
        ros_distro_dir="/opt/ros"
    fi
    ros_distro_dir=$(eval echo "$ros_distro_dir")
    if [ -d "$ros_distro_dir" ]; then
        avail_ros_distro=$(find "${ros_distro_dir}" \
                                -maxdepth 1 \
                                -mindepth 1 \
                                -type d \
                                -printf "%f\t")
        echo "Are these your ROS Distros: "
        echo -e "\e[01;34m${avail_ros_distro}\e[0m"
        read -r -p "press [Enter] to continue " _
        read -r -e -p "Where are your workspaces? By Default [$HOME]: " ws_dir
        if [ "$ws_dir" = "" ]; then
            ws_dir=$HOME
        fi
        ws_dir=$(eval echo "$ws_dir")
        if [ -d "$ws_dir" ]; then
            avail_ws=$(find "${ws_dir}" \
                            -maxdepth 1 \
                            -mindepth 1 \
                            -type d \
                            -printf "%f\n" \
                            | grep _ws | sed "s/_ws//")
            echo "Are these your ROS workspaces (ends with _ws):"
            echo -e "\e[01;34m${avail_ws}\e[0m"
            read -r -p "press [Enter] to continue " _
            cp "$dirpath"/.ros_shortcut.sh "$HOME"/
            sed -i "16 a ros_distro_dir=${ros_distro_dir}\nws_dir=${ws_dir}" \
                "$HOME"/.ros_shortcut.sh

            echo -e "\e[01;32m>>>Successfully install ros_src_tools!\e[0m"
            echo -e "\e[01;32m>>>Please reopen your terminal.\e[0m"
        else
            echo "Invalid path, aborted"
        fi


    else
        echo "Invalid path, aborted"
    fi
}


if [ "$(grep ". ~/.ros_shortcut.sh" "${HOME}"/.bashrc)" != "" ]; then
    if [ -f "$HOME/.ros_shortcut.sh" ]; then
        read -r -p \
            "myROSshortcuts are already installed, reconfigure?[y/N]: " \
            opt_recfg
        if [ "$opt_recfg" = "y" ] || [ "$opt_recfg" = "Y" ]; then
            ros_src_tools_configure
        fi
    else
        echo ".ros_shortcut.sh is missing! Lets reconfigure it for you"
        echo "Did you accidentally deleted it?"
        ros_src_tools_configure
    fi
else
    echo "Starting to setup myROSshortcuts"
    {
        echo ""
        echo "# ROS source tools";
        echo "if [ -f ~/.ros_shortcut.sh ]; then";
        echo "  . ~/.ros_shortcut.sh";
        echo "fi"
    } >> "$HOME"/.bashrc
    ros_src_tools_configure
fi
