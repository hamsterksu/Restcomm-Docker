#!/bin/bash
#Maintainer George Vagenas - gvagenas@telestax.com
#Maintainer Jean Deruelle - jean.deruelle@telestax.com
#Maintainer Lefteris Banos -liblefty@telestax.com

source /etc/container_environment.sh


BASEDIR=/opt/Restcomm-JBoss-AS7
RESTCOMM_CORE_LOG=$BASEDIR/standalone/log
MMS_LOGS=$BASEDIR/mediaserver/log

echo "Will check for enviroment variable and configure restcomm.conf"


if [ -n "$RESTCOMM_LOGS" ]; then
  echo "RESTCOMM_LOGS $RESTCOMM_LOGS"
  sed -i "s|BASEDIR=.*| |" /opt/Restcomm-JBoss-AS7/bin/restcomm/logs_collect.sh
  sed -i "s|LOGS_DIR_ZIP=.*|LOGS_DIR_ZIP=$RESTCOMM_LOGS/\$DIR_NAME|" /opt/Restcomm-JBoss-AS7/bin/restcomm/logs_collect.sh
  sed -i "s|RESTCOMM_LOG_BASE=.*|RESTCOMM_LOG_BASE=`echo $RESTCOMM_LOGS`|" /opt/embed/restcomm_docker.sh

  LOGS_LOCATE=`echo $RESTCOMM_LOGS`
  sudo mkdir -p "$LOGS_LOCATE"
  RESTCOMM_CORE_LOG=$LOGS_LOCATE
  MMS_LOGS=$LOGS_LOCATE
  LOGS_TRACE=$LOGS_LOCATE
fi

if [ -n "$STATIC_ADDRESS" ]; then
  echo "STATIC_ADDRESS $STATIC_ADDRESS"
  sed -i "s/STATIC_ADDRESS=.*/STATIC_ADDRESS=`echo $STATIC_ADDRESS`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$RESTCOMM_PORT" ]; then
  echo "RESTCOMM_PORT $RESTCOMM_PORT"
  sed -i "s|8080|$RESTCOMM_PORT|"   $BASEDIR/standalone/configuration/standalone-sip.xml
  sed -i "s|8080|$RESTCOMM_PORT|"   $BASEDIR/standalone/configuration/mss-sip-stack.properties
  sed -i "s|:8080|:$RESTCOMM_PORT|"    $BASEDIR/bin/restcomm/autoconfig.d/config-restcomm.sh
fi

if [ -n "$OUTBOUND_PROXY" ]; then
  echo "OUTBOUND_PROXY $OUTBOUND_PROXY"
  sed -i "s/OUTBOUND_PROXY=.*/OUTBOUND_PROXY=`echo $OUTBOUND_PROXY`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$OUTBOUND_PROXY_USERNAME" ]; then
  echo "OUTBOUND_PROXY_USERNAME $OUTBOUND_PROXY_USERNAME"
  sed -i "s/OUTBOUND_PROXY_USERNAME=.*/OUTBOUND_PROXY_USERNAME=`echo $OUTBOUND_PROXY_USERNAME`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$OUTBOUND_PROXY_PASSWORD" ]; then
  echo "OUTBOUND_PROXY_PASSWORD $OUTBOUND_PROXY_PASSWORD"
  sed -i "s/OUTBOUND_PROXY_PASSWORD=.*/OUTBOUND_PROXY_PASSWORD=`echo $OUTBOUND_PROXY_PASSWORD`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$MEDIASERVER_LOWEST_PORT" ]; then
  echo "MEDIASERVER_LOWEST_PORT $MEDIASERVER_LOWEST_PORT"
  sed -i "s/MEDIASERVER_LOWEST_PORT=.*/MEDIASERVER_LOWEST_PORT=`echo $MEDIASERVER_LOWEST_PORT`/" $BASEDIR/bin/restcomm/restcomm.conf
