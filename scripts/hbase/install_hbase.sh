#/bin/bash

SSH_PORT=22

#HBASE_MASTER=hbase-master.x86_64
#HBASE_THRIFT=hbase-thrift.x86_64
#HBASE_REGIONSERVER=hbase-regionserver.x86_64
#HBASE_CORE=hbase.x86_64
HBASE_MASTER=hbase-master-1.0.0+cdh5.4.7+183-1.cdh5.4.7.p0.3.el6.x86_64
HBASE_THRIFT=hbase-thrift-1.0.0+cdh5.4.7+183-1.cdh5.4.7.p0.3.el6.x86_64
HBASE_REGIONSERVER=hbase-regionserver-1.0.0+cdh5.4.7+183-1.cdh5.4.7.p0.3.el6.x86_64
HBASE_CORE=hbase-1.0.0+cdh5.4.7+183-1.cdh5.4.7.p0.3.el6.x86_64

BASE_DIR=$(cd `dirname $0`; pwd)

#HOST_SET="10.142.78.32 10.142.78.33"
MASTERS=`cat ${BASE_DIR}/masters | tr '\n' ' '`
REGIONSERVERS=`cat ${BASE_DIR}/regionservers | tr '\n' ' '`
THRIFT=`cat ${BASE_DIR}/thrift | tr '\n' ' '`

#MASTERS="10.142.78.32"
#THRIFT="10.142.78.32"
#REGIONSERVERS="10.142.78.33 10.142.78.34"

do_hbase_remove(){
    #STEP1: remove masters
    for host in ${MASTERS}
    do
        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_MASTER}"
        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_CORE}"

        ssh -p $SSH_PORT $host "[ -d /usr/lib/hbase ] && sudo rm -rf /usr/lib/hbase"
        ssh -p $SSH_PORT $host "[ -d /etc/hbase ] && sudo rm -rf /etc/hbase"
        ssh -p $SSH_PORT $host "[ -d /opt/log/hbase ] && sudo rm -rf /opt/log/hbase"
    done

    #STEP2: remove thrift
    for host in ${THRIFT}    
    do
        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_THRIFT}"
        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_CORE}"
    done

    #STEP3: remove regionservers
    for host in ${REGIONSERVERS}
    do
        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_REGIONSERVER}"
        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_CORE}"

        ssh -p $SSH_PORT $host "[ -d /usr/lib/hbase ] && sudo rm -rf /usr/lib/hbase"
        ssh -p $SSH_PORT $host "[ -d /etc/hbase ] && sudo rm -rf /etc/hbase"
        ssh -p $SSH_PORT $host "[ -d /opt/log/hbase ] && sudo rm -rf /opt/log/hbase"
    done 
}

do_hbase_install(){
    #STEP 1: install hbase masters
    for host in ${MASTERS}
    do
        ssh -p $SSH_PORT $host "[ ! -d /usr/lib/hbase ]"
        if [ $? -ne 0 ];then
            echo "hbase directory already exists. Now exit..."
        fi 

        #try to do removal first
        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_MASTER}"
        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_CORE}"

        #now do installation
        ssh -p $SSH_PORT $host "sudo yum install -y ${HBASE_MASTER}"    

        #create log dir and log file
        ssh -p $SSH_PORT $host '[ ! -f /opt/log/hbase/hbase.log ] && sudo mkdir -p /opt/log/hbase && sudo touch /opt/log/hbase/hbase.log && sudo chmod -R 777 /opt/log/hbase && sudo chown -R hbase:hbase /opt/log/hbase'

    done

    #STEP2: install thrift
    for host in ${THRIFT}
    do
        #ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_THRIFT}"

        ssh -p $SSH_PORT $host "sudo yum install -y ${HBASE_THRIFT}"
    done


    #STEP3: install regionservers
    for host in ${REGIONSERVERS}
    do
        ssh -p $SSH_PORT $host "[ ! -d /usr/lib/hbase ]"
        if [ $? -ne 0 ];then
            echo "hbase directory already exists. Now exit..."
        fi

        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_REGIONSERVER}"
        ssh -p $SSH_PORT $host "sudo yum remove -y ${HBASE_CORE}"

        ssh -p $SSH_PORT $host "sudo yum install -y ${HBASE_REGIONSERVER}"
      
        ssh -p $SSH_PORT $host '[ ! -f /opt/log/hbase/hbase.log ] && sudo mkdir -p /opt/log/hbase && sudo touch /opt/log/hbase/hbase.log && sudo chmod -R 777 /opt/log/hbase && sudo chown -R hbase:hbase /opt/log/hbase'
    done
}

case "$1" in
    'install')
        do_hbase_install
        ;;
    'remove')
        do_hbase_remove
        ;;
    *)
        echo "Usage: $0 {install|remove}"
        exit 1
esac

exit 0

