FROM ubuntu:22.04

ARG SELENIUM_RELEASE \
    DEBIAN_FRONTEND=noninteractive

ENV WIDTH=1920 \
    HEIGHT=1080 \
    DPI=72 \
    DEPTH=24 \
    DISPLAY=:99

USER root

WORKDIR /

COPY . /

RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        curl \
        jq \
        wget \
        unzip \
        bzip2 \
        gnupg2

# google-chrome
RUN curl -sL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get -y install \
        google-chrome-stable && \
    google-chrome --version

# chromedriver
RUN wget -q "https://chromedriver.storage.googleapis.com/$(curl -sL https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip" && \
    unzip chromedriver_linux64.zip -d /usr/bin && \
    rm -rf chromedriver_linux64.zip && \
    chromedriver --version

# firefox
RUN apt-get install -y \
        libgtkd-3-dev \
        libasound2-dev \
        libdbus-glib-1-2 && \
    wget -q -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    tar -xjf firefox.tar.bz2 -C /usr/local/lib && \
    ln -sf /usr/local/lib/firefox/firefox /usr/bin/firefox && \
    rm -rf firefox.tar.bz2 && \
    firefox --version

# geckodriver
RUN wget -q -O geckodriver-linux64.tar.gz "$(curl -sL https://api.github.com/repos/mozilla/geckodriver/releases/latest | jq -r '.assets[] | select(.name | test("^geckodriver-v.*-linux64\\.tar\\.gz$")) | .browser_download_url')" && \
    tar -xzf geckodriver-linux64.tar.gz -C /usr/bin && \
    rm -rf geckodriver-linux64.tar.gz && \
    geckodriver --version

# selenium
RUN apt-get install -y \
        openjdk-11-jdk-headless \
        xvfb \
        fluxbox && \
    # wget -q -O /selenium-server.jar "$(curl -sL https://api.github.com/repos/SeleniumHQ/selenium/releases/latest | jq -r '.assets[] | select(.name | test("^selenium-server-.*\\.jar$")) | .browser_download_url')"
    wget -q -O /selenium-server.jar "https://github.com/SeleniumHQ/selenium/releases/download/selenium-${SELENIUM_RELEASE}/selenium-server-${SELENIUM_RELEASE}.jar"

# supervisord
RUN apt-get install -y \
        supervisor && \
    mv supervisord.conf /etc/supervisor/conf.d/

# cleanup
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 4444

CMD ["/usr/bin/supervisord"]
