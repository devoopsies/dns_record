# dns_record
Small tool to add, list, and delete records from a BIND9 instance

# Tools included in this package:

* create_table.sh
* record_change.sh
* dnsupdated

## create_table.sh

Simple script to create a sqlite3 database called 'dns_data.db' with the tables 'dns'. This only needs to be added once.

Table contains entries for the following columns:

* typeid: 1, 2, or 3. 1: SOA data, 2: root domain entries, 3: host.domain entries
* host: hostname
* domain: domain
* record_type: Type of DNS record (A, MX, CNAME, AAAA supported)
* record_data: The record data to populate

This will be the table that data is pulled from by dnsupdated to populate your BIND9 configuration files

## record_change.sh

An interactive script to add, list, or delete DNS records by hostname and domain. Use as follows:

```bash
./record_change.sh add
./record_change.sh list
./record_change.sh delete
```

## dnsupdated

A daemon that reads data from your dns_data.db database and writes it out to bind9 files. Bind9 is reloaded automatically when records are updated.

The following assumptions are made:

* Zones are located in the `/etc/bind/zones/` directory
* Zones are named as `db.$domain.$tld`. 

The domain `devoopsies.com` would therefore have the following zone file:

```bash
/etc/bind/zones/db.devoopsies.com
```