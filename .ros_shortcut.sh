#!/bin/bash

## available ROS version and ws directory

## search ROS distro dir for distros
avail_ros_distro=$(find "${ros_distro_dir:-"/opt/ros/"}" \
                        -maxdepth 1 \
                        -mindepth 1 \
                        -type d \
                        -printf "%f\n")

## Homing ros to workspace
function roshome {
    if [ -z "$ROS_WORKSPACE" ]; then
        if roscd; then
            cd "../$1" || return
        fi
    else
        cd "$ROS_WORKSPACE" || return
    fi
}


# Intelligently sourcing ROS environment
function srcros {
    local melodic_setup="/opt/ros/melodic/setup.bash"
    local rosver_setup="/opt/ros/$1/setup.bash"
    ws_dir=${ws_dir:-"$HOME"}
    if [ $# -eq 0 ]; then
        # shellcheck source=/dev/null
        . "$melodic_setup"
        echo -e "\e[01;32m>>>Successfully source ROS Melodic by default.\e[0m"

    elif [ $# -eq 1 ]; then
        if [ -f "$rosver_setup" ]; then
            # shellcheck source=/dev/null
            . "$rosver_setup"
            echo -e "\e[01;32m>>>Successfully source ROS ${1^}.\e[0m"
        else
            # shellcheck source=/dev/null
            . "$melodic_setup"
            echo -e "\e[01;32m>>>Successfully source ROS melodic instead.\e[0m"
        fi

    elif [ $# -eq 2 ]; then
        # shellcheck source=/dev/null
        if [ -f "$rosver_setup" ]; then
            # shellcheck source=/dev/null
            . "$rosver_setup"
            local ws_ros1_setup="$ws_dir"/"$2"_ws/devel/setup.bash
            local ws_ros2_setup="$ws_dir"/"$2"_ws/install/setup.bash
            if [ -f "$ws_ros2_setup" ]; then
                # shellcheck source=/dev/null
                . "$ws_ros2_setup"
                export ROS_WORKSPACE
                ROS_WORKSPACE=$(eval echo "$ws_dir"/"$2"_ws/)
                local msg1="\e[01;32m>>>Successfully source ROS ${1^}"
                local msg2="and ${2} workspace.\e[0m"
                echo -e "$msg1""$msg2"
            elif [ -f "$ws_ros1_setup" ]; then
                # shellcheck source=/dev/null
                . "$ws_ros1_setup"
                export ROS_WORKSPACE
                ROS_WORKSPACE=$(eval echo "$ws_dir"/"$2"_ws/)
                local msg1="\e[01;32m>>>Successfully source ROS ${1^}"
                local msg2="and ${2} workspace.\e[0m"
                echo -e "$msg1""$msg2"

            else
                echo -e "\e[01;31mError: Wrong workspace name!!!\e[0m"
                echo -e "\e[01;32m>>>Successfully source ROS ${1^}.\e[0m"
            fi
        fi
    else
        echo -e "\e[01;31mError: Wrong num of params!!"
        return 1
    fi

    if [ -f /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash ]; then
        # shellcheck source=/dev/null
        . /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
    fi

    format_ros1_console
}

# shellcheck disable=2154
function format_ros1_console {
    export ROSCONSOLE_FORMAT
    ROSCONSOLE_FORMAT="${node} [${severity}]: ${message}"
}

# Source ROS autocompletion function
function _srcros_completions {
    if [ "${#COMP_WORDS[@]}" -eq "2" ]; then
        mapfile -t \
            COMPREPLY < <(compgen -W "${avail_ros_distro}" "${COMP_WORDS[1]}")
        return
    fi
    local ws_suggestions
    ws_suggestions=$(find "${ws_dir:-"$HOME"}" \
                                    -maxdepth 1 \
                                    -mindepth 1 \
                                    -type d \
                                    -printf "%f\n" \
                                    | grep "_ws" | sed "s/_ws//")
    if [ "${#COMP_WORDS[@]}" -eq "3" ]; then
        mapfile -t \
            COMPREPLY < <(compgen -W "${ws_suggestions}" "${COMP_WORDS[2]}")
    fi
}

alias rosdep_install_all="rosdep install --from-paths src --ignore-src -y"

complete -F _srcros_completions srcros