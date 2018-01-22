# Remove installed Apache or PHP
sudo yum remove httpd* php* -y
# Install Apache 2.4, MariaDB and PHP 7.0
sudo yum install -y httpd24 mariadb-server php70 php70-gd php70-imap php70-mbstring php70-mysqlnd php70-opcache php70-pdo php70-pecl-apcu
# Start Apache, MariaDB now, and enable Apache, MariaDB on startup
sudo service httpd start && sudo chkconfig httpd on
sudo service mysql start && sudo chkconfig mysql on
# Change the group of "ec2-user"
sudo usermod -a -G apache ec2-user
# Apache directory permission settings
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
# Secure your MariaDB
sudo mysql_secure_installation

# In your home directory, download drupal and move it to Apache www directory
cd
wget https://ftp.drupal.org/files/projects/drupal-7.56.tar.gz
tar xvzf drupal-7.56.tar.gz
sudo mv drupal-7.56 /var/www/html/drupal
# Set the right group
sudo chown -R ec2-user:apache /var/www/html/drupal

# Lang files are here.
cd /var/www/html/drupal/profiles/standard/translations
wget http://ftp.drupal.org/files/translations/7.x/drupal/drupal-7.56.zh-hant.po
# Don't forget to change group
sudo chown ec2-user:apache drupal-7.56.zh-hant.po

# File system error
sudo chmod 775 -R /var/www/html/drupal/sites/defualt
# If no settings.php exist
cd /var/www/html/drupal/sites/defualt
sudo cp default.settings.php settings.php
sudo chown ec2-user:apache settings.php
sudo chmod 775 settings.php