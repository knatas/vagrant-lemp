#!/usr/bin/env bash

PASSWORD='root'
hosts=(test.local sandelis.local)

# install NGINX
sudo apt-get install -y nginx

# install PHP5
sudo apt-get install -y  php5-fpm php5-mysql
sudo php5enmod mcrypt

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

# install phpmyadmin and give password(s) to installer
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"
sudo apt-get -y install phpmyadmin

sudo ln -s /usr/share/phpmyadmin /usr/share/nginx/html/phpmyadmin

# setup PMA host file
VHOST=$(cat << 'EOF'
#
# A virtual host
#
server {
        listen       80;

        server_name  pma.local;
        root /usr/share/nginx/html/phpmyadmin;
        index index.html index.htm index.php;

        location / {
                try_files $uri $uri/ /index.php$is_args$args;
        }

        # pass the PHP scripts to FastCGI server listening on /var/run/php5-fpm.sock
        location ~ \.php$ {
                try_files $uri /index.php =404;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }
}
EOF
)
# Enable site
sudo echo "${VHOST}" > /etc/nginx/sites-available/pma.local.conf
sudo ln -s /etc/nginx/sites-available/pma.local.conf /etc/nginx/sites-enabled/

# Other sites
for i in ${hosts[@]}; do
VHOST=$(cat << EOF
#
# A virtual host
#
server {
        listen       80;

        server_name  $i;
        root /home/vagrant/public_html/$i;
        index index.html index.htm index.php;

        location / {
                try_files \$uri \$uri/ /index.php\$is_args\$args;
        }

        # pass the PHP scripts to FastCGI server listening on /var/run/php5-fpm.sock
        location ~ \.php\$ {
                try_files \$uri /index.php =404;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                include fastcgi_params;
        }
}
EOF
)
# Enable site
sudo echo "${VHOST}" > /etc/nginx/sites-available/$i.conf
sudo ln -s /etc/nginx/sites-available/$i.conf /etc/nginx/sites-enabled/

done

# restarting services
sudo service mysql restart
sudo service php5-fpm restart
sudo service nginx restart

