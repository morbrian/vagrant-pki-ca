FROM registry.access.redhat.com/rhscl/nginx-112-rhel7

USER root

COPY nginx.conf /etc/opt/rh/rh-nginx112/nginx/nginx.conf
#COPY custom_CAs.pem /etc/nginx/certs/custom_CAs.pem

VOLUME ["/etc/nginx/certs", "/opt/app-root/etc/nginx.d"]

EXPOSE 8443

CMD /opt/rh/rh-nginx112/root/usr/sbin/nginx -g "daemon off;"

