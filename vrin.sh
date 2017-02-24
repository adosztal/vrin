#!/bin/sh

# Setting "physical" (i.e. non-loopback) interface eth0.
phy() {
    # Reading NIC related settings into variables which are used to
    # fill in the fields with the previously entered data.
    ETH0_IPv4=`grep eth0_ipv4 $CONF_FILE | cut -d " " -f 2`
    ETH0_MASKv4=`grep eth0_maskv4 $CONF_FILE | cut -d " " -f 2`
    ETH0_NETv4=`grep eth0_netv4 $CONF_FILE | cut -d " " -f 2`
    ETH0_IPv6=`grep eth0_ipv6 $CONF_FILE | cut -d " " -f 2`
    ETH0_NETv6=`grep eth0_netv6 $CONF_FILE | cut -d " " -f 2`


    # IPv4 address
    dialog --backtitle "vRIN ${VER}" --title "Configure physical interface 1/5" --ok-label "Next" --inputbox "IP address:" 19 50 $ETH0_IPv4 2> /tmp/vrin_eth0_ipv4

    RETVAL=$? # Checking if Cancel or the ESC button has been pressed (values 1 & 255) 
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_eth0_ipv4` # Reading dialog's output
    sed -i "s/^eth0_ipv4.*$/eth0_ipv4 ${OUT}/g" $CONF_FILE # Replacing the variable in the config file

    # IPv4 Netmask
    dialog --backtitle "vRIN ${VER}" --title "Configure physical interface 2/5" --ok-label "Next" --inputbox "Netmask (/xx format):" 19 50 $ETH0_MASKv4 2> /tmp/vrin_eth0_maskv4

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_eth0_maskv4`
    sed -i "s/^eth0_maskv4.*$/eth0_maskv4 ${OUT}/g" $CONF_FILE

    # IPv4 Network
    dialog --backtitle "vRIN ${VER}" --title "Configure physical interface 3/5" --inputbox "Network:" 19 50 $ETH0_NETv4 2> /tmp/vrin_eth0_netv4

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_eth0_netv4`
    sed -i "s/^eth0_netv4.*$/eth0_netv4 ${OUT}/g" $CONF_FILE


    # IPv6 address
    dialog --backtitle "vRIN ${VER}" --title "Configure physical interface 4/5" --ok-label "Next" --inputbox "IP address:" 19 50 $ETH0_IPv6 2> /tmp/vrin_eth0_ipv6

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_eth0_ipv6`
    sed -i "s/^eth0_ipv6.*$/eth0_ipv6 ${OUT}/g" $CONF_FILE

    # IPv6 Network
    dialog --backtitle "vRIN ${VER}" --title "Configure physical interface 5/5" --inputbox "Network:" 19 50 $ETH0_NETv6 2> /tmp/vrin_eth0_netv6

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_eth0_netv6`
    sed -i "s/^eth0_netv6.*$/eth0_netv6 ${OUT}/g" $CONF_FILE

    main
}


# Setting loopback interface IP; IPv4 address is used for router-id (OSPF, BGP) too
lo() {
    LO_IPv4=`grep lo_ipv4 $CONF_FILE | cut -d " " -f 2`
    LO_IPv6=`grep lo_ipv6 $CONF_FILE | cut -d " " -f 2`

    # IPv4 address
    dialog --backtitle "vRIN ${VER}" --title "Configure loopback interface 1/2" --inputbox "Enter IPv4 address:" 19 50 $LO_IPv4 2> /tmp/vrin_lo_ipv4
    
    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_lo_ipv4`
    sed -i "s/^lo_ipv4.*$/lo_ipv4 ${OUT}/g" $CONF_FILE

    # IPv6 address
    dialog --backtitle "vRIN ${VER}" --title "Configure loopback interface 2/2" --inputbox "Enter IPv6 address:" 19 50 $LO_IPv6 2> /tmp/vrin_lo_ipv6
    
    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_lo_ipv6`
    sed -i "s/^lo_ipv6.*$/lo_ipv6 ${OUT}/g" $CONF_FILE

    main
}


# Protocol selection
proto() {
    dialog --backtitle "vRIN ${VER}" --title "Routing protocols" --checklist "Select enabled routing protocol(s):" 19 50 5 \
        "BGP" "" `egrep "^BGP " $CONF_FILE | cut -d " " -f 2` \
        "OSPFv2" "" `grep "^OSPFv2 " $CONF_FILE | cut -d " " -f 2` \
        "OSPFv3" "" `grep "^OSPFv3 " $CONF_FILE | cut -d " " -f 2` \
        "RIP (IPv4)" "" `grep "^RIP " $CONF_FILE | cut -d " " -f 2` \
        "RIPNG (IPv6)" "" `grep "^RIPNG " $CONF_FILE | cut -d " " -f 2` 2> /tmp/vrin_proto_routing # Output is like "BGP OSPFv2" or "OSPFv3 RIP (IPv4)", etc.
        
    RETVAL=$?

    case $RETVAL in
        0)
            #BGP
            PROTO=`grep BGP /tmp/vrin_proto_routing`
            if [ ${#PROTO} = "0" ]; then
                sed -i 's/^BGP.*$/BGP off/g' $CONF_FILE
            else
                sed -i 's/^BGP.*$/BGP on/g' $CONF_FILE
            fi
            
            # OSPFv2
            PROTO=`grep OSPFv2 /tmp/vrin_proto_routing`
            if [ ${#PROTO} = "0" ]; then
                sed -i 's/^OSPFv2.*$/OSPFv2 off/g' $CONF_FILE
            else
                sed -i 's/^OSPFv2.*$/OSPFv2 on/g' $CONF_FILE
            fi
            
            # OSPFv3
            PROTO=`grep OSPFv3 /tmp/vrin_proto_routing`
            if [ ${#PROTO} = "0" ]; then
                sed -i 's/^OSPFv3.*$/OSPFv3 off/g' $CONF_FILE
            else
                sed -i 's/^OSPFv3.*$/OSPFv3 on/g' $CONF_FILE
            fi
            
            # RIP
            PROTO=`grep "RIP ..IPv4" /tmp/vrin_proto_routing`
            if [ ${#PROTO} = "0" ]; then
                sed -i 's/^RIP .*$/RIP off/g' $CONF_FILE
            else
                sed -i 's/^RIP .*$/RIP on/g' $CONF_FILE
            fi
                       
            # RIPNG
            PROTO=`grep "RIPNG ..IPv6" /tmp/vrin_proto_routing`
            if [ ${#PROTO} = "0" ]; then
                sed -i 's/^RIPNG .*$/RIPNG off/g' $CONF_FILE
            else
                sed -i 's/^RIPNG .*$/RIPNG on/g' $CONF_FILE
            fi

            main;;

        1|255)
            main;;
    esac
}


# OSPF configuration
ospf() {
    OSPF_AREA_NUMBER=`grep ospf_area_number $CONF_FILE | cut -d " " -f 2`
    OSPF_METRIC_TYPE=`grep ospf_metric_type $CONF_FILE | cut -d " " -f 2`
    OSPF_METRIC_NUMBER=`grep ospf_metric_number $CONF_FILE | cut -d " " -f 2`

    # Area number
    dialog --backtitle "vRIN ${VER}" --title "OSPF 1/3" --inputbox "OSPF area in dotted decimal (x.x.x.x) format:" 19 50 $OSPF_AREA_NUMBER 2> /tmp/vrin_ospf_area_number
    
    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_ospf_area_number`
    sed -i "s/^ospf_area_number.*$/ospf_area_number ${OUT}/g" $CONF_FILE
    
    
    # Metric type
    if [ "$OSPF_METRIC_TYPE" = "E1" ]; then
        dialog --backtitle "vRIN ${VER}" --title "OSPF 2/3" --ok-label "Next" --radiolist "Metric type:" 19 50 3 \
            "1" "E1" ON \
            "2" "E2" off 2>/tmp/vrin_metric_type
    else
        dialog --backtitle "vRIN ${VER}" --title "OSPF 2/3" --ok-label "Next" --radiolist "Metric type:" 19 50 3 \
            "1" "E1" off \
            "2" "E2" ON 2>/tmp/vrin_metric_type
    fi
    
    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_metric_type`
    sed -i "s/^ospf_metric_type.*$/ospf_metric_type ${OUT}/g" $CONF_FILE

    
    # Metric
    dialog --backtitle "vRIN ${VER}" --title "OSPF 3/3" --inputbox "OSPF redist metric (0-16777214 or blank):" 19 50 $OSPF_METRIC_NUMBER 2> /tmp/vrin_ospf_metric_number
    
    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_ospf_metric_number`
    sed -i "s/^ospf_metric_number.*$/ospf_metric_number ${OUT}/g" $CONF_FILE

    main
}


