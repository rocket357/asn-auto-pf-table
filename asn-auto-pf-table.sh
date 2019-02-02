#!/bin/sh

CACHEDIR=/root/net-ranges/ # "include" $CACHEDIR/$company in pf.conf to filter
COMPANY_LIST=/root/company_list.txt

#BINARIES (not tested on non-OpenBSD systems)
FTP=/usr/bin/ftp
GREP=/usr/bin/grep
TR=/usr/bin/tr
CUT=/usr/bin/cut
WHOIS=/usr/bin/whois
SED=/usr/bin/sed
SORT=/usr/bin/sort
MV=/bin/mv
RM=/bin/rm
ECHO=/bin/echo

# there's a better way to do this, but I've not bothered fixing this yet.
for company in `cat $COMPANY_LIST`; do
        $ECHO "Pulling a list of ASNs for $company";
        ASNs=$($FTP -V -o - https://www.ultratools.com/tools/asnInfoResult?domainName=$company | $GREP AS | $TR ' ' '\n' | $GREP tool-results-heading | $CUT -d '>' -f2 | $CUT -d'<' -f1 | $TR -d 'AS');
        $ECHO -n "table <$company> const { " > $CACHEDIR/$company;
        $ECHO > /tmp/$company;
        for ASN in `$ECHO $ASNs`; do
                $ECHO "    Looking up registered netranges for ASN: $ASN";
                $ECHO -n $($WHOIS -h whois.radb.net "!gas$ASN" | $GREP '/' | $TR ' ' '\n') >> /tmp/$company
                $ECHO " " >> /tmp/$company
        done;
        $ECHO " Writing pf table definition to $CACHEDIR$company"
        for ipr in `cat /tmp/$company | tr ' ' '\n' | $SORT -nu`; do $ECHO -n $ipr >> $CACHEDIR/$company; $ECHO -n ", " >> $CACHEDIR/$company; done
        $SED -e 's/, $//' $CACHEDIR/$company > /tmp/$company;
        $MV /tmp/$company $CACHEDIR/$company;
        $ECHO " }" >> $CACHEDIR/$company;
done
