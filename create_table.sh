#!/bin/bash
# Simple script to create a sqlite3 database called 'dns_data.db' with the tables 'dns'
# Table contains entries for the following columns:
#   typeid: 1, 2, or 3. 1: SOA data, 2: root domain entries, 3: host.domain entries
#   host: hostname
#   domain: domain
#   record_type: Type of DNS record (A, MX, CNAME, AAAA supported)
#   record_data: The record data to populate

sqlite3 dns_data.db 'CREATE TABLE dns (typeid INTEGER NOT NULL, host TEXT NOT NULL, domain TEXT NOT NULL, record_type TEXT NOT NULL, record_data TEXT NOT NULL)'