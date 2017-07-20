FROM registry-nginxinc.rhcloud.com/nginx/rhel7-nginx:1.9.2

COPY template.conf /tmp

#DEFAULT
RUN sed s/\$\{SERVER_NAME\}/_/ /tmp/template.conf > /etc/nginx/conf.d/default.conf

#HOST1
RUN sed s/\$\{SERVER_NAME\}/host1.develop.com/ /tmp/template.conf > /etc/nginx/conf.d/host1.develop.com.conf
RUN sed -i s/default_server// /etc/nginx/conf.d/host1.develop.com.conf
RUN sed -i /ssl_client_certificate/d /etc/nginx/conf.d/host1.develop.com.conf
RUN sed -i /ssl_verify_client/d /etc/nginx/conf.d/host1.develop.com.conf
RUN sed -i /ssl_verify_depth/d /etc/nginx/conf.d/host1.develop.com.conf

#HOST2
RUN sed s/\$\{SERVER_NAME\}/host2.develop.com/ /tmp/template.conf > /etc/nginx/conf.d/host2.develop.com.conf
RUN sed -i s/default_server// /etc/nginx/conf.d/host2.develop.com.conf
RUN sed -i /ssl_client_certificate/d /etc/nginx/conf.d/host2.develop.com.conf
RUN sed -i /ssl_verify_client/d /etc/nginx/conf.d/host2.develop.com.conf
RUN sed -i /ssl_verify_depth/d /etc/nginx/conf.d/host2.develop.com.conf

#HOST2
RUN sed s/\$\{SERVER_NAME\}/host3.develop.com/ /tmp/template.conf > /etc/nginx/conf.d/host3.develop.com.conf
RUN sed -i s/default_server// /etc/nginx/conf.d/host3.develop.com.conf


VOLUME ["/etc/nginx/certs", "/var/log/nginx"]

EXPOSE 8443




