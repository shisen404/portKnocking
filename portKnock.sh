# Run the script with three agruments each a port number
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
# -F flushes all the chains. Chains can't be deleted unless they are empty
sudo iptables -F
# -X Delets all the non-builtin chains in the table
sudo iptables -X
# -Z Zero's the packet and byte counters in all chains
sudo iptables -Z

# Adding the additional chains that will be required
sudo iptables -N WALL
sudo iptables -N KNOCK1
sudo iptables -N KNOCK2
sudo iptables -N KNOCK3
sudo iptables -N PASSED

sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Rules to accept traffic for localhost, web server and python's SimpleHTTPServer
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
sudo iptables -A INPUT -j WALL

#First GATE
sudo iptables -A KNOCK1 -p tcp --dport $1 -m recent --name AUTH1 --set -j DROP
sudo iptables -A KNOCK1 -j DROP

#Second GATE
sudo iptables -A KNOCK2 -m recent --name AUTH1 --remove
sudo iptables -A KNOCK2 -p tcp --dport $2 -m recent --name AUTH2 --set -j DROP
sudo iptables -A KNOCK2 -j KNOCK1

#Third GATE
sudo iptables -A KNOCK3 -m recent --name AUTH2 --remove
sudo iptables -A KNOCK3 -p tcp --dport $3 -m recent --name AUTH3 --set -j DROP
sudo iptables -A KNOCK3 -j KNOCK1

sudo iptables -A PASSED -m recent --name AUTH3 --remove
sudo iptables -A PASSED -p tcp --dport 22 -j ACCEPT
sudo iptables -A PASSED -j KNOCK1

sudo iptables -A WALL -m recent --rcheck --seconds 60 --name AUTH3 -j PASSED
sudo iptables -A WALL -m recent --rcheck --seconds 20 --name AUTH2 -j KNOCK3
sudo iptables -A WALL -m recent --rcheck --seconds 20 --name AUTH1 -j KNOCK2
sudo iptables -A WALL -j KNOCK1
