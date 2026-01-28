#!/bin/bash

echo "Setting variables..."
certificate_name=greenhouse_step_ca.crt
origin="/greenhouse/ca-certificates"
destiny="/var/www/html/ca-certificates"
occ_certificate="./ca-certificates/$certificate_name"

if [ ! -d $destiny ]; then
    echo "Creating path <$destiny>"
    mkdir $destiny
else 
    echo "Path <$destiny already> exist"
fi

echo "Duplicating Greenhouse CA certificate <greenhouse_step_ca.crt>..."
cp $origin/$certificate_name $destiny/$certificate_name

echo "Importing certificate <$destiny/$certificate_name> ..."
/var/www/html/occ security:certificates:import $occ_certificate
echo "Import completed. Checking current certificates..."
/var/www/html/occ security:certificates
echo "Done!"