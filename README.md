# Miscellaneous-bash-scripts
Linux bash scripts that does not fit other repository of mine

**bandwidth-limiter-linux** - maintain network interface bandwidth limits in various time frames and/or change/override limit manually

**banip** - Script to help guide user to block/unblock IPv4 address/range on Linux computer with iptables. "chmod 700 banip" to make it executable.

**brokenlinkchecker** - Script that monitors the defined URLs and report (output or mail) if it returns any non-standard HTTP code like Not found, Forbidden or such

**cloudflare-reverse-IP-hidden-mx** - Discover the IP address of the hosting server where the Cloudflare protected site is really hosted. Not always works.

**connections-list-per-ip-port.sh** - Handy for server admin to discover why the connections number is so high, which are top connection IPs, which top ports, and suggestion on how to block using csf firewall.

**convert2utf** - Linux bash script to help converting directory of files (matching user defined extension) into UTF-8, in case these are not UTF already

**discoverroughiops** - use "fio" tool to discover rough disk performance - read operations per second and bandwidth used during the reading

**ftpupload** - this bash script should help guide on how to use linux "ftp" client utility to upload & downlod file

**isipblocked** - search for IP in various log files to discover details about its activity and if is blocked in iptables or in Configserver firewall

**killpkgaccif24h** - This bash script will kill process which running more than X hours

**mediainfocomparefiles** - Bash script is using already installed "mediainfo" utility to compare files in a directory regarding defined video parameters to help find out differences that cause issues after merging files together

**monitornsipchange** - Monitor nameservers and if its IP change, report it via e-mail

**namesilobalance** - Bash script to discover current funds balance of the Namesilo.com account and report via email if the balance is below the defined treshold

**optimizeimages** - bash script to optimize images in certain directory reducing size for better performance and disk space savings

**pagemonitor_for_new_footprints** - bash script to monitor one web page and inform via e-mail if it contains new occurrence of the defined phrase/footprint

**search** - helper bash script for searching Linux computer for files by name, by content or search&replace in certain files content

**torrentcahedownloader** - Linux bash script that should download .torrent file that match the torrent hash that you input

**updatemuwire** - Linux bash script that helps download new or update existing [Muwire](https://github.com/zlatinb/muwire/) directory and build it so it can be run on Linux (if appropriate Java is installed)

**yahoolfdblock** - Bash script that checks the defined file if it contains any of the defined phrases and report via e-mail if yes
