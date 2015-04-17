#!/bin/sh

# Package
PACKAGE="homeassistant"
DNAME="Home Assistant"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
PYTHON_DIR="/usr/local/python3"
PATH="${INSTALL_DIR}/bin:${INSTALL_DIR}/env/bin:${PYTHON_DIR}/bin:${PATH}"
USER="homeassistant"
PYTHON="${INSTALL_DIR}/env/bin/python3"
HOMEASSISTANT="${INSTALL_DIR}/share/homeassistant"
CFG_FILE="${INSTALL_DIR}/share/homeassistant/configuration.yaml"
PID_FILE="${INSTALL_DIR}/var/.config-lock"
LOG_FILE="${INSTALL_DIR}/var/homeassistant.log"


start_daemon ()
{
    su - ${USER} -c "PATH=${PATH} ${PYTHON} -m ${HOMEASSISTANT} --open-ui --pid ${PID_FILE}"
}

stop_daemon ()
{    
	exit 0
	;;
}

daemon_status ()
{
    if [ -f ${PID_FILE} ] && kill -0 `grep PID: ${PID_FILE} | cut -d ' ' -f2` > /dev/null 2>&1; then
        return
    fi
    rm -f ${PID_FILE}
    return 1
}

wait_for_status ()
{
    counter=$2
    while [ ${counter} -gt 0 ]; do
        daemon_status
        [ $? -eq $1 ] && return
        let counter=counter-1
        sleep 1
    done
    return 1
}


case $1 in
    start)
        if daemon_status; then
            echo ${DNAME} is already running
        else
            echo Starting ${DNAME} ...
            start_daemon
        fi
        ;;
    stop)
        if daemon_status; then
            echo Stopping ${DNAME} ...
            stop_daemon
        else
            echo ${DNAME} is not running
        fi
        ;;
    status)
        if daemon_status; then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    log)
        echo ${LOG_FILE}
        ;;
    *)
        exit 1
        ;;
esac
