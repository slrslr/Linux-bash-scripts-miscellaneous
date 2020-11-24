echo "Port 80 connections:"
netstat -plan|grep :80|awk {'print $5'}|cut -d: -f 1|sort|uniq -c|sort -nk 1
echo "----------------------------
"
netstat -an | grep ESTABLISHED | awk '{print $5}' | awk -F: '{print $1}' | sort | uniq -c | awk '{ printf("%s\t%s\t",$2,$1) ; for (i = 0; i < $1; i++) {printf("*")}; print "" }'

echo "
Deny IP (add to csf.deny): csf -d .."

echo "Number of connections per port (consider disabling service on that port if under attack)"
netstat -tuna | awk -F':+| +' 'NR>2{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n
echo "------------ netstat was used ------------
do: netstat -p to show all processes , do | grep http to filter some app"
