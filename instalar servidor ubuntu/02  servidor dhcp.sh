#instalamos el servidor dhcp
apt-get install dhcp3-server
# abrimos el archivo de configuracion del dhcp
nano /etc/dhcp/dhcpd.conf		
#descomentamos la siguiente lineas
#y las modificamos segun nuestra conveniencia
	subnet 192.168.50.0 netmask 255.255.255.0 {  	# mascara de red de la subred
		range 192.168.50.10 192.168.50.250;   		# rango de direcciones que entregará el servidor
		option domain-name-servers 192.168.50.1; 	#
		option domain-name "192.168.50.1";   
		option routers 192.168.50.1;    
		option broadcast-address 192.168.50.255;    	# esta es la dirección de broadcast
		default-lease-time 600;
		max-lease-time 7200;
	}
# si queremos reservar una ip para un cliente especifico
	host reservado1 {
		hardware ethernet 00:0c:29:c9:46:80; # Direccion mac del cliente
		fixed-address 192.168.50.2; # Direccion ip que le asignaremos
		# Si queremos cargar otras opciones como servidor dns o puerta de enlace predeterminada
		# podemos ir asignando aqui abajo
	} 	
# una vez configurado, podemos reiniciar el servidor dhcp
/etc/init.d/isc-dhcp-server restart