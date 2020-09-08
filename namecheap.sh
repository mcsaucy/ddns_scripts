#!/bin/bash

set -e
set -o pipefail

function usage_and_die() {
    {
        echo "Updates a Namecheap dynamic DNS record to the IP for an interface."
        echo "If no hostname is provided, we will attempt to set a record after"
        echo "the running system's hostname."
        echo
        echo "Usage: \\"
        echo "  NAMECHEAP_DDNS_PASS=foobar \\"
        echo "  $0 interface_name [hostname]"
    } >&2
    exit 1
}

function fatal() {
    echo "Fatal: $*" >&2
    exit 1
}

function getip() {
    { ip addr show "$1" \
        | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}'
    } || fatal "failed to get IP for interface $1"
}

function domain() {
    dom="${1#*.}"

    if [[ -z "$dom" ]]; then
        fatal "failed to determine domain name from provided fqdn <$1>."
    fi

    if [[ -z "${dom#*.}" ]]; then
        fatal "<$dom> doesn't seem like a domain name you own..."
    fi

    echo "$dom"
}

function host() {
    echo "${1%%.*}"
}

function update() {
    BASE="https://dynamicdns.park-your-domain.com/update"
    host="host=$1"
    domain="domain=$2"
    password="password=${NAMECHEAP_DDNS_PASS?}"
    ip="ip=$3"

    echo "Preparing to update $host + $domain to $ip" >&2

    if ! OUT="$(curl -s "${BASE}?$host&$domain&$password&$ip")" ||
        grep -qv "<ErrCount>0</ErrCount>" <<< "$OUT"; then
        fatal "failed to update; response: $OUT"
    fi
    echo "Looks like success; result: $OUT" >&2
}

if [[ "$#" -lt 1 || "$#" -gt 2 ]]; then
    usage_and_die
fi

FQDN="${2:-$(hostname -f)}"
update "$(host "$FQDN")" "$(domain "$FQDN")" "$(getip "$1")"
