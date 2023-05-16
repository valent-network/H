#!/bin/sh
set -e

# Compute the DNS resolvers for use in the templates - if the IP contains ":", it's IPv6 and must be enclosed in []
export RESOLVERS=$(awk '$1 == "nameserver" {print ($2 ~ ":")? "["$2"]": $2}' ORS=' ' /etc/resolv.conf | sed 's/ *$//g')
if [ "x$RESOLVERS" = "x" ]; then
    echo "Error: there is no resolvers!!" >&2
    exit 1
fi

cat /default.conf.template | envsubst '$CLIENT_MAX_BODY_SIZE $RESOLVERS' > /etc/nginx/conf.d/default.conf
cat /nginx.conf.template | envsubst '$VALENT_PUMA_URL' > /etc/nginx/nginx.conf

exec "$@"