# BGP settings
bgp() {
    BGP_LOCAL_AS=`grep bgp_local_as $CONF_FILE | cut -d " " -f 2`
    BGP_REMOTE_AS=`grep bgp_remote_as $CONF_FILE | cut -d " " -f 2`
    BGP_NEIGHBOR_IPv4=`grep bgp_neighbor_ipv4 $CONF_FILE | cut -d " " -f 2`
    BGP_NEIGHBOR_IPv6=`grep bgp_neighbor_ipv6 $CONF_FILE | cut -d " " -f 2`

    # Local AS
    dialog --backtitle "vRIN ${VER}" --title "BGP settings 1/4" --ok-label "Next" --inputbox "Local AS:" 19 50 $BGP_LOCAL_AS 2> /tmp/vrin_bgp_local_as

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_bgp_local_as`
    sed -i "s/^bgp_local_as.*$/bgp_local_as ${OUT}/g" $CONF_FILE

    # Remote AS
    dialog --backtitle "vRIN ${VER}" --title "BGP settings 2/4" --ok-label "Next" --inputbox "Remote AS:" 19 50 $BGP_REMOTE_AS 2> /tmp/vrin_bgp_remote_as

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_bgp_remote_as`
    sed -i "s/^bgp_remote_as.*$/bgp_remote_as ${OUT}/g" $CONF_FILE

    # Neighbor IPv4
    dialog --backtitle "vRIN ${VER}" --title "BGP settings 3/4" --inputbox "Neighbor IPv4 address:" 19 50 $BGP_NEIGHBOR_IPv4 2> /tmp/vrin_bgp_neighbor_ipv4

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_bgp_neighbor_ipv4`
    sed -i "s/^bgp_neighbor_ipv4.*$/bgp_neighbor_ipv4 ${OUT}/g" $CONF_FILE

    # Neighbor IPv6
    dialog --backtitle "vRIN ${VER}" --title "BGP settings 4/4" --inputbox "Neighbor IPv6 address:" 19 50 $BGP_NEIGHBOR_IPv6 2> /tmp/vrin_bgp_neighbor_ipv6

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_bgp_neighbor_ipv6`
    sed -i "s/^bgp_neighbor_ipv6.*$/bgp_neighbor_ipv6 ${OUT}/g" $CONF_FILE

    main
}


