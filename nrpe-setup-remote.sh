#!/bin/bash
#
# NRPE-SETUP-REMOTE by Christopher Dobler 2015
#
# USAGE:  
#   nrpe-cpanel-setup user host


escape_string()
{
   printf '%s' $1 | sed -e 's/[][\\^*+.$-]/\\\1/g'
}

#install dependencies
echo "Installing NRPE and plugins/dependencies"

#SAMPLE: multi line inline remote bash
# ssh "$1" bash -c "'
# 	yum -y install nagios-plugins openssl nagios-nrpe-plugin nagios-plugins-extra nagios-plugins-basic nagios-plugins-all nrpe
# 	'"

yum -y install nagios-plugins openssl nagios-nrpe-plugin nagios-plugins-extra nagios-plugins-basic nagios-plugins-all nrpe yum-security

service nrpe start
chkconfig nrpe on


echo ""
echo "Installing NRPE Configs"

#SAMPLE : if the matched doesnt exist then replace the given
# if ! grep -q "^allowed_hosts=127.0.0.1,monitor.dobsys.io" /etc/nagios/nrpe.cfg
# 	then 
# 		sed -i "s/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1,monitor.dobsys.io/g" /etc/nagios/nrpe.cfg
# fi

#SAMPLE : if the matched doesnt exist then add to bottom of file
# if ! grep -q /"^command[check_procs]=/usr/lib64/nagios/plugins/check_procs -u $ARG1$ -c $ARG2$ -C $ARG3$/" /etc/nagios/nrpe.cfg
# 	then 
# 		sed "$ a\command[check_procs]=/usr/lib64/nagios/plugins/check_procs -u $ARG1$ -c $ARG2$ -C $ARG3$" -i /etc/nagios/nrpe.cfg
# fi

declare -a cmd_str
declare -a cmd_idx
declare -i i
i=0

cmd_str[0]="allowed_hosts=127.0.0.1,monitor.dobsys.io"
cmd_idx[0]="allowed_hosts=127.0.0.1"
cmd_str[1]='command[check_procs]=/usr/lib64/nagios/plugins/check_procs -u $ARG1$ -c $ARG2$ -C $ARG3$'
cmd_idx[1]="command\[check_procs\]"
cmd_str[2]="command[check_yum]=/usr/lib64/nagios/plugins/check_yum --warn-on-any-update"
cmd_idx[2]="command\[check_yum\]"
cmd_str[3]='command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 10% -c 5%'
cmd_idx[3]='command\[check_disk\]'
cmd_str[4]='command[check_filesystem]=/usr/lib64/nagios/plugins/check_filesystem -d /dev/vda1 -t lvm'
cmd_idx[4]='command\[check_filesystem\]'
cmd_str[5]='command[check_swap]=/usr/lib64/nagios/plugins/check_swap -w 50 -c 10'
cmd_idx[5]='command\[check_swap\]'
cmd_str[6]='command[check_load]=/usr/lib64/nagios/plugins/check_load -w 1.0,0.75,0.5 -c 2.0,1.0,1.0'
cmd_idx[6]='command\[check_load\]'

# cmd_str[6]='dont_blame_nrpe=1'
# cmd_idx[6]='dont_blame_nrpe'


for p in "${cmd_str[@]}"
do
   	:
   	# sed -i 's/.*'${cmd_idx[$i]}'.*/${p}/' /etc/nagios/nrpe.cfg
	sed -i "/${cmd_idx[$i]}/c\\${p}" /etc/nagios/nrpe.cfg
	if ! grep -q "${cmd_idx[$i]}" /etc/nagios/nrpe.cfg
	then 
		sed "$ a\\${p}" -i /etc/nagios/nrpe.cfg
	fi
	((i++))
done

service nrpe restart
