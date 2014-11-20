#abrimos el directorio /etc/network/interfaces con permisos de usuario root
sudo su
nano /etc/network/interfaces

#y dejamos el archivo como sigue

#############################################
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
address 192.168.50.1
netmask 255.255.255.0

#############################################

#si necesitamos reiniciar las interfaces de red

ifup eth0 # inicia la interfaz eth0
ifdown eth0 # detiene la interfaz eth0
ifconfig # muestra la configuracion de todas las targetas de red
/etc/init.d/networking restart  # Reinicia todos los servicios de red
/sbin/ifconfig –a # Para conocer todas las interfaces de red ya sea activas o no