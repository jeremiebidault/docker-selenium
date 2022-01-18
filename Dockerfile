FROM ubuntu:21.04

ARG SELENIUM \
    GOOGLE_CHROME=95.0.4638.54-1 \
    CHROMEDRIVER=95.0.4638.17 \
    FIREFOX=93.0 \
    GECKODRIVER=0.30.0 \
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
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        bzip2 \
        libdbus-glib-1-2 \
        xvfb \
        fluxbox \
        openjdk-11-jdk-headless \
        supervisor && \
    # google-chrome-stable
    wget -q https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${GOOGLE_CHROME}_amd64.deb && \
    dpkg -i google-chrome-stable_${GOOGLE_CHROME}_amd64.deb || true && apt-get --fix-broken install -y && \
    rm -rf google-chrome-stable_${GOOGLE_CHROME}_amd64.deb && \
    google-chrome --version && \
    # chromedriver
    wget -q https://chromedriver.storage.googleapis.com/${CHROMEDRIVER}/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/bin && \
    rm -rf chromedriver_linux64.zip && \
    chromedriver --version && \
    # firefox
    wget -q https://download-installer.cdn.mozilla.net/pub/firefox/releases/${FIREFOX}/linux-x86_64/en-US/firefox-${FIREFOX}.tar.bz2 && \
    tar -xjf firefox-${FIREFOX}.tar.bz2 -C /usr/local/lib && \
    ln -s /usr/local/lib/firefox/firefox /usr/bin/firefox && \
    rm -rf firefox-${FIREFOX}.tar.bz2 && \
    firefox --version && \
    # geckodriver
    wget -q https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER}/geckodriver-v${GECKODRIVER}-linux64.tar.gz && \
    tar -xvzf geckodriver-v${GECKODRIVER}-linux64.tar.gz -C /usr/bin && \
    rm -rf geckodriver-v${GECKODRIVER}-linux64.tar.gz && \
    geckodriver --version && \
    # selenium
    wget -q -O /selenium-server.jar https://github.com/SeleniumHQ/selenium/releases/download/selenium-${SELENIUM}/selenium-server-${SELENIUM}.jar && \
    # supervisord
    mv supervisord.conf /etc/supervisor/conf.d/ && \
    chmod +x start-xvfb.sh start-fluxbox.sh start-selenium.sh && \
    # cleanup
    rm -rf /var/lib/apt/lists/*

EXPOSE 4444

CMD ["/usr/bin/supervisord"]
