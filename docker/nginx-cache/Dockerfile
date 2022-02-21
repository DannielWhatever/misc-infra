FROM nginx:mainline-alpine

ARG REMOTE_HOST

RUN rm /etc/nginx/conf.d/*

COPY proxy.conf etc/nginx/includes/proxy.conf

COPY default.conf /etc/nginx/conf.d/default.conf
RUN sed -i 's/__REMOTE_HOST__/${REMOTE_HOST}/g' /etc/nginx/conf.d/default.conf


EXPOSE 80
