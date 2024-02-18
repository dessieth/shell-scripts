#!/bin/bash
#
#
#######################################
# Author: Dessie
# Date: Feb 14, 2024
# version: v0.1
# The script performs user management
#
#######################################


search_user() {
	username=$1
	find_user=$(grep -E "$username" /etc/passwd| awk -F ':' '{print $1}')
	if [ "$username" = "$find_user" ]; then
		return 0
	else
		return 1
	fi
}

display_info(){
	username=$1
	if (search_user $username); then
		user_name=$(grep -E "$username" /etc/passwd| awk -F ':' '{print $1}')
		user_home=$(grep -E "$username" /etc/passwd| awk -F ':' '{print $6}')
		user_shell=$(grep -E "$username" /etc/passwd| awk -F ':' '{print $7}')
		echo "user name: $user_name \nuser home: $user_home \nuser shell: $user_shell"
	else
		echo "$user_name doesn't exist"
	fi
}

create_user() {
	username=$1
	if (! search_user $username); then
		read -p "Enter the user home directory [/home/$username]: " user_home
		read -p "Enter the user running shell [/bin/sh]: " user_shell
		if [ -z $user_home ] && [ -z $user_shell ]; then
			sudo useradd $username
		elif [ -z $user_home ]; then
			sudo useradd -m -s $user_shell $username
		elif [ -z $user_shell ]; then
			sudo useradd -d $user_home -m $username
		else
			sudo useradd -d $user_home -m -s $user_shell $username
		fi

		if [ $? -eq 0 ]; then
			echo "The new user is created successfully"
		fi
	else
		echo "The user exists"
	fi
}

delete_user(){
	username=$1
	if (search_user $username); then
		read -p "Pleas enter [1] to disale or [2] to delete: " choice
		if [ $choice -eq 1 ]; then
			sudo usermod -L $username
			if [ $? -eq 0 ]; then
				echo "The user is disabled successfully"
			fi
		else
			read -p "Do you want to continue deleting $username [Y|N]: " response
			case $response in
				[Yy])
					sudo userdel -r $username 2>/dev/null
					if [ $? -eq 0 ]; then
						echo "The user is deleted successfully"
					fi
					;;
			esac
		fi
	else
		echo "The user doesn't exist"
	fi
}

# The main program starts here;
while :
do
echo
echo  "  \tUSER MANAGMENT MENU"
echo  "  1) Create user"
echo  "  2) Display user info"
echo  "  3) Delete or disable user"
echo  "  4) Modify user information"
echo  "  5) Change password or enable user"
echo
read -p "Select an option [1..4] and press Enter: " choice
case $choice in
	1) 
		read -p "Please enter the user name: " user_name
		create_user $user_name
		;;
	2) 
		read -p "Please enter the user name: " user_name
		display_info $user_name
		;;
	3) 
		read -p "Please enter the user name: " user_name
		delete_user $user_name
		;;
	*) echo "Please enter the correct option[1..4]"
		;;
esac
echo
read -p "Press Enter to continue or [Q|q] to quit: " input
case $input in
	[Qq]) exit 0
		;;
	*) continue
		;;
esac
done