else
  MEDIASERVER_LOWEST_PORT='65000'
  echo "MEDIASERVER_LOWEST_PORT $MEDIASERVER_LOWEST_PORT"
  sed -i "s/MEDIASERVER_LOWEST_PORT=.*/MEDIASERVER_LOWEST_PORT=`echo $MEDIASERVER_LOWEST_PORT`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$MEDIASERVER_HIGHEST_PORT" ]; then
  echo "MEDIASERVER_HIGHEST_PORT $MEDIASERVER_HIGHEST_PORT"
  sed -i "s/MEDIASERVER_HIGHEST_PORT=.*/MEDIASERVER_HIGHEST_PORT=`echo $MEDIASERVER_HIGHEST_PORT`/" $BASEDIR/bin/restcomm/restcomm.conf
else
  MEDIASERVER_HIGHEST_PORT='65535'
  echo "MEDIASERVER_HIGHEST_PORT $MEDIASERVER_HIGHEST_PORT"
  sed -i "s/MEDIASERVER_HIGHEST_PORT=.*/MEDIASERVER_HIGHEST_PORT=`echo $MEDIASERVER_HIGHEST_PORT`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$PROVISION_PROVIDER" ]; then
  echo "PROVISION_PROVIDER $PROVISION_PROVIDER"
  sed -i "s/PROVISION_PROVIDER=.*/PROVISION_PROVIDER=`echo $PROVISION_PROVIDER`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$DID_LOGIN" ]; then
  echo "DID_LOGIN $DID_LOGIN"
  sed -i "s/DID_LOGIN=.*/DID_LOGIN=`echo $DID_LOGIN`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$DID_PASSWORD" ]; then
  echo "DID_PASSWORD $DID_PASSWORD"
  sed -i "s/DID_PASSWORD=.*/DID_PASSWORD=`echo $DID_PASSWORD`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$SMS_PREFIX" ]; then
  echo "SMS_PREFIX $SMS_PREFIX"
  sed -i "s/SMS_PREFIX=.*/SMS_PREFIX=`echo $SMS_PREFIX`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$GENERIC_SMPP_TYPE" ]; then
  echo "Generic SMPP type $GENERIC_SMPP_TYPE"
  sed -i "s/SMPP_ACTIVATE=.*/SMPP_ACTIVATE='true'/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_SYSTEM_ID=.*/SMPP_SYSTEM_ID="`echo $GENERIC_SMPP_ID`"/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_PASSWORD=.*/SMPP_PASSWORD="`echo $GENERIC_SMPP_PASSWORD`"/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_SYSTEM_TYPE=.*/SMPP_SYSTEM_TYPE="`echo $GENERIC_SMPP_TYPE`"/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_PEER_IP=.*/SMPP_PEER_IP="`echo $GENERIC_SMPP_PEER_IP`"/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_PEER_PORT=.*/SMPP_PEER_PORT="`echo $GENERIC_SMPP_PEER_PORT`"/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s|<connection activateAddressMapping=\"false\" sourceAddressMap=\"\" destinationAddressMap=\"\" tonNpiValue=\"1\">|<connection activateAddressMapping=\"false\" sourceAddressMap=\""`echo $GENERIC_SMPP_SOURCE_MAP`"\" destinationAddressMap=\""`echo $GENERIC_SMPP_DEST_MAP`"\" tonNpiValue=\"1\">|" $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/conf/restcomm.xml
fi

if [ -n "$NEXMO_SMPP_TYPE" ]; then
  echo "NEXMO_SMPP_TYPE $NEXMO_SMPP_TYPE"
  sed -i "s/SMPP_ACTIVATE=.*/SMPP_ACTIVATE='true'/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_SYSTEM_ID=.*/SMPP_SYSTEM_ID='`echo $DID_LOGIN`'/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_PASSWORD=.*/SMPP_PASSWORD='`echo $DID_PASSWORD`'/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_SYSTEM_TYPE=.*/SMPP_SYSTEM_TYPE='`echo $NEXMO_SMPP_TYPE`'/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_PEER_IP=.*/SMPP_PEER_IP='smpp0.nexmo.com'/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s/SMPP_PEER_PORT=.*/SMPP_PEER_PORT='8000'/" $BASEDIR/bin/restcomm/smpp.conf
  sed -i "s|<connection activateAddressMapping=\"false\" sourceAddressMap=\"\" destinationAddressMap=\"\" tonNpiValue=\"1\">|<connection activateAddressMapping=\"false\" sourceAddressMap=\"6666\" destinationAddressMap=\"7777\" tonNpiValue=\"1\">|" $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/conf/restcomm.xml
fi

