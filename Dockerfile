# versions :
# ubuntu 18.04
# google-chrome-stable 85.0.4183.102-1
# firefox 80.0.1
# chromedriver 85.0.4183.87
# geckodriver 0.27.0

# default packages : wget
# chrome && firefox packages : gnupg2 unzip libdbus-glib-1-dev
# selenium packages : xvfb fluxbox openjdk-8-jdk-headless
# supervisord packages : supervisor

FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

ENV WIDTH=1920 \
    HEIGHT=1080 \
    DPI=72 \
    DEPTH=24 \
    DISPLAY=:99

COPY . /

RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        wget \
        gnupg2 \
        unzip \
        libdbus-glib-1-dev \
        xvfb \
        fluxbox \
        openjdk-8-jdk-headless \
        supervisor && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    apt-get -y update && \
    apt-get -y --no-install-recommends install google-chrome-stable=85.0.4183.102-1 && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://chromedriver.storage.googleapis.com/85.0.4183.87/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/bin

RUN wget https://download-installer.cdn.mozilla.net/pub/firefox/releases/80.0.1/linux-x86_64/en-US/firefox-80.0.1.tar.bz2 && \
    tar -xjf firefox-80.0.1.tar.bz2 -C /usr/local/lib && \
    ln -s /usr/local/lib/firefox/firefox /usr/bin/firefox && \
    wget https://github.com/mozilla/geckodriver/releases/download/v0.27.0/geckodriver-v0.27.0-linux64.tar.gz && \
    tar -xvzf geckodriver-v0.27.0-linux64.tar.gz -C /usr/bin

RUN wget http://selenium-release.storage.googleapis.com/3.9/selenium-server-standalone-3.9.0.jar

RUN mv supervisord.conf /etc/supervisor/conf.d/ && \
    chmod +x start-xvfb.sh start-fluxbox.sh start-selenium.sh

RUN rm -rf \
        chromedriver_linux64.zip \
        firefox-80.0.1.tar.bz2 \
        geckodriver-v0.27.0-linux64.tar.gz

EXPOSE 4444

CMD ["/usr/bin/supervisord"]
