#!/bin/bash

# Manage log leve of restcomm app
# Maintainer Gennadiy Dubina - gennadiy.dubina@dataart.com

RESTCOMM_CORE_LOG=$BASEDIR/standalone/log
MMS_LOGS=$BASEDIR/mediaserver/log

xmli(){
  file=${@: -1}
  xml $@ > "$file.1"
  mv "$file.1" $file
}

configure_component_log(){
  component=$1
  level=$2
  file=$3
  root="//log:subsystem"
  namespace='urn:jboss:domain:logging:1.2'
  elNumbers=$(xml sel -N log=$namespace -t -v "count(//log:logger[@category='$component'])" $file)
  if [ "$elNumbers" -eq 0 ]; then
    xmli ed -N log=$namespace \
        -s "$root" -t elem -n 'logger_new' \
        -i "$root/logger_new" -t attr -n 'category' -v "$component" \
        -s "$root/logger_new" -t elem -n 'level' \
        -i "$root/logger_new/level" -t attr -n 'name' -v "$level" \
        -r "$root/logger_new" -v 'logger' \
        $file
  else
    xmli ed -N log=$namespace \
        -u "//log:logger[@category='$component']/log:level/@name" -v "$level" \
        $file
  fi
}

##### Manage log level #####

if [ -n "$LOG_LEVEL" ]; then
  echo "LOG_LEVEL $LOG_LEVEL"

  namespace='urn:jboss:domain:logging:1.2'
  xmli ed -N log=$namespace -u "//log:logger[@category='org.mobicents.servlet.sip']/@category" -v 'org.mobicents.servlet' $BASEDIR/standalone/configuration/standalone-sip.xml
  xmli ed -N log=$namespace -u "//log:level/@name" -v $LOG_LEVEL $BASEDIR/standalone/configuration/standalone-sip.xml
  xmli ed -N log=$namespace \
      -s "//log:periodic-rotating-file-handler" -t elem -n 'level' \
      -i "//log:periodic-rotating-file-handler/level" -t attr -n 'value' -v "$LOG_LEVEL" \
      $BASEDIR/standalone/configuration/standalone-sip.xml

  xmli ed -u "//param[@name='Threshold']/@value" -v "$LOG_LEVEL" $BASEDIR/mediaserver/conf/log4j.xml 
  xmli ed -u "//priority/@value" -v $LOG_LEVEL $BASEDIR/mediaserver/conf/log4j.xml
fi

if [ -n "$GOVNIST_LOG_LEVEL" ]; then
  namespace='urn:jboss:domain:logging:1.2'
  xmli ed -N log=$namespace -u "//log:logger[@category='gov.nist']/log:level/@name" -v $GOVNIST_LOG_LEVEL $BASEDIR/standalone/configuration/standalone-sip.xml
fi

for i in $( set -o posix ; set | grep ^LOG_LEVEL_COMPONENT_ | sort -rn ); do
    component=$(echo ${i} | cut -d = -f2)
    level=$(echo ${i} | cut -d = -f3)

    echo "Configure log level for: $component -> $level"

    configure_component_log "$component" "$level" $BASEDIR/standalone/configuration/standalone-sip.xml
done

echo "Log level coniguration done"

##### Manage log files location #####

if [ -n "$RESTCOMM_LOGS" ]; then
  echo "RESTCOMM_LOGS $RESTCOMM_LOGS"
  sed -i "s|BASEDIR=.*| |" $BASEDIR/bin/restcomm/logs_collect.sh
  sed -i "s|LOGS_DIR_ZIP=.*|LOGS_DIR_ZIP=$RESTCOMM_LOGS/\$DIR_NAME|" $BASEDIR/bin/restcomm/logs_collect.sh
  sed -i "s|RESTCOMM_LOG_BASE=.*|RESTCOMM_LOG_BASE=`echo $RESTCOMM_LOGS`|" /opt/embed/restcomm_docker.sh

  LOGS_LOCATE=`echo $RESTCOMM_LOGS`
  sudo mkdir -p "$LOGS_LOCATE"
  RESTCOMM_CORE_LOG=$LOGS_LOCATE
  MMS_LOGS=$LOGS_LOCATE
  LOGS_TRACE=$LOGS_LOCATE
fi

