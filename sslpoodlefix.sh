#!/bin/sh
# Copyright (c) 2002-2014 by Rack-Soft, INC
# Copyright (c) 2002-2014 by 4PSA (www.4psa.com)

#Description:
#The following script patches DNS Manager 3.0.0 - 4.0.5 against CVE-2014-356
check_dnsmanager()
{
        if [ -f /usr/local/dnsmanager/.version ];then
                version=`/bin/awk '{print $1}' /usr/local/dnsmanager/.version|awk -F'.' '{print $1$2$3}'`
        else
                echo " DNSManager does not seem to be installed on this system!!!"
                exit 0
        fi
}
check_dnsmanager
if [ ${version} -ge 300 -a ${version} -lt 410  ];then
	if [ `grep -Ec "^.*ssl\.use-sslv3.*disable.*$" /usr/local/dnsmanager/admin/conf/dnsmanager.conf` -ge 1 ];then
		echo "==> Patch already aplied "
		exit 0
	fi
        echo "==> Backup config to /usr/local/dnsmanager/admin/conf/dnsmanager.conf.sslfixbackup"
        /bin/cp -fp /usr/local/dnsmanager/admin/conf/dnsmanager.conf /usr/local/dnsmanager/admin/conf/dnsmanager.conf.sslfixbackup
        echo "==> Disable SSLv3 protocol"
        /bin/sed -i 's/^.*ssl.cipher-list.*$//' /usr/local/dnsmanager/admin/conf/dnsmanager.conf
        /bin/sed -i 's/^.*ssl.engine.*$/ssl.engine\t\t= "enable"\nssl.cipher-list\t= "ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:!MD5:!aNULL:!eNULL:!NULL:!DH:!EDH:!AESGCM"\nssl.use-sslv2\t\t= "disable"\nssl.use-sslv3\t\t= "disable"\nssl.honor-cipher-order\t\t= "enable"\n/' /usr/local/dnsmanager/admin/conf/dnsmanager.conf
        echo "==> Restart Web Management Server"
        /etc/init.d/dnsmanager restart

else 
	echo "==> This patch is only for DNSManager 3.0.0 - 4.0.5"
fi
