#!/bin/bash 
PID_FILENAME=teleicu-service-data.pid

#启动检查最大超时时间（单位s）
MAX_TIMEOUT=60

TARGET_PATH=$(cd `dirname $0`; pwd)
cd ${TARGET_PATH}

#获取app名称
APP_NAME=$(find . -maxdepth 1 -name *.jar|cut -c 3-)

cd ${TARGET_PATH}
if [ -f ${PID_FILENAME} ];then
  pid=$(cat ${PID_FILENAME})
else
  pid=$(ps -ef|grep ${APP_NAME}|grep -v grep|grep -v kill|awk '{print $2}')
fi

if [ ${pid} ];then
  echo ${APP_NAME}' is running with pid:'${pid}
  echo "killing pid:"${pid}
  kill -s 9 ${pid}
  for ((i=0; i<${MAX_TIMEOUT}; i++))
  do
    sleep 1
    ps -ef|grep -v grep|grep -v kill|awk '{print $2}'|grep ${pid}
    if [ $? -ne 0 ];then
      break
    else
      echo 'stopping... '${i}
    fi
  done
fi
echo 'starting '${APP_NAME}
nohup java -jar ${APP_NAME} > /dev/null &
