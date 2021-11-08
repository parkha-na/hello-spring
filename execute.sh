#!/bin/bash
# chkconfig 2345 20 80
# written by jhjeon on 2021-06-24
# 프로세스 명을 명시한다.
readonly PROC_NAME="hello-spring"
# jar 파일
readonly DAEMON="hello-spring.jar"
# 프로세스 아이디가 존재할 패스를 설정
readonly PID_PATH="./"
readonly PROC_PID="${PID_PATH}${PROC_NAME}.pid"

max_perm_size=2g
heap_memory_size=2g
spring_profiles_active=prod

# 시작 함수
start()
{
    echo "Starting  ${PROC_NAME}..."
    local PID=$(get_status)
    if [ -n "${PID}" ]; then
        echo "${PROC_NAME} is already running"
        exit 0
    fi
    nohup java -jar -Dspring.profiles.active=${spring_profiles_active} -XX:MaxPermSize=${max_perm_size} -Xms${heap_memory_size} -Xmx${heap_memory_size} -XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError "${DAEMON}" > /dev/null 2>&1 &
    local PID=${!}

    if [ -n ${PID} ]; then
        echo " - Starting..."
        echo " - Created Process ID in ${PROC_PID}"
        echo ${PID} > ${PROC_PID}
    else
        echo " - failed to start."
    fi
}
# 디버깅
debug()
{
    echo "Starting  ${PROC_NAME}..."
    local PID=$(get_status)
    if [ -n "${PID}" ]; then
        echo "${PROC_NAME} is already running"
        exit 0
    fi
    nohup java -jar -Dspring.profiles.active=${spring_profiles_active} -XX:MaxPermSize=${max_perm_size} -Xms${heap_memory_size} -Xmx${heap_memory_size} -XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8555 "${DAEMON}" > /dev/null 2>&1 &
    local PID=${!}

    if [ -n ${PID} ]; then
        echo " - Starting debug..."
        echo " - Created Process ID in ${PROC_PID}"
        echo ${PID} > ${PROC_PID}
    else
        echo " - failed to start."
    fi
}
# 중지
stop()
{
    echo "Stopping ${PROC_NAME}..."
    local DAEMON_PID=`cat "${PROC_PID}"`

    if [ "$DAEMON_PID" -lt 3 ]; then
        echo "${PROC_NAME} was not  running."
    else
        kill $DAEMON_PID
        rm -f $PROC_PID
        echo " - Shutdown ...."
    fi
}
# 상태 
status()
{
    local PID=$(get_status)
    if [ -n "${PID}" ]; then
        echo "${PROC_NAME} is running"
    else
        echo "${PROC_NAME} is stopped"
        # start daemon
        #nohup java -jar "${DAEMON}" > /dev/null 2>&1 &
    fi
}

get_status()
{
    ps ux | grep ${PROC_NAME} | grep -v grep | awk '{print $2}'
}

# 케이스 별로 함수를 호출하도록 한다.
case "$1" in
    start)
        start
        sleep 3
        ;;
    debug)
        debug
        sleep 3
        ;;
    stop)
        stop
        sleep 3
        ;;
    status)
    status "${PROC_NAME}"
    ;;
    *)
    echo "Usage: $0 { start | debug | stop | status }"
esac
exit 0
