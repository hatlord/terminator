## RDP Password Attacker  
Terminator is an RDP password attack tool which uses Impacket's rdp_check.py example. It will take a list of hosts, usernames and passwords or a single one of each.  
Terminator will also take a single NTLM hash, or list of hashes for authentication (Pass the hash).

./terminator.rb --help should tell you all you need to know.  

> Computar-2:terminator rich$ ./terminator.rb --help  
    RDP Password Attacker  
  -h, --host=<s      Provide a single host at the command line - host:port  
  -H, --hosts=<s     Provide a list of hosts  
  -u, --user=<s      Provide a username  
  -U, --users=<s     Provide a list of usernames  
  -p, --pass=<s      Provide a password  
  -P, --passes=<s    Provide a list of passwords  
  -n, --hash=<s      Provide a hash instead of a password  
  -N, --hashes=<s    Provide a list of hashes instead of a password  
  -d, --domain=<s    Domain or workgroup (default: WORKGROUP)  
  -v, --version       Print version and exit  
  -e, --help          Show this  
