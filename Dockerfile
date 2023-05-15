FROM nginx:1-alpine

ENV CLIENT_MAX_BODY_SIZE 20M
ENV FIDER_URL http://srv-captain--global-fider:3000
ENV VALENT_PUMA_URL http://srv-captain--valent-puma:3000

COPY default.conf /default.conf.template
COPY nginx.conf /nginx.conf.template

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]