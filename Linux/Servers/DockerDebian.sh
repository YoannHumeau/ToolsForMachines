#!/bin/bash

check_access_is_root()
{
        if [ $(id -u) != 0 ]
        then
                echo "ERROR : This script must be run as root or sudo !"
                exit 1
        fi
}

check_user_exists() # $1 must be $user
{
        # Check user is given
        if [ -z "$1" ]; then
                echo "ERROR : You need to specify a user"
                exit 1
        fi

        # Check user exists
        if ! id "$1" &> /dev/null; then
                echo "ERROR : The user \"$user\" does not exists"
                exit 1
        fi
}

install_docker()
{
    echo "Start install Docker"

    # Update and install tools we need
    sudo apt update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

    # Get the Docker key
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add the Docker repo
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
}

give_user_access_without_sudo()
{
    if ! [ $(getent group docker) ]; then
      echo "ERROR : Group docker not found! Is Docker installed on your machine ?"
      exit 1;
    fi

    # Make user access Docker without sudo
    usermod -aG docker $user
    echo "User \"$user\" is allowed to run docker without sudo"
    su - $user -c exit
    echo -e "\nTo take effect, exit this session and relog with the user \"$user\" and run the command : \"docker run hello-world\""
}

print_help()
{
    echo "$(basename "$0") [-i] [-u <linux-username>] -- program to install Docker on Debian and allow user to run container without sudo

where:
    -h  show this help text
    -i  install Docker
    -u  linux user to add for not requireing sudo"
    exit 1
}

# Get parameters
while getopts "iu::help" flag
do
    case "${flag}" in
        i) install=true;;
        u) user=$OPTARG;;
        h) print_help;;
    esac
done


# Run baby !
check_access_is_root
check_user_exists $user
if [ $install ]; then install_docker; fi;
give_user_access_without_sudo
