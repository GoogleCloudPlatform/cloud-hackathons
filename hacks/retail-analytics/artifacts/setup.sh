#!/bin/bash

if [ -f /etc/config_complete ]; then
    exit 0
fi

# Installing OS dependencies
apt-get update -y
apt-get install -y \
    wget unzip apt-transport-https \
    ca-certificates curl gnupg \
    lsb-release

# Installing the required Docker packages (https://docs.docker.com/engine/install/debian/)
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Creating Docker group and assigning the group to $USER
groupadd -f docker
usermod -aG docker $USER
newgrp docker

# Pull and Run Image (https://hub.docker.com/r/wnameless/oracle-xe-11g-r2)
docker pull wnameless/oracle-xe-11g-r2

# Starting the Oracle Docker container with port 1521 being mapped to port 1521 on host
docker run -d -p 0.0.0.0:1521:1521 -e ORACLE_ALLOW_REMOTE=true wnameless/oracle-xe-11g-r2

# Prepare the sample transactions
git clone https://github.com/caugusto/datastream-bqml-looker-tutorial.git

DOCKER_ID=`docker ps -a|grep wnameless|grep Up| awk '{print $1}'`
docker exec -i -e USER=oracle -u oracle $DOCKER_ID bash << 'EOF'
ps -ef|grep pmon
ps -ef|grep LISTENER

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE

until echo "SELECT STATUS FROM V\$INSTANCE;" | sqlplus / as sysdba | grep 'OPEN' > /dev/null; do
    sleep 5
    echo "Waiting for the Oracle instance to start..."
done

lsnrctl status LISTENER
sqlplus / as sysdba << 'EOFSQL'
SET ECHO ON
SET FEEDBACK ON
SELECT INSTANCE_NAME, STATUS, DATABASE_STATUS FROM V$INSTANCE;
SELECT log_mode FROM v$database;
ALTER USER HR IDENTIFIED BY tutorial_hr ACCOUNT UNLOCK;
exit;
EOFSQL
EOF

docker cp datastream-bqml-looker-tutorial $DOCKER_ID:/u01/app/oracle
docker exec -i $DOCKER_ID bash << EOF
chown -R oracle:dba /u01/app/oracle/datastream-bqml-looker-tutorial 
EOF

docker exec -i -e USER=oracle -u oracle $DOCKER_ID bash << 'EOF'
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE
# Create FASTFRESH SCHEMA and ORDERS TABLE
sqlplus / as sysdba << EOFSQL
SET ECHO ON
SET FEEDBACK ON
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/XE/users.dbf' AUTOEXTEND ON MAXSIZE UNLIMITED;
CREATE USER "FASTFRESH" IDENTIFIED BY tutorial_fastfresh
      DEFAULT TABLESPACE "USERS"
      TEMPORARY TABLESPACE "TEMP";
GRANT "CONNECT" TO "FASTFRESH";
GRANT "RESOURCE" TO "FASTFRESH";
GRANT UNLIMITED TABLESPACE TO "FASTFRESH";
ALTER USER FASTFRESH DEFAULT TABLESPACE USERS;
CREATE TABLE FASTFRESH.ORDERS ( 
time_of_sale TIMESTAMP WITH TIME ZONE,  
order_id NUMBER(38),  
product_name VARCHAR2(128),  
price NUMBER(38, 20),  
quantity NUMBER(38),  
payment_method VARCHAR2(26),  
store_id NUMBER(38),  
user_id NUMBER(38)
)
TABLESPACE USERS
;
exit;
EOFSQL

echo "Will load the FASTFRESH.ORDERS table next ... This will take about 10 minutes to complete ..."
bunzip2 /u01/app/oracle/datastream-bqml-looker-tutorial/sample_data/oracle_data.csv.bz2
cd /u01/app/oracle/datastream-bqml-looker-tutorial/sqlloader
./load_fastfresh_data.sh
EOF

docker exec -i -e USER=oracle -u oracle $DOCKER_ID bash << 'EOF'
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE
# Create datastream user
sqlplus / as sysdba << 'EOFSQL'
SET ECHO ON
SET FEEDBACK ON
CREATE USER datastream IDENTIFIED BY tutorial_datastream;
GRANT EXECUTE_CATALOG_ROLE TO datastream;
GRANT CONNECT TO datastream;
GRANT CREATE SESSION TO datastream;
GRANT SELECT ON SYS.V_$DATABASE TO datastream;
GRANT SELECT ON SYS.V_$ARCHIVED_LOG TO datastream;
GRANT SELECT ON SYS.V_$LOGMNR_CONTENTS TO datastream;
GRANT SELECT ON SYS.V_$LOGMNR_LOGS TO datastream;
GRANT EXECUTE ON DBMS_LOGMNR TO datastream;
GRANT EXECUTE ON DBMS_LOGMNR_D TO datastream;
GRANT SELECT ANY TRANSACTION TO datastream;
GRANT SELECT ANY TABLE TO datastream;
exit;
EOFSQL
# Enable archivelog ... Required by Datastream
sqlplus / as sysdba << EOFSQL
SET ECHO ON
SET FEEDBACK ON
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (all) COLUMNS;
ALTER SYSTEM SET ARCHIVE_LAG_TARGET = 60 scope=both;
exit;
EOFSQL
# Change RMAN retention to 4 days
rman target / << EOFSQL
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 4 DAYS;
exit;
EOFSQL
EOF

touch /etc/config_complete


