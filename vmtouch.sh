#!/usr/bin/env bash
#===============================================================================
#
#          FILE: vmtouch.sh
# 
#         USAGE: ./vmtouch.sh start|stop|restart
# 
#   DESCRIPTION: Starts vmtouch program as daemon
# 
#===============================================================================

# config file for vmtouch
VMTOUCH_CONF='/etc/vmtouch.conf'

# config file for daemon
VMTOUCHD_CONF='/etc/default/vmtouch'

#libui-sh
if [ ! -r '/usr/lib/libui.sh' ]; then
    echo "The file /usr/lib/libui.sh is missing."
    exit 1
fi
source /usr/lib/libui.sh
libui_sh_init cli


_check (){ #{{{
    # run as root
    [ $EUID -eq 0 ] || die_error "Gotta be root."

    # checks configuration files
    if [ ! -r "$VMTOUCHD_CONF" ]; then
        die_error "The configuration file $VMTOUCHD_CONF for daemon isn't readable."
    else
        . "$VMTOUCHD_CONF"
    fi

    if [ ! -r "$VMTOUCH_CONF" ]; then
        die_error "The configuration file $VMTOUCH_CONF isn't readable."
    fi

    if [ -z "$PIDS_FILE" ]; then 
        die_error "Variable PIDS_FILE isn't set."
    fi
    
    if [ -z "$VMTOUCHD_OPT" ]; then 
        die_error "Variable VMTOUCHD_OPT isn't set."
    fi
} # ----------  end of function _check  ----------}}}

start (){ #{{{
    if [ -s "$PIDS_FILE" ]; then
        show_warning "A vmtouch process is already running." "Stop or restart the service."
        exit 
    fi
    local prepid postpid pid
    while read line; do 
        if [[ "$line" =~ ^'#' || "$line" =~ ^$ ]]; then
            continue
        fi
        # pids of vmtouch processes
        prepid=$(pidof vmtouch)
        vmtouch $VMTOUCHD_OPT $line 
        if [ $? == 1 ]; then
            continue
        fi
        # pids of vmtouch processes + the newest
        postpid=$(pidof vmtouch)
        # Apped last the newest pid of vmtouch to the pids file.
        echo -e "${postpid%$prepid}\n" >> $PIDS_FILE
        if [ $? == 1 ]; then
            die_error "The file $PIDS_FILE isn't writeable."
        fi
    done < $VMTOUCH_CONF
} # ----------  end of function start  ----------}}}

stop (){ #{{{
    if [ -r "$PIDS_FILE" ]; then
        while read pid; do
            kill $pid
        done < $PIDS_FILE
        rm -f "$PIDS_FILE"
        if [ $? -ne 0 ]; then
            show_warning "Cann't remove the '$PIDS_FILE'." "Check the file '$PIDS_FILE'."
        fi
    fi
} # ----------  end of function stop  ----------}}}

restart (){ #{{{
   stop
   start
} # ----------  end of function restart  ----------}}}

_check

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart|reload)
        restart
        ;;
    status)
        status
        ;;
esac
