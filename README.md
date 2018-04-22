# vRIN - virtual Route Injector
This is a VM appliance capable to inject high number of routes into a network.
Tested on GNS3 topologies using VirtualBox. Runs Quagga.

Supported protocols:
- BGP (IPv4/6)
- OSPF
- OSPFv3
- RIP v2
- RIPng

vRIN generates /32 IPv4 and /128 IPv6 static routes and redistributes them
into the selected routing protocol(s); hence the generated routes appear as
external (e.g. "O E2").

vRIN has been tested with 1M BGP routes (@John Dir, thanks!). Generating the
config files took ~22 minutes; the VM used ~700MB of memory.

Note: To align to the recommendation of RFCs 3177 and 5375, IPv6 netmasks are
fixed: /64 for eth0, /128 for loopback and generated routes.



## Usage
Connect eth0 to the network where you want vRIN to inject routes into then
start the VM. You can either run the VM in normal or headless mode; in the
latter case you can access vRIN through serial console. User input is not
checked; it's your responsibility to enter valid information.

After generating the routes, each Quagga process can be reached through eth0
using their default ports:
- zebra: 2601
- rip: 2602
- ripng: 2603
- ospf: 2604
- bgp: 2605
- ospf6d: 2606
VTY password: vrin

Notes:
 - Route generation may take a while when creating lots of routes (i.e. 10k+).
 - Login (serial / VM window): root / vrin



## Changelog

### Version 0.9.2
- FIXED: Netmask issue when changing IPv4 address (@LordHammer, thanks!).



### Version 0.9.1
- FIXED: Using IPv4 prefix for assigning IPv6 address to eth0 (@Andrew
  Coleman, thanks!).
- Package updates



### Version 0.9
- OSPFv3 support!
- Upgraded base system to Debian Stretch with Quagga 1.0.20160315-1.



### Version 0.8
- IPv6 support (RIPng, BGP). Tried OSPFv3 too but redistributed static routes
  are not advertised by Quagga properly; advertising router is "N/A" in the
  receiving routers OSPFv3 database, thus it's not being installed into the
  routing table.
- LIMITATION: IPv6 route generation works by entering no longer than /64
  network only!
- Added restoring configuration to the default state. 



### Version 0.7
- Remote management through serial console.
- FIXED: Error message appeared in certain cases when exiting to shell.
- FIXED: Minor typo errors.

 

### Version 0.6
- Autologin on tty1.
- Metric type (OSPF) and metric (OSPF & RIP) can be set for external routes
  (i.e. the generated routes).
- Removed out of band management; it confused people. Now vRIN has only one
  interface, which should be connected to routed environment (GNS3, lab, etc).
- FIXED: Exiting to Shell doesn't require entering an exit command after
  getting the prompt anymore.
- FIXED: Config files couldn't be saved when telnetting into Quagga daemons.
- FIXED: IP change on physical interface failed in certain conditions.



### Version 0.5.1
- Reduced OVA file size to 194 MB. @Julien Duponchelle, thanks for the tips!



### Version 0.5
- Reduced VM RAM to 256 MB. Tested with 100k routes to an OSPF neighbor.
- FIXED: Only the enabled protocols' settings appear in "Show settings".
- FIXED: Sometimes Quagga got stuck after several restarting.
- Added some comments.
- Added a gauge bar when creating the prefixes, only to remove it immediately.
  It made the script run 20x slower.



### Version 0.4
- First fully working version but still beta.
- RIP authentication key can be up to 16 characters. This is a limitation of
  RIP.
- BUG: Exiting to Shell requires entering an exit command after getting the
  prompt.



### Versions 0.1-0.3
- These were internal development versions, they're not available for download



## TODO
- IS-IS support
- Input sanity checks



## Author
Andras Dosztal (@adosztal)



## Disclaimer
vRIN is copyrighted (c) by Andras Dosztal 2015-2017.  Any injury or loss due to
the use of this software is not the responsibility of the author. This software
is provided "as is" without any express or implied warranties, including,
without limitation, the implied warranties of merchantability and fitness for
a particular purpose.

In short: act sane and don't blame me. :)