# RIP metric
rip() {
    RIP_METRIC_NUMBER=`grep rip_metric_number $CONF_FILE | cut -d " " -f 2`
    dialog --backtitle "vRIN ${VER}" --title "RIP(ng)" --inputbox "RIP(ng) redist metric (0-16 or blank):" 19 50 $RIP_METRIC_NUMBER 2> /tmp/vrin_rip_metric_number

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_rip_metric_number`
    sed -i "s/^rip_metric_number.*$/rip_metric_number ${OUT}/g" $CONF_FILE

    main
    
}


# Authentication for OSPF and RIP
auth() {
    AUTH_TYPE=`grep auth_type $CONF_FILE | cut -d " " -f 2`
    AUTH_KEY=`grep auth_key $CONF_FILE | cut -d " " -f 2`

    # Crafting radiolist from 3 possibilities
    if [ "$AUTH_TYPE" = "None" ]; then
        dialog --backtitle "vRIN ${VER}" --title "Authentication (OSPF/RIP) 1/2" --ok-label "Next" --radiolist "Authentication type:" 19 50 3 \
            "None" "" ON \
            "Cleartext" "" off \
            "MD5" "" off 2> /tmp/vrin_auth_type
    fi

    if [ "$AUTH_TYPE" = "Cleartext" ]; then
        dialog --backtitle "vRIN ${VER}" --title "Authentication (OSPF/RIP) 1/2" --ok-label "Next" --radiolist "Authentication type:" 19 50 3 \
            "None" "" off \
            "Cleartext" "" ON \
            "MD5" "" off 2> /tmp/vrin_auth_type
    fi

    if [ "$AUTH_TYPE" = "MD5" ]; then
        dialog --backtitle "vRIN ${VER}" --title "Authentication (OSPF/RIP) 1/2" --ok-label "Next" --radiolist "Authentication type:" 19 50 3 \
            "None" "" off \
            "Cleartext" "" off \
            "MD5" "" ON 2> /tmp/vrin_auth_type
    fi

    RETVAL=$?
            
    case $RETVAL in
        0)
            OUT=`cat /tmp/vrin_auth_type`
            sed -i "s/^auth_type.*$/auth_type ${OUT}/g" $CONF_FILE;;
        1|255)
            main;;
    esac

    # Re-reading authentication type. If None was selected, the key does not have to be set
    AUTH_TYPE=`grep auth_type $CONF_FILE | cut -d " " -f 2`
    echo $AUTH_TYPE > /tmp/vrin_xxx
    if [ $AUTH_TYPE = "None" ]; then
        main
    else
        dialog --backtitle "vRIN ${VER}" --title "Authentication (OSPF/RIP) 2/2" --inputbox "Authentication key:" 19 50 $AUTH_KEY 2> /tmp/vrin_auth_key
        
        RETVAL=$?
        case $RETVAL in
            1|255)
                main;;
        esac
        OUT=`cat /tmp/vrin_auth_key`
        sed -i "s/^auth_key.*$/auth_key ${OUT}/g" $CONF_FILE
    fi

    main

}


# Defining the first generated IP and the number of prefixes.
prefix() {
    ROUTE_IPv4=`grep route_ipv4 $CONF_FILE | cut -d " " -f 2`
    ROUTE_IPv6=`grep route_ipv6 $CONF_FILE | cut -d " " -f 2`
    ROUTE_NUMBER=`grep route_number $CONF_FILE | cut -d " " -f 2`


    # IPv4
    dialog --backtitle "vRIN ${VER}" --title "Prefixes 1/3" --ok-label "Next" --inputbox "First IPv4 address:" 19 50 $ROUTE_IPv4 2> /tmp/vrin_route_ipv4

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_route_ipv4`
    sed -i "s/^route_ipv4.*$/route_ipv4 ${OUT}/g" $CONF_FILE


    # IPv6
    dialog --backtitle "vRIN ${VER}" --title "Prefixes 2/3" --ok-label "Next" --inputbox "IPv6 subnet, must be no longer than /64, without netmask:" 19 50 $ROUTE_IPv6 2> /tmp/vrin_route_ipv6

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac

    # Checking if the entered value is x:x:x:x::
    # If so, the double colon is replaced with single.    
    COLON_CHECK=`grep -o ":" /tmp/vrin_route_ipv6 | wc -l`
    echo $COLON_CHECK > /tmp/vrin_col
    if [ $COLON_CHECK -eq 5 ]; then
        OUT=`sed 's/::/:/g' /tmp/vrin_route_ipv6`
    else
        OUT=`cat /tmp/vrin_route_ipv6`
    fi
    sed -i "s/^route_ipv6.*$/route_ipv6 ${OUT}/g" $CONF_FILE


    # Number of prefixes
    dialog --backtitle "vRIN ${VER}" --title "Prefixes 3/3" --inputbox "Number of prefixes:" 19 50 $ROUTE_NUMBER 2> /tmp/vrin_route_number

    RETVAL=$?
    case $RETVAL in
        1|255)
            main;;
    esac
    OUT=`cat /tmp/vrin_route_number`
    sed -i "s/^route_number.*$/route_number ${OUT}/g" $CONF_FILE

    main
}


