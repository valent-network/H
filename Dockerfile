FROM nginx:1-alpine

ENV CLIENT_MAX_BODY_SIZE 20M
ENV VALENT_PUMA_URL puma:3000

COPY default.conf /default.conf.template
COPY nginx.conf /nginx.conf.template

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]