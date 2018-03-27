# Build
FROM nginx:1.13.10

LABEL version="1.0"
LABEL maintainer="William Dekou <williamdekou@gmail.com>"

ENV NGINX_VERSION 1.13.10
ENV GIT_EMAIL "williamdekou@gmail.com"
ENV GIT_NAME "William DEKOU"
ENV GIT_USERNAME "williamdekou"
ENV GIT_BRANCH "master"
ENV GIT_REPO "https://github.com/williamdekou/spa-nginx-docker.git"
ENV REMOVE_FILES 0
RUN apt-get -qq update && apt-get -qq -my install curl \ 
    openssh-client \
    wget \
    supervisor \
    curl \
    git \
    gnupg \
    ca-certificates \
    dialog \
    autoconf \
    libssl-dev

# http://nodesource.com/blog/installing-node-js-tutorial-ubuntu/
# step 0
# Adding the NodeSource APT repository for Debian-based distributions repository AND the PGP key for verifying packages
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

# Install Node.js from the Debian-based distributions repository
RUN apt-get install -y nodejs && node -v && npm i npm --global && npm i yarn --global
RUN mkdir -p /var/log/supervisor 

ADD conf/supervisord.conf /etc/supervisord.conf

# Copy our nginx config
RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
mkdir -p /etc/nginx/ssl/ && \
rm -Rf /var/www/* && \
mkdir -p /var/www/spa/
ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf
ADD conf/nginx-site-ssl.conf /etc/nginx/sites-available/default-ssl.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# copy in code
ADD . /tmp/spa 
RUN cd /tmp/spa && yarn && yarn build && mv ./build/* /var/www/spa

# Add Scripts
ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push
ADD scripts/letsencrypt-setup /usr/bin/letsencrypt-setup
ADD scripts/letsencrypt-renew /usr/bin/letsencrypt-renew
RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push && chmod 755 /usr/bin/letsencrypt-setup && chmod 755 /usr/bin/letsencrypt-renew && chmod 755 /start.sh

ADD errors/ /var/www/errors
WORKDIR /var/www/spa

EXPOSE 80 443

CMD ["/start.sh"]

# https://medium.com/@timmykko/deploying-create-react-app-with-nginx-and-ubuntu-e6fe83c5e9e7
# https://stackoverflow.com/questions/33322103/multiple-froms-what-it-means
# supervisor https://www.digitalocean.com/community/tutorials/how-to-install-and-manage-supervisor-on-ubuntu-and-debian-vps
# https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-nginx-for-ubuntu-14-04
# https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04
# http://nginx.org/en/docs/http/configuring_https_servers.html
# https://medium.com/@Doda100VN/deploy-react-app-with-nginx-pm2-9a86de53ef8e
# https://stackoverflow.com/questions/46880853/deploy-create-react-app-on-nginx
# http://zabana.me/notes/build-deploy-react-app-with-nginx.html
# https://linode.com/docs/web-servers/nginx/how-to-configure-nginx/
# https://medium.com/@timmykko/deploying-create-react-app-with-nginx-and-ubuntu-e6fe83c5e9e7
