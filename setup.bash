#!/usr/bin/env bash
dirpath=$(dirname "$0")

myROSshortcuts_configure(){
  read -p "Where is ROS installed? By Default [/opt/ros]: " ros_distro_dir
  if ["$ros_distro_dir" == ""]; then
    ros_distro_dir="/opt/ros"
  fi
  if [ -d "$ros_distro_dir" ]; then
    avail_ros_distro=$(ls $ros_distro_dir | sed "s/\t/\ /")
    echo "Are these your ROS Distros: "
    echo "$avail_ros_distro"
    read -p "press [Enter] to continue " opt
    read -p "Where are your workspaces? By Default [$HOME]: " ws_dir
    if [ "$ws_dir" == "" ]; then
      ws_dir="$HOME"
    fi
    if [ -d "$ws_dir" ]; then
      avail_ws=$(ls $ws_dir | sed "s/\t/\n/" | grep _ws | sed "s/_ws//" | sed "s/\n/\ /")
      echo "Are these your ROS workspaces (ends with _ws):"
      echo "$avail_ws" 
      read -p "press [Enter] to continue " opt
      cp $dirpath/.ros_shortcut.bash $HOME/
      sed -i "4 a ros_distro_dir=${ros_distro_dir}\nws_dir=${ws_dir}" $HOME/.ros_shortcut.bash

      echo -e "\e[01;32m>>>Successfully install myROSshortcutS.\e[0m"
    else
      echo "Invalid path, aborted"
    fi


  else
    echo "Invalid path, aborted"
  fi
}


if [ "$(grep ". ~/.ros_shortcut.bash" $HOME/.bashrc)" != "" ] && [ "$(grep "#. ~/.ros_shortcut.bash" $HOME/.bashrc)" == "" ]; then
  if [ -f "$HOME/.ros_shortcut.bash" ]; then
    read -p "myROSshortcuts are already installed, re-configure?[yN]: " opt_recfg
    if [ "$opt_recfg" == "y" ]; then
      myROSshortcuts_configure
    fi
  else
    echo ".ros_shortcut.bash is missing! Lets reconfigure it for you"
    echo "Did you accidentally deleted it?"
    myROSshortcuts_configure
  fi
else
  echo "Starting to setup myROSshortcuts"
  echo ". ~/.ros_shortcut.bash" >> $HOME/.bashrc
  myROSshortcuts_configure
fi

  
