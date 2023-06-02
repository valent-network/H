FROM nginx:1-alpine

ENV CLIENT_MAX_BODY_SIZE 20M
ENV VALENT_PUMA_URL puma:3000
ENV BUDGET_BASE_PATH /budget
ENV VALENT_API_HOST https://recar.io

ADD apps apps

COPY default.conf /default.conf.template
COPY nginx.conf /nginx.conf.template

COPY apps/error.html /var/www/nginx/error/error.html
COPY nostr.json /var/www/nginx/nostr.json

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]