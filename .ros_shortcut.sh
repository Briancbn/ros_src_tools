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
        if [ "$1" = "-h" ]; then
            echo "usage: srcros [-h] [distro_name] [workspace_name]"
            echo ""
            echo "Sourcing available ROS distro and ROS workspace."
            echo ""
            echo "  srcros"
            echo "    Source Melodic setup.bash by default."
            echo ""
            echo "  srcros [distro_name]"
            echo "    Source available distro name found in ${ros_distro_dir}."
            echo ""
            echo "  srcros [distron_name] [workspace_name]"
            echo "    Source available distro name found in ${ros_distro_dir}"
            echo "    and then source the workspace name (ends with '_ws')"
            echo "    found in ${ws_dir}."
            echo "    Workspace name don't need suffix."
            echo ""
            echo "  srcros -h"
            echo "    show help information"
            return 0
        elif [ -f "$rosver_setup" ]; then
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
            local ws_devel_setup="$ws_dir"/"$2"_ws/devel/setup.bash
            local ws_install_setup="$ws_dir"/"$2"_ws/install/setup.bash
            if [ -f "$ws_install_setup" ]; then
                # shellcheck source=/dev/null
                . "$ws_install_setup"
                export ROS_WORKSPACE
                ROS_WORKSPACE=$(eval echo "$ws_dir"/"$2"_ws/)
                local msg1="\e[01;32m>>>Successfully source ROS ${1^}"
                local msg2=" and ${2} workspace.\e[0m"
                echo -e "$msg1""$msg2"
            elif [ -f "$ws_devel_setup" ]; then
                # shellcheck source=/dev/null
                . "$ws_devel_setup"
                export ROS_WORKSPACE
                ROS_WORKSPACE=$(eval echo "$ws_dir"/"$2"_ws/)
                local msg1="\e[01;32m>>>Successfully source ROS ${1^}"
                local msg2=" and ${2} workspace.\e[0m"
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

    if [ -f /usr/share/colcon_cd/function/colcon_cd.sh ]; then
        # shellcheck source=/dev/null
        source /usr/share/colcon_cd/function/colcon_cd.sh
    fi

    format_ros1_console
    force_ros2_color
}

# shellcheck disable=2154
# shellcheck disable=2016
function format_ros1_console {
    export ROSCONSOLE_FORMAT
    ROSCONSOLE_FORMAT='${node} [${severity}]: ${message}'
}

function force_ros2_color {
    export RCUTILS_COLORIZED_OUTPUT
    RCUTILS_COLORIZED_OUTPUT=1
}

# shellcheck disable=2154
function rosdep_install_all {
    rosdep install \
        --from-paths src \
        --ignore-src \
        -y \
        --rosdistro "${ROS_DISTRO}" \
        "$@"
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

complete -F _srcros_completions srcros
