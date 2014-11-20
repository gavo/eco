# Para configurar apache con host virtuales, necesitamos tener ya configurados el servidor dns
# si no lo hicimos, es mejor que nos pongamos al caso antes de seguir con este pasoss


# nos ubicamos en el directorio de apache que se encarga de gestionar las direcciones
cd /etc/apache2/sites-available
# modificamos el directorio principal
nano 000-default.conf 

###############################################################################
<VirtualHost *:80>
	ServerName informatica.net
	ServerAlias informatica
	DocumentRoot /var/www/informatica

	DirectoryIndex index.php

	<Directory />
		Options FollowSymLinks
		AllowOverride None
	</Directory>
	<Directory /var/www/informatica>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride None
		Order allow,deny
		allow from all
	</Directory>

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
###################################################################################

a2ensite 000-default.conf
sudo cp 000-default.conf subdominio1.conf
sudo cp 000-default.conf subdominio2.conf

##Lo mismo para el subdominio 1 y 2 aunque con directorios y nombres diferentes
nano subdominio1.conf
######################################################################
<VirtualHost *:80>
	ServerName subdominio1.informatica.net
	ServerAlias sbudominio1
	DocumentRoot /var/www/subdominio1

	DirectoryIndex index.php

	<Directory />
		Options FollowSymLinks
		AllowOverride None
	</Directory>
	<Directory /var/www/subdominio1>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride None
		Order allow,deny
		allow from all
	</Directory>

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
##########################################################################

a2ensite subdominio1.conf 
a2ensite subdominio2.conf 
## si necesitamos quitar permiso a subdominio seria dissite subdominio1.conf

# creamos directorios
mkdir /var/www/vallekano
$ mkdir /var/www/subdominio1
$ mkdir /var/www/subdominio2

# agregamos el index para cada pagina
nano /var/www/vallekano/index.php

# reiniciamos el servicio
service apache2 restart


# una vez terminado esto, necesitamos configurar nuestro servidor dns, para agregar el subdominio
nano /etc/bind/db.informatica.net
# previamente debimos haber configurado el servidor dns, asi que modificamos el archivo db.informatica

#################################################################################################
;
; BIND data file for local loopback interface
;
$TTL	604800
@		IN		SOA		informatica.net. root.informatica.net. (
							  2			;  Serial
						 604800			;  Refresh
						  86400			;  Retry
						2419200			;  Expire
						 604800 )		;  Negative Cache TTL
;
@		IN		NS		informatica.net.
@		IN		A		192.168.50.1
videoteca	IN	CNAME	informatica.net. # estos seran subdominios o dominios virtuales emulados por apache2
encuestas	IN	CNAME	informatica.net. # a los que se accedera con el nombre http://encuestas.informatica.net o http://videoteca.informatica.net
########################################################################################################