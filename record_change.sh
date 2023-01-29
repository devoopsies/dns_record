#!/bin/bash
# A simple script that interacts with a sqlite database for listing, adding, and deleting domain DNS records

# Function to add records to database
function add_record {
    echo "please enter record data"
    read "record_data"
    record_add="INSERT INTO dns (typeid, host, domain, record_type, record_data) VALUES('3', '$host', '$domain', '$record_type', '$record_data')"
    record_add_manage="INSERT INTO dns (typeid, host, domain, record_type, record_data) VALUES('3', 'manage.$host', '$domain', '$record_type', '$record_data')"
    sqlite3 dns_data.db "$record_add"
    # List all records to be added
    # Management records with unique data still need to be coded. For now we can add record twice, once as 'manage.$host.domain.tld'
    echo "A record with the following data has been added:"
    echo "Host:  " $host
    echo "FQDN:  " $host".burton.fyi"
    echo "Type:  " $record_type 
    echo "Data:  " $record_data
    echo "Your management domain is as follows:"
    echo "Host:   manage."$host
    echo "FQDN:   manage."$host".burton.fyi"
    echo "Type:  " $record_type
    echo "Data:  " $manage_record_data
}

# Function to list records that exist in database
function list_record {
    echo "Please enter a host"
    read host
    if [ -n $host ]
    then
        typeidvar=3
        list_all
    else
    echo "Please enter a domain"
    read domain
    #set the query as a variable so that it may be passed to sqlite as a single parameter
    query="SELECT * FROM dns where HOST='$host' and domain='$domain'"
    echo "You have queried the following entry:" $host.$domain
    #Run the query and clean it up in-line
    #I should clean this up so the query is run once and the data is picked from that
    complete=$(sqlite3 dns_data.db "$query" | sed 's/|/ /g' |awk '{print $2"."$3" IN "$4" "$5}')
    full=$(sqlite3 dns_data.db "$query" | sed 's/|/ /g' |awk '{print $2"."$3}')
    type=$(sqlite3 dns_data.db "$query" | sed 's/|/ /g' |awk '{print $4}')
    data=$(sqlite3 dns_data.db "$query" | sed 's/|/ /g' |awk '{print $5}')
    echo "FQDN:           " $full
    echo "Record Type:    " $type
    echo "Record Data:    " $data
    echo "Complete Record:" $complete
    fi
}

# Function to list all records in BIND9 format
function list_all {
    query="SELECT * FROM dns where typeid='$typeidvar'"
    IFS=' '
    complete=$(sqlite3 dns_data.db "$query" | sed 's/|/ /g' |awk '{print $2"."$3" IN "$4" "$5}')
    echo $complete
}

# Function to list all domains and group by domain
function list_all_domains {
    query="SELECT DISTINCT domain FROM dns"
    IFS=$'\n'
    domains=($(sqlite3 dns_data.db "$query"))
    records=()
    for domain in "${domains[@]}"
    do
        query="SELECT * FROM dns where domain='$domain' and typeid='$typeidvar'"
        IFS=' '
        complete=$(sqlite3 dns_data.db "$query" | sed 's/|/ /g' |awk '{print $2"."$3" IN "$4" "$5}')
        records+=("$complete")
    done

    for ((i=0; i<${#domains[@]}; i++)); do
        echo "Records for ${domains[i]}: "
        echo "${records[i]}"
        echo ""
    done
}

# Funtion to generate zone files for all domains
# Assumed directory to be "/etc/bind/zones/". Might update to take from bind9 conf

function generate_zone_file {
    typeidvar=1
    list_all_domains
    typeidvar=2
    list_all_domains
    typeidvar=3
    list_all_domains
}

# Function to delete records in database
function delete_record {
    # First we must prompt for host name
    echo "Please enter a host"
    read host
    echo "Please enter a domain"
    read domain

    # Set SQL query variable
    query="SELECT * FROM dns where HOST='$host' and domain='$domain'"
    echo "The following record will be deleted:"

    # Using previously-set "query" variable, we set the variable "complete". This contains the output of entire command to run the SQL query
    complete=$(sqlite3 dns_data.db "$query" | sed 's/|/ /g' |awk '{print $2"."$3" IN "$4" "$5}')
    # List the output of the above command for confirmation
    echo $complete

    # Similar to "complete" variable, we set the "record_delete" variable in order to use it as an argument against sqlite3's bash interface
    record_delete="delete from dns where host='$host' and domain='$domain'"
    echo "Please type \"ENTER\" to continue:"
    read continue
    if [ "$continue" == "ENTER" ]
    then
        # Run the actual delete using the previously-set "record_delete" variable as the command argument
        sqlite3 dns_data.db  "$record_delete"
        echo "The following record has been deleted:"
        echo "    $host.$domain"
    else
        echo "No changes made"
        echo "Goodbye"
    fi
}

# Code to list a record. Calls the list_record function
if [ "$1" == "list" ]
then
    list_record

# Code to add a record - call the add_record function
elif [ "$1" == "add" ]
then 
    echo "Please enter a host"
    read host
    echo "Please enter domain"
    read domain
    echo "Please enter a record type"
    read record_type
    # Check to make sure record type is valid
    if [ "$record_type" == "A" ]
    then
        add_record
    elif [ "$record_type" == "CNAME" ]
    then
        add_record
    elif [ "$record_type" == "MX" ]
    then
        add_record
    elif [ "$record_type" == "AAAA" ]
    then
        add_record
    else
        echo "Record type must be one of: \"A|CNAME|MX|AAAA\""
    fi

# Code to delete records
elif [ "$1" == "delete" ]
then
    delete_record

# Code to print out DNS entries to file
elif [ "$1" == "output" ]
then
    generate_zone_file

else
    echo "Please enter a valid option: \"list|add|delete|output\""
fi


