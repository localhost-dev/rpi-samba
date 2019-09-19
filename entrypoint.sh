#!/bin/bash

# Just to see the time
echo "------------------------------------------------------"
echo " Start time: "$(date)
echo "------------------------------------------------------"
echo ""

# Variables
config_file="/etc/samba/smb.conf"
users=()
shares=()

# Read all arguments and deal with them later on
while [ $# -gt 0 ]
	do
		opt=$1
		case $opt in
		"-uid")
			shift ;
			user_id=$1 ;;
		"-gid")
			shift ;
			group_id=$1 ;;
		"-u")
			shift ;
			users+=$1 ;;
		"-s")
			shift ;
			shares+=$1 ;;
		esac
		shift
	done

# Check if initial user exists
user_exists=$(grep -c "^docker:" /etc/passwd)

if [ ${user_exists} -eq 0 ]; then

	# Adding docker user with proper UID and GID (if possible)
	echo "-- Creating samba user"

	if [ ! -z ${group_id} ] && [ ${group_id} -ge 1000 ]; then
		groupadd -g ${group_id} -o docker
		group_id_cmd=" -g docker"
	fi

	if [ ! -z ${user_id} ]; then
		user_id_cmd=" -u ${user_id}"
	fi

	useradd -M docker ${user_id_cmd} ${group_id_cmd}

	echo "username: docker"
	echo "uid: $(id -u docker)"
	echo "gid: $(id -g docker)"

	# Create samba config file
	echo -e "\n-- Creating initial samba configuration file"

	echo "
[global]
workgroup = WORKGROUP
security = user
create mask = 0664
directory mask = 0775
force create mode = 0664
force directory mode = 0775
force user = docker
force group = docker
load printers = no
printing = bsd
printcap name = /dev/null
disable spoolss = yes
" > ${config_file}

	# Adding users to the system
	echo -e "\n-- Adding users..."
	for LINE in "${users[@]}"; do
		IFS=: read username password <<< ${LINE}
		useradd -M ${username}
		echo -e "${password}\n${password}" | smbpasswd -s -a ${username}
	done

	# Adding shared directories
	echo -e "\n-- Adding shares..."
	for LINE in "${shares[@]}"; do
		IFS=: read sharename sharepath permissions usernames <<< ${LINE}

		echo "Added shared directory ${sharepath}"
		chown docker ${sharepath}

		READ_ONLY="yes"; if [[ "rw" = "${permissions}" ]]; then READ_ONLY="no"; fi
		usernames=$(echo ${usernames} |tr "," " ")

		echo "
[${sharename}]
path = \"${sharepath}\"
read only = ${READ_ONLY}
valid users = ${usernames}
" >> ${config_file}
	done

	echo ""
fi

echo -e "-- Running samba..."
exec ionice -c 3 smbd -FS --configfile="${config_file}" </dev/null
