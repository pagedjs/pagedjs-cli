FROM ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Los_Angeles

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
	software-properties-common \
  wget \
	xvfb \
	libxss1 \
	dbus \
	dbus-x11 \
	git \
	openssh-client \
	&& rm -rf /var/lib/apt/lists/*


# Install ghostscript
RUN apt-get update && apt-get install -y \
	build-essential make gcc g++ \
	python3 \
	ghostscript \
	libgs-dev \
	&& rm -rf /var/lib/apt/lists/*


# Update Freetype
COPY docker-font.conf /etc/fonts/local.conf
ENV FREETYPE_PROPERTIES="truetype:interpreter-version=35"

# Install fonts
# from https://github.com/browserless/browserless/blob/main/docker/chrome/Dockerfile#L11-L27
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections && \
  apt-get -y -qq install software-properties-common &&\
  apt-add-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner" && \
  apt-get -y -qq --no-install-recommends install \
    fontconfig \
    fonts-freefont-ttf \
    fonts-gfs-neohellenic \
    fonts-indic \
    fonts-ipafont-gothic \
    fonts-kacst \
    fonts-liberation \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-roboto \
    fonts-thai-tlwg \
    fonts-ubuntu \
    fonts-wqy-zenhei \
		&& rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=development
# Install Node.js
RUN apt-get update && \
    mkdir -p /etc/apt/keyrings && \
    curl -sL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >> /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Add user so we don't need --no-sandbox.
RUN groupadd --gid 999 node \
  	&& useradd --uid 999 --gid node --shell /bin/bash --create-home node \
		&& adduser node audio \
		&& adduser node video

ENV CONNECTION_TIMEOUT=60000
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PLAYWRIGHT_BROWSERS_PATH=/usr/local/bin/chromium-browsers
# Revision from https://github.com/microsoft/playwright/blob/main/packages/playwright-core/browsers.json#L6
ENV BROWSER_REVISION=1097
ENV PUPPETEER_EXECUTABLE_PATH="$PLAYWRIGHT_BROWSERS_PATH/chromium-$BROWSER_REVISION/chrome-linux/chrome"
RUN npm install playwright@1.41.1 --location=global
RUN playwright install --with-deps chromium

RUN npm install node-gyp --location=global

ENV DBUS_SESSION_BUS_ADDRESS autolaunch:
RUN service dbus start

# Run everything after as non-privileged user.
USER node

ENV DIRECTORY /home/node/pagedjs-cli
RUN mkdir -p $DIRECTORY
WORKDIR $DIRECTORY

COPY --chown=node:node package.json package-lock.json rollup.config.js src/browser.js $DIRECTORY/
COPY --chown=node:node src/browser.js $DIRECTORY/src/

RUN npm install
RUN GS4JS_HOME="/usr/lib/$(gcc -dumpmachine)" npm install ghostscript4js

COPY --chown=node:node . $DIRECTORY

CMD ["./src/cli.js"]
