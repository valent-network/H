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

mkdir -p /var/www/nginx/budget      && cat /apps/budget.html.template       | envsubst '$BUDGET_BASE_PATH $VALENT_API_HOST' > /var/www/nginx/budget/index.html
mkdir -p /var/www/nginx/dashboard   && cat /apps/dashboard.html.template    | envsubst '$VALENT_API_HOST'                   > /var/www/nginx/dashboard/index.html
mkdir -p /var/www/nginx/ads         && cat /apps/ad.html.template           | envsubst '$VALENT_API_HOST'                   > /var/www/nginx/ads/index.html
mkdir -p /var/www/nginx/manager     && cat /apps/manager.html.template      | envsubst '$VALENT_API_HOST'                                   > /var/www/nginx/manager/index.html

mv /apps/landing /var/www/nginx

exec "$@"
