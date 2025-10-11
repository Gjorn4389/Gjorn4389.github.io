#! /bin/bash

function switch2windows() {
    echo "switch to windows"
    # windwos entry index = 4
    sudo grub-reboot 4
    for ((i=3;i>0;i--)) {
        echo "$i seconds reboot"
        sleep 1
    }
    reboot
}

function releaseDpkgLock() {
    sudo rm -f /var/cache/apt/archives/lock /var/lib/dpkg/lock
}

function term() {
    if [ `whoami` == "root" ]; then
        echo "Can't upport in root"
    fi

    if [ $# -eq 0 ]; then
        gnome-terminal --working-directory="$PWD"
    elif [ -d "$1" ]; then
        gnome-terminal --working-directory="$(realpath "$1")"
    else
        echo "Path not exist: $1"
    fi
}

function Handbook() {
    code ~/Documents/Handbook
}


# alias dsh='docker exec -it $1 /bin/bash'

# install `fzf`, dsh + Tab to insert docker name
function dsh() {
    local container=${1:-$(docker ps --format '{{.Names}}' | fzf)}
    if [ -n "$container" ]; then
        docker ps | grep $container || docker start $container
        docker exec -it "$container" /bin/bash
    else
        echo "No container selected."
    fi
}