if [ -n "$DID_ENDPOINT" ]; then
  echo "DID_ENDPOINT $DID_ENDPOINT"
  sed -i "s/DID_ENDPOINT=.*/DID_ENDPOINT=`echo $DID_ENDPOINT`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$DID_SITEID" ]; then
  echo "DID_SITEID $DID_SITEID"
  sed -i "s/DID_SITEID=.*/DID_SITEID=`echo $DID_SITEID`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$DID_ACCOUNTID" ]; then
  echo "DID_ACCOUNTID $DID_ACCOUNTID"
  sed -i "s/DID_ACCOUNTID=.*/DID_ACCOUNTID=`echo $DID_ACCOUNTID`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$INTERFAX_USER" ]; then
  echo "INTERFAX_USER $INTERFAX_USER"
  sed -i "s/INTERFAX_USER=.*/INTERFAX_USER=`echo $INTERFAX_USER`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$INTERFAX_PASSWORD" ]; then
  echo "INTERFAX_PASSWORD $INTERFAX_PASSWORD"
  sed -i "s/INTERFAX_PASSWORD=.*/INTERFAX_PASSWORD=`echo $INTERFAX_PASSWORD`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$ISPEECH_KEY" ]; then
  echo "ISPEECH_KEY $ISPEECH_KEY"
  sed -i "s/ISPEECH_KEY=.*/ISPEECH_KEY=`echo $ISPEECH_KEY`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$VOICERSS_KEY" ]; then
  echo "VoiceRSS key: $VOICERSS_KEY"
  sed -i "s/VOICERSS_KEY=.*/VOICERSS_KEY=`echo $VOICERSS_KEY`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$ACAPELA_APPLICATION" ]; then
  echo "ACAPELA_APPLICATION $ACAPELA_APPLICATION"
  sed -i "s/ACAPELA_APPLICATION=.*/ACAPELA_APPLICATION=`echo $ACAPELA_APPLICATION`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$ACAPELA_LOGIN" ]; then
  echo "ACAPELA_LOGIN $ACAPELA_LOGIN"
  sed -i "s/ACAPELA_LOGIN=.*/ACAPELA_LOGIN=`echo $ACAPELA_LOGIN`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$ACAPELA_PASSWORD" ]; then
  echo "ACAPELA_PASSWORD $ACAPELA_PASSWORD"
  sed -i "s/ACAPELA_PASSWORD=.*/ACAPELA_PASSWORD=`echo $ACAPELA_PASSWORD`/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$S3_BUCKET_NAME" ]; then
  echo "S3_BUCKET_NAME $S3_BUCKET_NAME S3_ACCESS_KEY $S3_ACCESS_KEY S3_SECURITY_KEY $S3_SECURITY_KEY"
  sed -i "/<amazon-s3>/ {
		N; s|<enabled>.*</enabled>|<enabled>true</enabled>|
		N; s|<bucket-name>.*</bucket-name>|<bucket-name>`echo $S3_BUCKET_NAME`</bucket-name>|
		N; s|<folder>.*</folder>|<folder>logs</folder>|
		N; s|<access-key>.*</access-key>|<access-key>`echo $S3_ACCESS_KEY`</access-key>|
		N; s|<security-key>.*</security-key>|<security-key>`echo $S3_SECURITY_KEY`</security-key>|
	}" $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/conf/restcomm.xml
fi

