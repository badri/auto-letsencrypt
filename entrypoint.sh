#!/bin/bash

trap "exit" SIGHUP SIGINT SIGTERM

if [ -z "$DOMAINS" ] ; then
  echo "No domains set, please fill -e 'DOMAINS=example.com www.example.com'"
  exit 1
fi

if [ -z "$EMAIL" ] ; then
  echo "No email set, please fill -e 'EMAIL=your@email.tld'"
  exit 1
fi

CHECK_FREQ="${CHECK_FREQ:-30}"

check() {
  echo "* Starting webroot initial certificate request script..."

  certbot certonly -n --standalone -d ${DOMAINS} --text --agree-tos \
      --email ${EMAIL} \
      --server https://acme-v01.api.letsencrypt.org/directory \
      --rsa-key-size 4096 --verbose --keep-until-expiring \
      --standalone-supported-challenges http-01      

  echo "* Certificate request process finished for domain $DOMAINS"

  if [ "$CERTS_PATH" ] ; then
    echo "* Copying certificates to $CERTS_PATH"
    eval cp /etc/letsencrypt/live/$DOMAINS/* $CERTS_PATH/
  fi

  echo "* Next check in $CHECK_FREQ days"
  sleep ${CHECK_FREQ}d
  check
}

check
