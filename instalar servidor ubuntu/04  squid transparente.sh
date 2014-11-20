#INSTALACION DEL SERVIDOR SQUID
apt-get install squid3
#abrimos el arhivo de configuracion
nano /etc/squid3/squid.conf


#EL ARCHIVO DE CONFIGURACION PUEDE TENER ESTOS PARAMETROS
######################################################################################################
visible_hostname proxy_inf_informatica
http_port 3128 transparent
cache_mgr gustavovargasmiranda@maingrain.we

acl SSL_ports port 443
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http
acl CONNECT method CONNECT

acl https port 443
acl localnet src 192.168.50.0/24

http_access deny !Safe_ports
http_access allow https
http_access allow localnet
http_access deny all

cache_mem 512 MB
maximum_object_size_in_memory 2 MB
maximum_object_size 100 MB
cache_dir ufs /var/spool/squid3 20000 16 256

forwarded_for off
refresh_pattern ^ftp:						1440	20%		10080
refresh_pattern ^gopher:					1440	0%		1440
refresh_pattern -i (/cgi-bin/|\?)			1440	0%		0
refresh_pattern	(Release|Packeges(.gz)*)$	0		20%		2880
refresh_pattern  .							0		20%		4320

delay_pools 1
delay_class 1 3
delay_access 1 allow all
delay_parameters 1 -1/-1 -1/-1 16384/245760

####################################################################################################

## para probar el archivo de configuracion, podemos ejecutrar el comandos
/usr/sbin/squid3
# que nos alertara si hay errores en el archivo que comprometan su funcionalidad

#posteriormente nos creamos un archivo en un directorio para que contenga las reglas iptables
# para redireccionar todo hacia el puerto del proxy
sudo nano /etc/iptables-script
# el contenido del archivo sera el siguiente

####################################################################################################
# IP del servidor SQUID
SQUID_SERVER="172.16.0.12"
# Interfaz conectada a internet
INTERNET="eth0"
# Red Lan por donde se conectaran al proxy
LOCAL="192.168.1.0/27" #como declaramos en squid.conf es el rango de ips a escuchar
# Puerto que utiliza el servidor proxy
SQUID_PORT="3128"
# Limpiamos firewall anterior
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
# Se cargan modulos de IPTABLES para NAT e "IP conntrack support"
modprobe ip_conntrack
modprobe ip_conntrack_ftp
# For win xp ftp client
#modprobe ip_nat_ftp
# Habilitamos forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
# Configuramos una politica de filtrado por defecto
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
# Permitimos el acceso ilimitado al loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# Permitimos UDP, DNS y Passive FTP
iptables -A INPUT -i $INTERNET -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -s $LOCAL -m state --state ESTABLISHED,RELATED -j ACCEPT
# Esta es la mas importante ya que prepara este systema como router para la LAN
iptables -t nat -A POSTROUTING -o $INTERNET -j MASQUERADE
iptables -A FORWARD -s $LOCAL -j ACCEPT
# Permitimos que la LAN tenga acceso ilimitado
iptables -A INPUT -s $LOCAL -j ACCEPT
iptables -A OUTPUT -s $LOCAL -j ACCEPT
# Redireccionamos (DNAT) las peticiones del puerto 80 de la LAN al squid por el puerto 3128 ($SQUID_PORT) aka transparent proxy
iptables -t nat -A PREROUTING -s $LOCAL -p tcp --dport 80 -j DNAT --to $SQUID_SERVER:$SQUID_PORT
#OJOOOO!!!! el squid3 NO repito NO hace cache de HTTPS (443) en las notas dire por que
#iptables -t nat -A PREROUTING -s $LOCAL -p tcp --dport 443 -j DNAT --to $SQUID_SERVER:$SQUID_PORT
# si son del mismo proxy
iptables -t nat -A PREROUTING -i $INTERNET -p tcp --dport 80 -j REDIRECT --to-port $SQUID_PORT
#iptables -t nat -A PREROUTING -i $INTERNET -p tcp --dport 443 -j REDIRECT --to-port $SQUID_PORT
#abrimos los demas puertos desde internet a la lan
iptables -A INPUT -i $INTERNET -j ACCEPT
iptables -A OUTPUT -o $INTERNET  -j ACCEPT
# DROP lo demas y lo agregamos al LOG
iptables -A INPUT -j LOG
iptables -A INPUT -j DROP
#######################################################################################################################

#posteriormente damos los permisos de inicio
chmod +x /etc/iptables-script
# y hacemos que se pueda iniciar el archivo junto con el sitema operativo
#modificando el archivo 
sudo nano /etc/rc.local

###############################################################################
##arriba hay varios comentarios
#luego agregamos el codigo
/etc/iptables-script

exit 0
###############################################################################