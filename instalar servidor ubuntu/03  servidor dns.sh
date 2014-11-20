#instalamos bind9
apt-get install bind9 
#accedemos al primer archivo para configurarlo
nano /etc/bind/named.conf.local

# El archivo quedara mas o menos asi
####################################################################
	zone "informatica.net"{
		type master;
		file "/etc/bind/db.informatica.net";
	};
	#aqui estamos diciendo que trabajaremos sobe la red 192.168.50
	# si vamos a agregar otras subredes, debemos crearle su propia zona inversa
	# caso contrario, si esta en la misma red, simplemente 
	zone "50.168.192.in-addr.arpa"{
		type master;
		file "/etc/bind/db.192.168.50";
	};
####################################################################
	
#luego de eso hacemos una copia del archivo db.local
cp db.local db.informatica.net #a un archivo nuevo con el nombre definido arriba
cp db.local db.192.168.50#a un archivo nuevo con el nombre definido arriba para la red inversa

nano /etc/bind/db.informatica.net
#modificamos primero el archivo db.informatica
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
#luego modificamos el archivo db.192.168.50
;
; BIND data file for local loopback interface
;
$TTL	604800
@		IN		SOA		informatica.net. root.informatica.net. (
							  1			;  Serial
						 604800			;  Refresh
						  86400			;  Retry
						2419200			;  Expire
						 604800 )		;  Negative Cache TTL
;
@		IN		NS		informatica.net.
1		IN		PTR		informatica.net.
#ese es el contenido
#luego se modifica el servidor dns del sistema para que utilice el que configuramos 
sudo nano /etc/resolv.conf
#remplazamos el dns primario por el nuestro
nameserver 192.168.50.1
#reiniciamos el servidor dns
/etc/init.d/bind9 restart

# para diagnosticar el dns que creamos podemos usar el comando
dig informatica.net