# asn-auto-pf-table
Generates per-company pf tables (i.e. "table \<rackspace\> { $CIDRS }") that contains all of the company's assigned net cidrs via ASN lookups.

Populate company_list.txt with the names of companies you would like to build pf tables for, then run the asn-auto-pf-table.sh
script.  Once that is complete, you should have a file in your $CACHEDIR for each company, which you can then use in pf.conf
as such:

block in on vlan2000 proto tcp from any to \<facebook\> port { 80, 443 }