if [ -n "$CORE_LOGS_LOCATION" ]; then
  echo "CORE_LOGS_LOCATION $CORE_LOGS_LOCATION"
  mkdir -p `echo $CORE_LOGS_LOCATION`
  sed -i "s|find .*server.log|find $RESTCOMM_CORE_LOG/$CORE_LOGS_LOCATION/restcommCore-server.log*|" /etc/cron.d/restcommcore-cron

  xmli ed -u "//_:file[@relative-to='jboss.server.log.dir']/@path" -v "$RESTCOMM_CORE_LOG/$CORE_LOGS_LOCATION/restcommCore-server.log" $BASEDIR/standalone/configuration/standalone-sip.xml
  #logs collect script conficuration
  sed -i "s/RESTCOMM_CORE_FILE=server.log/RESTCOMM_CORE_FILE=restcommCore-server.log/" $BASEDIR/bin/restcomm/logs_collect.sh
  sed -i "s|RESTCOMM_CORE_LOG=.*|RESTCOMM_CORE_LOG=$RESTCOMM_CORE_LOG/$CORE_LOGS_LOCATION|" $BASEDIR/bin/restcomm/logs_collect.sh
  sed -i "s|RESTCOMM_LOG_BASE=.*|RESTCOMM_LOG_BASE=$CORE_LOGS_LOCATION|" $BASEDIR/bin/restcomm/logs_collect.sh

fi

if [ -n "$MEDIASERVER_LOGS_LOCATION" ]; then
  echo "MEDIASERVER_LOGS_LOCATION $MEDIASERVER_LOGS_LOCATION"
  mkdir -p `echo $MEDIASERVER_LOGS_LOCATION`
  sed -i "s|find .*server.log|find $MMS_LOGS/`echo $MEDIASERVER_LOGS_LOCATION`/media-server.log*|" /etc/cron.d/restcommmediaserver-cron
  sed -i 's/configLogDirectory$/#configLogDirectory/' $BASEDIR/bin/restcomm/autoconfig.d/config-mobicents-ms.sh
  #Daily log rotation for MS.
  xmli ed -u "//appender[@name='FILE']/@class" -v "org.apache.log4j.DailyRollingFileAppender" $BASEDIR/mediaserver/conf/log4j.xml
  xmli ed -u "//appender[@name='FILE']/param[@name='Append']/@value" -v 'true' $BASEDIR/mediaserver/conf/log4j.xml
  xmli ed -u "//appender[@name='FILE']/param[@name='File']/@value" -v "$MMS_LOGS/$MEDIASERVER_LOGS_LOCATION/media-server.log" $BASEDIR/mediaserver/conf/log4j.xml
  
  #logs collect script conficuration
  sed -i "s|MEDIASERVER_FILE=server.log|MEDIASERVER_FILE=media-server.log|" $BASEDIR/bin/restcomm/logs_collect.sh
  sed -i "s|MMS_LOGS=.*|MMS_LOGS=$MMS_LOGS/`echo $MEDIASERVER_LOGS_LOCATION`|" $BASEDIR/bin/restcomm/logs_collect.sh
fi

if [ -n "$RESTCOMM_TRACE_LOG" ]; then
  echo "RESTCOMM_TRACE_LOG $RESTCOMM_TRACE_LOG"
  mkdir -p $LOGS_TRACE/$RESTCOMM_TRACE_LOG
  sed -i "s|find .*restcomm_trace_|find $LOGS_TRACE/`echo $RESTCOMM_TRACE_LOG`/restcomm_trace_|" /etc/cron.d/restcommtcpdump-cron
  sed -i "s|RESTCOMM_TRACE=.*|RESTCOMM_TRACE=\$RESTCOMM_LOG_BASE/`echo $RESTCOMM_TRACE_LOG`|"  /opt/embed/restcomm_docker.sh
  nohup xargs bash -c "tcpdump -pni any -t -n -s 0  \"portrange 5060-5063 or (udp and portrange 65000-65535) or port 80 or port 443 or port 2427 or port 2727\" -G 3500 -w $LOGS_TRACE/$RESTCOMM_TRACE_LOG/restcomm_trace_%Y-%m-%d_%H:%M:%S-%Z.pcap -z gzip" &

  TCPFILE="/etc/my_init.d/restcommtrace.sh"
    cat <<EOT >> $TCPFILE
#!/bin/bash
    nohup xargs bash -c "tcpdump -pni any -t -n -s 0  \"portrange 5060-5063 or (udp and portrange 65000-65535) or port 80 or port 443 or port 2427 or port 2727\" -G 3500 -w $LOGS_TRACE/$RESTCOMM_TRACE_LOG/restcomm_trace_%Y-%m-%d_%H:%M:%S-%Z.pcap -z gzip" &
EOT
    chmod 777 $TCPFILE
fi