# Displaying all settings
show() {
    # Reading all settings into variables
    ETH0_IPv4=`grep eth0_ipv4 $CONF_FILE | cut -d " " -f 2`
    ETH0_MASKv4=`grep eth0_maskv4 $CONF_FILE | cut -d " " -f 2`
    ETH0_NETv4=`grep eth0_netv4 $CONF_FILE | cut -d " " -f 2`
    ETH0_IPv6=`grep eth0_ipv6 $CONF_FILE | cut -d " " -f 2`
    ETH0_NETv6=`grep eth0_netv6 $CONF_FILE | cut -d " " -f 2`
    BGP=`grep BGP $CONF_FILE | cut -d " " -f 2`
    OSPFv2=`grep OSPFv2 $CONF_FILE | cut -d " " -f 2`
    OSPFv3=`grep OSPFv3 $CONF_FILE | cut -d " " -f 2`
    RIP=`grep "^RIP " $CONF_FILE | cut -d " " -f 2`
    RIPNG=`grep RIPNG $CONF_FILE | cut -d " " -f 2`
    LO_IPv4=`grep lo_ipv4 $CONF_FILE | cut -d " " -f 2`
    LO_IPv6=`grep lo_ipv6 $CONF_FILE | cut -d " " -f 2`
    OSPF_AREA_NUMBER=`grep ospf_area_number $CONF_FILE | cut -d " " -f 2`
    OSPF_METRIC_TYPE=`grep ospf_metric_type $CONF_FILE | cut -d " " -f 2`
    OSPF_METRIC_NUMBER=`grep ospf_metric_number $CONF_FILE | cut -d " " -f 2`
    RIP_METRIC_NUMBER=`grep rip_metric_number $CONF_FILE | cut -d " " -f 2`
    BGP_LOCAL_AS=`grep bgp_local_as $CONF_FILE | cut -d " " -f 2`
    BGP_REMOTE_AS=`grep bgp_remote_as $CONF_FILE | cut -d " " -f 2`
    BGP_NEIGHBOR_IPv4=`grep bgp_neighbor_ipv4 $CONF_FILE | cut -d " " -f 2`
    BGP_NEIGHBOR_IPv6=`grep bgp_neighbor_ipv6 $CONF_FILE | cut -d " " -f 2`
    AUTH_TYPE=`grep auth_type $CONF_FILE | cut -d " " -f 2`
    AUTH_KEY=`grep auth_key $CONF_FILE | cut -d " " -f 2`
    ROUTE_IPv4=`grep route_ipv4 $CONF_FILE | cut -d " " -f 2`
    ROUTE_IPv6=`grep route_ipv6 $CONF_FILE | cut -d " " -f 2`
    ROUTE_NUMBER=`grep route_number $CONF_FILE | cut -d " " -f 2`

    # Crafting output message
    MSGOUT="Physical interface IPs: $ETH0_IPv4 | $ETH0_IPv6\n
Physical interface masks: $ETH0_MASKv4 | 64\n
Physical interface networks: $ETH0_NETv4 | $ETH0_NETv6\n
Loopback interface IPs: $LO_IPv4 | $LO_IPv6"

    # Show BGP status, but details only if BGP = on
    MSGOUT="$MSGOUT\n
BGP: $BGP"
    if [ $BGP = "on" ]; then
        MSGOUT="$MSGOUT\n
BGP local AS: $BGP_LOCAL_AS\n
BGP remote AS: $BGP_REMOTE_AS\n
BGP neighbor IPs: $BGP_NEIGHBOR_IPv4 | $BGP_NEIGHBOR_IPv6"
    fi

    # Show OSPF status, but details only if OSPF = on
    MSGOUT="$MSGOUT\n
OSPFv2: $OSPFv2\n
OSPFv3: $OSPFv3"
    if [ $OSPFv2 = "on" ] || [ $OSPFv3 = "on" ]; then
        MSGOUT="$MSGOUT\n
OSPF area number: $OSPF_AREA_NUMBER\n
OSPF metric type: E$OSPF_METRIC_TYPE\n
OSPF redist metric: $OSPF_METRIC_NUMBER"
    fi

    # Show RIP status, but metric only if RIP = on
    MSGOUT="$MSGOUT\n
RIP: $RIP\n
RIPng: $RIPNG"
    if [ $RIP = "on" ] || [ $RIPNG = "on" ]; then
        MSGOUT="$MSGOUT\n
RIP(ng) redist metric: $RIP_METRIC_NUMBER"
    fi
    
    # Show auth type, but key on if type is not None
    MSGOUT="$MSGOUT\n
Auth type: $AUTH_TYPE"
    if [ $AUTH_TYPE != "None" ]; then
        MSGOUT="$MSGOUT\n
Auth key: $AUTH_KEY"
    fi

    MSGOUT="$MSGOUT\n
First generated prefixes: $ROUTE_IPv4 | $ROUTE_IPv6\n
Number of prefixes: $ROUTE_NUMBER"

    dialog --backtitle "vRIN ${VER}" --title "All settings" --msgbox "${MSGOUT}" 19 70

    main
}


