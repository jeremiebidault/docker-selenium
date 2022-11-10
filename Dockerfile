FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

ENV WIDTH=1920 \
    HEIGHT=1080 \
    DPI=72 \
    DEPTH=24 \
    DISPLAY=:99

USER root

WORKDIR /

COPY . /

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        sudo \
        curl \
        jq \
        wget \
        unzip \
        bzip2 \
        supervisor

    # firefox
RUN apt-get install -y --no-install-recommends \
        libgtkd-3-dev \
        libasound2-dev \
        libdbus-glib-1-2

    # selenium
RUN apt-get install -y --no-install-recommends \
        openjdk-11-jdk-headless \
        xvfb \
        fluxbox

    # google-chrome-stable
RUN wget -q "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && \
    dpkg -i google-chrome-stable_current_amd64.deb || true && \
    apt-get --fix-broken install -y && \
    rm -rf google-chrome-stable_current_amd64.deb && \
    google-chrome --version

    # chromedriver
RUN wget -q "https://chromedriver.storage.googleapis.com/$(curl -sL https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip" && \
    unzip chromedriver_linux64.zip -d /usr/bin && \
    rm -rf chromedriver_linux64.zip && \
    chromedriver --version

    # firefox
RUN wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    tar -xjf firefox.tar.bz2 -C /usr/local/lib && \
    ln -sf /usr/local/lib/firefox/firefox /usr/bin/firefox && \
    rm -rf firefox.tar.bz2 && \
    firefox --version

    # geckodriver
RUN GECKODRIVER_URI=$(curl -sL https://api.github.com/repos/mozilla/geckodriver/releases/latest | jq -r '.assets[] | select(.name | test("^geckodriver-v.*-linux64\\.tar\\.gz$")) | .browser_download_url') && \
    wget -q -O geckodriver-linux64.tar.gz "${GECKODRIVER_URI}" && \
    tar -xzf geckodriver-linux64.tar.gz -C /usr/bin && \
    rm -rf geckodriver-linux64.tar.gz && \
    geckodriver --version

    # selenium
RUN SELENIUM_URI=$(curl -sL https://api.github.com/repos/SeleniumHQ/selenium/releases/latest | jq -r '.assets[] | select(.name | test("^selenium-server-.*\\.jar$")) | .browser_download_url') && \
    wget -q -O /selenium-server.jar "${SELENIUM_URI}"

    # supervisord
RUN mv supervisord.conf /etc/supervisor/conf.d/ && \
    chmod +x start-xvfb.sh start-fluxbox.sh start-selenium.sh

    # cleanup
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 4444

CMD ["/usr/bin/supervisord"]
