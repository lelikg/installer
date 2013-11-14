#!/usr/bin/env bash


##################################################
#  REPLACE OR ADD TO CONFIG FUNCTION DEFINITION  #
##################################################

function replace_or_add_config {
    # $1 = filename
    # $2 = conf
    # $3 = val

    grep "$2" "$1" | grep -v "^#"
    if [ $? -eq 0 ]; then
        #replace config using regex because Roni likes them :)))
        sed -ibak "s/\<#*$2\>.*/$2=$3/" $1;
    else
        echo "$2=$3" >> $1
    fi
}

# Apt update
add-apt-repository -y ppa:webupd8team/java
echo "### running apt-get update";
apt-get -y -q update;

apt-get -y -q install postfix;

echo "### Installing Packages";

#trick postfix install
touch /etc/mailname && mkdir -p /etc/postfix && touch /etc/postfix/main.cf

DEBIAN_FRONTEND=noninteractive \
apt-get -y -q install \
    htop \
    subversion \
    mysql-server \
    php5-mcrypt \
    wget \
    openssh-server \
    git \
    dos2unix \
    php5 \
    php5-cli \
    php5-mysql \
    apache2 \
    curl \
    php-apc \
    php5-gd \
    php5-curl \
    php5-xsl \
    php-pear \
    php5-memcache \
    memcached \
    mailutils \
    libjpeg62 \
    ffmpeg \
    build-essential \
    unzip \
    imagemagick \
    rsync \
    alien \
    python-software-properties \
    lib32asound2 \
    lib32gcc1 \
    lib32ncurses5 \
    lib32stdc++6 \
    lib32z1 \
    libc6-i386 \
    libwww-perl \
    nagios3 \
    oracle-java6-installer \
    sshpass;

echo 'Adding Pear Channel >>>'
sudo pear channel-discover pear.phing.info
echo 'Installing Pear >>>'
pear install phing/phing

pear install pear/VersionControl_Git-0.4.4

# fool installer pre-requisites
ln -s /usr/sbin/nagios3 /usr/sbin/nagios

ln -s /usr/sbin/cron /usr/sbin/crond

############################
#  FIX PHP CONFIGURATIONS  #
############################
replace_or_add_config /etc/php5/cli/php.ini "request_order" "CGP"
replace_or_add_config /etc/php5/apache2/php.ini "request_order" "CGP"
replace_or_add_config /etc/php5/apache2/php.ini "max_input_vars" "5000"
replace_or_add_config /etc/php5/apache2/php.ini "max_input_vars" "5000"

# enable apache modules and restart apache
a2enmod rewrite headers expires filter file_cache proxy && service apache2 restart

##############################
#  EDIT MYSQL CONFIGURATION  #
##############################
echo "### configuring my.cnf"

mycnf="/etc/mysql/my.cnf";

echo "[mysqld]" >> $mycnf

service mysql stop

replace_or_add_config $mycnf "bind_address" "0.0.0.0"

replace_or_add_config $mycnf "lower_case_table_names" "1"
replace_or_add_config $mycnf "thread_stack" "262144"
replace_or_add_config $mycnf "open_files_limit" "20000"
replace_or_add_config $mycnf "innodb_file_per_table" "1"
replace_or_add_config $mycnf "innodb_log_file_size" "32MB"

rm -rf /var/lib/mysql/ib_logfile0 /var/lib/mysql/ib_logfile1

service mysql start