if [ -n "$HSQL_PERSIST" ]; then
  echo "HSQL_PERSIST $HSQL_PERSIST"
  mkdir -p $HSQL_PERSIST
  sed -i "s|<data-files>.*</data-files>|<data-files>`echo $HSQL_PERSIST`</data-files>|"  $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/conf/restcomm.xml
  cp $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/data/hsql/* $HSQL_PERSIST
fi

if [ -n "$SMTP_USER" ]; then
  echo "SMTP_USER $SMTP_USER SMTP_PASSWORD $SMTP_PASSWORD SMTP_HOST $SMTP_HOST"
  sed -i "/<smtp-notify>/ {
		N; s|<host>.*</host>|<host>`echo $SMTP_HOST`</host>|
		N; s|<user>.*</user>|<user>`echo $SMTP_USER`</user>|
		N; s|<password>.*</password>|<password>`echo $SMTP_PASSWORD`</password>|
	}" $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/conf/restcomm.xml

  sed -i "/<smtp-service>/ {
		N; s|<host>.*</host>|<host>`echo $SMTP_HOST`</host>|
		N; s|<user>.*</user>|<user>`echo $SMTP_USER`</user>|
		N; s|<password>.*</password>|<password>`echo $SMTP_PASSWORD`</password>|
	}" $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/conf/restcomm.xml
fi

if [ -n "$MYSQL_USER" ]; then
  echo "MYSQL_USER $MYSQL_USER MYSQL_HOST $MYSQL_HOST MYSQL_SCHEMA $MYSQL_SCHEMA"
  grep -q 'MYSQL_HOST=' $BASEDIR/bin/restcomm/restcomm.conf || echo "MYSQL_HOST=`echo $MYSQL_HOST`" >> $BASEDIR/bin/restcomm/restcomm.conf
  grep -q 'MYSQL_USER=' $BASEDIR/bin/restcomm/restcomm.conf ||  echo "MYSQL_USER=`echo $MYSQL_USER`" >> $BASEDIR/bin/restcomm/restcomm.conf
  grep -q 'MYSQL_PASSWORD=' $BASEDIR/bin/restcomm/restcomm.conf ||  echo "MYSQL_PASSWORD=`echo $MYSQL_PASSWORD`" >> $BASEDIR/bin/restcomm/restcomm.conf
  if [ -n "$MYSQL_SCHEMA" ]; then
	grep -q 'MYSQL_SCHEMA=' $BASEDIR/bin/restcomm/restcomm.conf || echo "MYSQL_SCHEMA=`echo $MYSQL_SCHEMA`" >> $BASEDIR/bin/restcomm/restcomm.conf
  else
	$MYSQL_SCHEMA="restcomm"
	  grep -q 'MYSQL_SCHEMA=' $BASEDIR/bin/restcomm/restcomm.conf || echo "MYSQL_SCHEMA=`echo $MYSQL_SCHEMA`" >> $BASEDIR/bin/restcomm/restcomm.conf
  fi
  echo "MYSQL_USER $MYSQL_USER MYSQL_HOST $MYSQL_HOST MYSQL_SCHEMA $MYSQL_SCHEMA"
  sed -i "s|restcomm;|${MYSQL_SCHEMA};|" $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/scripts/mariadb/init.sql
  source $BASEDIR/bin/restcomm/populate-update-mysqldb.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA
fi

if [ -n "$INIT_PASSWORD" ]; then
    juju-log "Update init password"
    # chnange admin password
    SQL_FILE=/opt/restcomm/standalone/deployments/restcomm.war/WEB-INF/scripts/mariadb/init.sql
    sed -i "s/uninitialized/active/g" $SQL_FILE
    sed -i "s/77f8c12cc7b8f8423e5c38b035249166/$INIT_PASSWORD/g" $SQL_FILE
    sed -i "s/2012-04-24 00:00:00.000000000/2016-02-18 10:00:00.575000000/" $SQL_FILE
    sed -i "s/2012-04-24 00:00:00.000000000/2016-02-18 10:10:00.575000000/" $SQL_FILE

    SQL_FILE=/opt/restcomm/standalone/deployments/restcomm.war/WEB-INF/data/hsql/restcomm.script
    sed -i "s/uninitialized/active/g" $SQL_FILE
    sed -i "s/77f8c12cc7b8f8423e5c38b035249166/$INIT_PASSWORD/g" $SQL_FILE
    sed -i "s/2012-04-24 00:00:00.000000000/2016-02-18 10:00:00.575000000/" $SQL_FILE
    sed -i "s/2012-04-24 00:00:00.000000000/2016-02-18 10:10:00.575000000/" $SQL_FILE

    # end 
fi

if [ -n "$SSL_MODE" ]; then
	sed -i "s/SSL_MODE=.*/SSL_MODE='`echo $SSL_MODE`'/" $BASEDIR/bin/restcomm/restcomm.conf
fi