# OC functions are used to increment octets during route generation.
# Each function increments one ocetet by 1 and sets it to 0 after 255.
oc1() {
    if [ $IP1 = 255 ]; then
        IP1=0
    else
        IP1=`expr $IP1 + 1`
    fi
}


oc2() {
    if [ $IP2 = 255 ]; then
        oc1
        IP2=0
    else
        IP2=`expr $IP2 + 1`
    fi
}


oc3() {
    if [ $IP3 = 255 ]; then
        oc2
        IP3=0
    else
        IP3=`expr $IP3 + 1`
    fi
}


oc4() {
    if [ $IP4 = 255 ]; then
        oc3
        IP4=0
    else
        IP4=`expr $IP4 + 1`
    fi
}


# Generating Quagga config files by replacing variables in the config
# templates and moving the output to /etc/quagga/
generate() {
    dialog --backtitle "vRIN ${VER}" --title "Confirmation" --yesno "\n    Are you sure?" 7 25
    RETVAL=$?

    case $RETVAL in
        0)
            ETH0_IPv4=`grep eth0_ipv4 $CONF_FILE | cut -d " " -f 2`
            ETH0_MASKv4=`grep eth0_maskv4 $CONF_FILE | cut -d " " -f 2`
            ETH0_MASKv4_DOT=`grep "^$ETH0_MASKv4 " /root/netmask.txt | cut -d " " -f 2`
            ETH0_NETv4=`grep eth0_netv4 $CONF_FILE | cut -d " " -f 2`
            ETH0_IPv6=`grep eth0_ipv6 $CONF_FILE | cut -d " " -f 2`
            ETH0_NETv6=`grep eth0_netv6 $CONF_FILE | cut -d " " -f 2`
            BGP=`grep BGP $CONF_FILE | cut -d " " -f 2`
            OSPFv2=`grep OSPFv2 $CONF_FILE | cut -d " " -f 2`
            OSPFv3=`grep OSPFv3 $CONF_FILE | cut -d " " -f 2`
            RIP=`grep "^RIP " $CONF_FILE | cut -d " " -f 2`
            RIPNG=`grep RIPNG $CONF_FILE | cut -d " " -f 2`
            LO_IPv4=`grep lo_ipv4 $CONF_FILE | cut -d " " -f 2`
            LO_IPv6=`grep lo_ipv6 $CONF_FILE | cut -d " " -f 2`
            OSPF_AREA_NUMBER=`grep ospf_area_number $CONF_FILE | cut -d " " -f 2`
            OSPF_METRIC_TYPE=`grep ospf_metric_type $CONF_FILE | cut -d " " -f 2`
            OSPF_METRIC_NUMBER=`grep ospf_metric_number $CONF_FILE | cut -d " " -f 2`
            RIP_METRIC_NUMBER=`grep rip_metric_number $CONF_FILE | cut -d " " -f 2`
            BGP_LOCAL_AS=`grep bgp_local_as $CONF_FILE | cut -d " " -f 2`
            BGP_REMOTE_AS=`grep bgp_remote_as $CONF_FILE | cut -d " " -f 2`
            BGP_NEIGHBOR_IPv4=`grep bgp_neighbor_ipv4 $CONF_FILE | cut -d " " -f 2`
            BGP_NEIGHBOR_IPv6=`grep bgp_neighbor_ipv6 $CONF_FILE | cut -d " " -f 2`
            AUTH_TYPE=`grep auth_type $CONF_FILE | cut -d " " -f 2`
            AUTH_KEY=`grep auth_key $CONF_FILE | cut -d " " -f 2`
            ROUTE_IPv4=`grep route_ipv4 $CONF_FILE | cut -d " " -f 2`
            ROUTE_IPv6=`grep route_ipv6 $CONF_FILE | cut -d " " -f 2`
            ROUTE_NUMBER=`grep route_number $CONF_FILE | cut -d " " -f 2`


            # Generating bgpd.conf
            sed "s/%bgp_local_as%/$BGP_LOCAL_AS/g;s/%lo_ipv4%/$LO_IPv4/g;s/%lo_ipv6%/$LO_IPv6/g;s/%bgp_neighbor_ipv4%/$BGP_NEIGHBOR_IPv4/g;s/%bgp_neighbor_ipv6%/$BGP_NEIGHBOR_IPv6/g;s/%bgp_remote_as%/$BGP_REMOTE_AS/g" $QDIR/templates/bgpd.conf.template > $QDIR/bgpd.conf


            # Generating ospfd.conf
            sed "s/%lo_ipv4%/$LO_IPv4/g;s/%ospf_area_number%/$OSPF_AREA_NUMBER/g;s/%eth0_netv4%\/%eth0_maskv4%/$ETH0_NETv4\/$ETH0_MASKv4/g" $QDIR/templates/ospfd.conf.template > $QDIR/ospfd.conf
            
            # ospfd auth
            if [ $AUTH_TYPE = "None" ]; then
                sed -i "s/%auth%//g" $QDIR/ospfd.conf
            fi
            if [ $AUTH_TYPE = "Cleartext" ]; then
                sed -i "s/%auth%/interface eth0\n  ip ospf authentication\n  ip ospf authentication-key $AUTH_KEY/g" $QDIR/ospfd.conf
            fi
            if [ $AUTH_TYPE = "MD5" ]; then
                sed -i "s/%auth%/interface eth0\n  ip ospf authentication\n  ip ospf authentication message-digest\n  ip ospf message-digest-key 1 md5 $AUTH_KEY/g" $QDIR/ospfd.conf
            fi

            #ospfd metric
            if [ ${#OSPF_METRIC_NUMBER} = "0" ]; then
                sed -i "s/%metric%/$OSPF_METRIC_TYPE/g" $QDIR/ospfd.conf
            else
                sed -i "s/%metric%/$OSPF_METRIC_TYPE metric $OSPF_METRIC_NUMBER/g" $QDIR/ospfd.conf
            fi


            # Generating ospf6d.conf
            sed "s/%lo_ipv4%/$LO_IPv4/g;s/%ospf_area_number%/$OSPF_AREA_NUMBER/g" $QDIR/templates/ospf6d.conf.template > $QDIR/ospf6d.conf

            # Generating ripd.conf & ripngd.conf
            if [ $AUTH_TYPE = "None" ]; then
                sed "s/%auth%//g" $QDIR/templates/ripd.conf.template > $QDIR/ripd.conf
                sed "s/%auth%//g" $QDIR/templates/ripngd.conf.template > $QDIR/ripngd.conf
            fi
            if [ $AUTH_TYPE = "Cleartext" ]; then
                sed "s/%auth%/interface eth0\n  ip rip authentication mode text\n  ip rip authentication string $AUTH_KEY/g" $QDIR/templates/ripd.conf.template > $QDIR/ripd.conf
                sed "s/%auth%/interface eth0\n  ip rip authentication mode text\n  ip rip authentication string $AUTH_KEY/g" $QDIR/templates/ripngd.conf.template > $QDIR/ripngd.conf
            fi
            if [ $AUTH_TYPE = "MD5" ]; then
                sed "s/%auth%/key chain vrin\n  key 1\n    key-string $AUTH_KEY\n\ninterface eth0\n  ip rip authentication mode md5\n  ip rip authentication key-chain vrin/g" $QDIR/templates/ripd.conf.template > $QDIR/ripd.conf
                sed "s/%auth%/key chain vrin\n  key 1\n    key-string $AUTH_KEY\n\ninterface eth0\n  ip rip authentication mode md5\n  ip rip authentication key-chain vrin/g" $QDIR/templates/ripngd.conf.template > $QDIR/ripngd.conf
            fi

            #ripd metric
            if [ ${#RIP_METRIC_NUMBER} = "0" ]; then
                sed -i "s/%metric%//g" $QDIR/ripd.conf $QDIR/ripngd.conf
            else
                sed -i "s/%metric%/metric $RIP_METRIC_NUMBER/g" $QDIR/ripd.conf $QDIR/ripngd.conf
            fi
 
            
            # Generating zebra.conf
            sed "s/%lo_ipv4%/$LO_IPv4/g;s/%lo_ipv6%/$LO_IPv6/g;s/%eth0_ipv4%/$ETH0_IPv4\/$ETH0_MASKv4/g;s/%eth0_ipv6%/$ETH0_IPv6/g" $QDIR/templates/zebra.conf.template > $QDIR/zebra.conf
            echo >> $QDIR/zebra.conf

            IP1=`grep route_ipv4 $CONF_FILE | cut -d "." -f 1 | cut -d " " -f 2`
            IP2=`grep route_ipv4 $CONF_FILE | cut -d "." -f 2`
            IP3=`grep route_ipv4 $CONF_FILE | cut -d "." -f 3`
            IP4=`grep route_ipv4 $CONF_FILE | cut -d "." -f 4`
            ROUTE_NUMBER=`grep route_number $CONF_FILE | cut -d " " -f 2`
            i=0

            while [ "$i" -lt "$ROUTE_NUMBER" ]; do
                echo "ip route $IP1.$IP2.$IP3.$IP4/32 Null0" >> $QDIR/zebra.conf
                oc4
                i=`expr $i + 1`
            done
            i=0

            while [ "$i" -lt "$ROUTE_NUMBER" ]; do
                echo "ipv6 route ${ROUTE_IPv6}$IP1:$IP2:$IP3:$IP4/128 ::1 blackhole" >> $QDIR/zebra.conf
                oc4
                i=`expr $i + 1`
            done


            echo >> $QDIR/zebra.conf
            echo "log file /var/log/quagga/zebra.log" >> $QDIR/zebra.conf
            echo >> $QDIR/zebra.conf


            # Generating debian.conf
            sed "s/%eth0_ipv4%/$ETH0_IPv4/g" $QDIR/templates/debian.conf.template > $QDIR/debian.conf
            sed -i "s/%eth0_ipv6%/$ETH0_IPv6/g" $QDIR/debian.conf
            
            # Generation daemons
            echo "zebra=yes" > $QDIR/daemons
            if [ $BGP = "on" ]; then
                echo "bgpd=yes" >> $QDIR/daemons
            else
                echo "bgpd=no" >> $QDIR/daemons
            fi
            if [ $OSPFv2 = "on" ]; then
                echo "ospfd=yes" >> $QDIR/daemons
            else
                echo "ospfd=no" >> $QDIR/daemons
            fi
            if [ $OSPFv3 = "on" ]; then
                echo "ospf6d=yes" >> $QDIR/daemons
            else
                echo "ospf6d=no" >> $QDIR/daemons
            fi
            if [ $RIP = "on" ]; then
                echo "ripd=yes" >> $QDIR/daemons
            else
                echo "ripd=no" >> $QDIR/daemons
            fi
            if [ $RIPNG = "on" ]; then
                echo "ripngd=yes" >> $QDIR/daemons
            else
                echo "ripngd=no" >> $QDIR/daemons
            fi

            echo "isisd=no
babeld=no" >> $QDIR/daemons 


            # Changing conf files' ownership to quagga. If this is not done, config
            # changes can't be saved in a telnet session
            chown quagga:quaggavty /etc/quagga/*


            # Using ifconfig to overwrite IP address
            /sbin/ifconfig eth0 $ETH0_IPv4 netmask $ETH0_MASKv4_DOT
            /sbin/ifconfig eth0 inet6 add $ETH0_IPv6/64


            # (Re)starting quagga
            if pgrep "quagga" > /dev/null
            then
                /etc/init.d/quagga stop >/dev/null 2>/dev/null
                for i in `pgrep -u quagga`; do kill $i >/dev/null 2>/dev/null; done # Sometimes quagga gets stuck; this kills all remaining processes
            fi
            /etc/init.d/quagga start


            dialog --backtitle "vRIN ${VER}" --title "Done" --msgbox "\nCompleted. Routes are being advertised." 8 50
            
            main;;

        1|255)
            main;;
    esac
}


# Restoring default configuration
restore() {
    dialog --backtitle "vRIN ${VER}" --title "Confirmation" --yesno "Are you sure you want to restore your configuration?" 7 50
    RETVAL=$?

    case $RETVAL in
        0)
            cp /root/vrin_default.conf /root/vrin.conf
            dialog --backtitle "vRIN ${VER}" --title "Done" --msgbox "Completed. Click on 'Generate routes' to apply the new settings." 8 70
            main;;
            
        1|255)
            main;;
    esac
}


# Main menu; all functions, except the OCx ones, return to here.
main() {
    dialog --backtitle "vRIN ${VER}" --title "Main menu" --cancel-label "Exit to shell" --menu "Choose an option" 19 50 12 \
        a "Configure physical interface" \
        b "Configure loopback interface" \
        c "Routing protocols" \
        d "OSPF settings" \
        e "BGP settings" \
        f "RIP(ng) settings" \
        g "Authentication settings" \
        h "Prefixes" \
        i "Show all settings" \
        j "Generate routes" \
        k "Restore default configuration" \
        l "Shutdown VM" 2> /tmp/vrin_menu

    RETVAL=$?
    CHOICE_MENU=`cat /tmp/vrin_menu`

    case $RETVAL in
        0)
            case $CHOICE_MENU in
                a)
                    phy;;
                b)
                    lo;;
                c)
                    proto;;
                d)
                    ospf;;
                e)
                    bgp;;
                f)
                    rip;;
                g)
                    auth;;
                h)
                    prefix;;
                i)
                    show;;
                j)
                    generate;;
                k)
                    restore;;
                l)
                    clear
                    rm /tmp/vrin* 2>/dev/null
                    init 0;;
            esac;;
        1|255)
            clear
            rm /tmp/vrin* 2>/dev/null
            echo "Execute /root/vrin.sh to return to the menu."
            echo
            exit;;
    esac
}

# Global settings
QDIR="/etc/quagga"
CONF_FILE="/root/vrin.conf"
VER="v0.9"

# Using ifconfig to set eth0 IP address
ETH0_IPv4=`grep eth0_ipv4 $CONF_FILE | cut -d " " -f 2`
ETH0_MASKv4=`grep eth0_maskv4 $CONF_FILE | cut -d " " -f 2`
ETH0_MASKv4_DOT=`grep "^$ETH0_MASKv4 " /root/netmask.txt | cut -d " " -f 2`
ETH0_IPv6=`grep eth0_ipv6 $CONF_FILE | cut -d " " -f 2`
/sbin/ifconfig eth0 $ETH0_IPv4 netmask $ETH0_MASKv4_DOT
/sbin/ifconfig eth0 inet6 add $ETH0_IPv6/64

main