if [ -n "$USE_STANDARD_PORTS" ]; then
  echo "USE_STANDARD_PORTS $USE_STANDARD_PORTS"
  sed -i "s|8080|80|"   $BASEDIR/standalone/configuration/standalone-sip.xml
  sed -i "s|8080|80|"   $BASEDIR/standalone/configuration/mss-sip-stack.properties
  sed -i "s|8443|443|"  $BASEDIR/standalone/configuration/standalone-sip.xml
  sed -i "s|8443|443|"  $BASEDIR/standalone/configuration/mss-sip-stack.properties
  sed -i "s|:8080||"    $BASEDIR/bin/restcomm/autoconfig.d/config-restcomm.sh
  sed -i "s|5080|5060|" $BASEDIR/standalone/configuration/standalone-sip.xml
  sed -i "s|5081|5061|" $BASEDIR/standalone/configuration/standalone-sip.xml
  sed -i "s|5082|5062|" $BASEDIR/standalone/configuration/standalone-sip.xml
  sed -i "s|5080|5060|" $BASEDIR/bin/restcomm/autoconfig.d/config-sip-connectors.sh
  sed -i "s|5081|5061|" $BASEDIR/bin/restcomm/autoconfig.d/config-sip-connectors.sh
  sed -i "s|5082|5062|" $BASEDIR/bin/restcomm/autoconfig.d/config-sip-connectors.sh
  sed -i "s|:5080||"    $BASEDIR/bin/restcomm/autoconfig.d/config-restcomm.sh
fi

if [ -n "$RVD_LOCATION" ]; then
  echo "RVD_LOCATION $RVD_LOCATION"
  mkdir -p `echo $RVD_LOCATION`
  sed -i "s|<workspaceLocation>.*</workspaceLocation>|<workspaceLocation>`echo $RVD_LOCATION`</workspaceLocation>|" $BASEDIR/standalone/deployments/restcomm-rvd.war/WEB-INF/rvd.xml
fi

if [ -n "$LOG_LEVEL" ]; then
  echo "LOG_LEVEL $LOG_LEVEL"
  sed -i "s|<logger category=\"org.mobicents.servlet.sip\">|<logger category=\"org.mobicents.servlet\">|" $BASEDIR/standalone/configuration/standalone-sip.xml
  sed -i "/<logger category=\"org.mobicents.servlet\">/ {
		N; s|<level name=\".*\"/>|<level name=\"`echo $LOG_LEVEL`\"/>|
	}" $BASEDIR/standalone/configuration/standalone-sip.xml
    sed -i  "s|<param name=\"Threshold\" value=\"INFO\" />|<param name=\"Threshold\" value=\"`echo $LOG_LEVEL`\" />|"  $BASEDIR/mediaserver/conf/log4j.xml

fi

if [ -n "$CORE_LOGS_LOCATION" ]; then
  echo "CORE_LOGS_LOCATION $CORE_LOGS_LOCATION"
  mkdir -p `echo $CORE_LOGS_LOCATION`
  sed -i "s|find .*server.log|find $RESTCOMM_CORE_LOG/`echo $CORE_LOGS_LOCATION`/restcommCore-server.log|" /etc/cron.d/restcommcore-cron
  sed -i "s|<file relative-to=\"jboss.server.log.dir\" path=\".*\"\/>|<file path=\"$RESTCOMM_CORE_LOG/`echo $CORE_LOGS_LOCATION`/restcommCore-server.log\"\/>|" $BASEDIR/standalone/configuration/standalone-sip.xml
  #logs collect script conficuration
  sed -i "s/RESTCOMM_CORE_FILE=server.log/RESTCOMM_CORE_FILE=restcommCore-server.log/" /opt/Restcomm-JBoss-AS7/bin/restcomm/logs_collect.sh
  sed -i "s|RESTCOMM_CORE_LOG=.*|RESTCOMM_CORE_LOG=$RESTCOMM_CORE_LOG/`echo $CORE_LOGS_LOCATION`|" /opt/Restcomm-JBoss-AS7/bin/restcomm/logs_collect.sh
  sed -i "s|RESTCOMM_LOG_BASE=.*|RESTCOMM_LOG_BASE=`echo $CORE_LOGS_LOCATION`|" /opt/Restcomm-JBoss-AS7/bin/restcomm/logs_collect.sh

fi

#Media-server Log configuration.
if [ -n "$MEDIASERVER_LOGS_LOCATION" ]; then
  echo "MEDIASERVER_LOGS_LOCATION $MEDIASERVER_LOGS_LOCATION"
  mkdir -p `echo $MEDIASERVER_LOGS_LOCATION`
  sed -i "s|find .*server.log|find $MMS_LOGS/`echo $MEDIASERVER_LOGS_LOCATION`/media-server.log|" /etc/cron.d/restcommmediaserver-cron
  sed -i 's/configLogDirectory$/#configLogDirectory/' $BASEDIR/bin/restcomm/autoconfig.d/config-mobicents-ms.sh
  #Daily log rotation for MS.
  sed -i "s|<appender name=\"FILE\" class=\"org\.apache\.log4j\.RollingFileAppender\"|<appender name=\"FILE\" class=\"org\.apache\.log4j\.DailyRollingFileAppender\"|"  $BASEDIR/mediaserver/conf/log4j.xml
  sed -i "s|<param name=\"Append\" value=\"false\"|<param name=\"Append\" value=\"true\"|"  $BASEDIR/mediaserver/conf/log4j.xml
  sed -i "s|<param name=\"File\" value=\".*\"|<param name=\"File\" value=\"$MMS_LOGS/`echo $MEDIASERVER_LOGS_LOCATION`/media-server.log\"|"  $BASEDIR/mediaserver/conf/log4j.xml
  #logs collect script conficuration
  sed -i "s|MEDIASERVER_FILE=server.log|MEDIASERVER_FILE=media-server.log|" /opt/Restcomm-JBoss-AS7/bin/restcomm/logs_collect.sh
  sed -i "s|MMS_LOGS=.*|MMS_LOGS=$MMS_LOGS/`echo $MEDIASERVER_LOGS_LOCATION`|" /opt/Restcomm-JBoss-AS7/bin/restcomm/logs_collect.sh
fi

if [ -n "$GOVNIST_LOG_LEVEL" ]; then
  sed -i "/<logger category=\"gov.nist\">/ {N; s/<level name=\"INFO\"\/>/<level name=\"`echo $GOVNIST_LOG_LEVEL`\"\/>/}" $BASEDIR/standalone/configuration/standalone-sip.xml
fi

if [ -n "$NFSMOUNT" ]; then
   if grep -qs '/mnt/nfs/home/rvd/workspace' /proc/mounts; then
    echo "It's mounted.";
  else
    echo "It's not mounted.";
    sudo mount -t nfs 54.83.206.20:/opt/$NFSMOUNT/rvd_workspace /mnt/nfs/home/rvd/workspace
  fi
fi

if [ -n "$RESTCOMM_TRACE_LOG" ]; then
  echo "RESTCOMM_TRACE_LOG $RESTCOMM_TRACE_LOG"
  mkdir -p $LOGS_TRACE/$RESTCOMM_TRACE_LOG
  sed -i "s|find .*restcomm_trace_|find $LOGS_TRACE/`echo $RESTCOMM_TRACE_LOG`/restcomm_trace_|" /etc/cron.d/restcommtcpdump-cron
  sed -i "s|RESTCOMM_TRACE=.*|RESTCOMM_TRACE=\$RESTCOMM_LOG_BASE/`echo $RESTCOMM_TRACE_LOG`|"  /opt/embed/restcomm_docker.sh
  ps cax | grep tcpdump > /dev/null
  if [ $? -eq 0 ]; then
    echo "TCPDUMP  is running."
  else
    echo "TCPDUMP is not running, need to run it."
    nohup xargs bash -c "tcpdump -pni eth0 -t -n -s 0  \"portrange 5060-5063 or (udp and portrange 65000-65535) or port 80 or port 443 or port 9990\" -G 9000 -w $LOGS_TRACE/$RESTCOMM_TRACE_LOG/restcomm_trace_%Y-%m-%d_%H:%M:%S-%Z.pcap -z gzip" &
  fi

fi

if [ -n "$RESTCOMMHOST" ]; then
  echo "HOSTNAME $RESTCOMMHOST"
  sed -i "s|<hostname>.*<\/hostname>|<hostname>`echo $RESTCOMMHOST`<\/hostname>|" $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/conf/restcomm.xml
else
  sed -i "s|<hostname>.*<\/hostname>|<hostname>`echo $STATIC_ADDRESS`<\/hostname>|" $BASEDIR/standalone/deployments/restcomm.war/WEB-INF/conf/restcomm.xml
 fi

