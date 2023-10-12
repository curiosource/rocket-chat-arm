FROM node:14.21.3
ENV RC_VERSION='latest'
ENV ARCH='arm64'

RUN useradd -M rocketchat && usermod -L rocketchat
RUN apt -y update && apt -y upgrade
RUN apt install -y unzip cmake make curl build-essential graphicsmagick glibc-source libstdc++6

ENV RUST_HOME /usr/local/lib/rust
ENV RUSTUP_HOME ${RUST_HOME}/rustup
ENV CARGO_HOME ${RUST_HOME}/cargo
RUN mkdir /usr/local/lib/rust && \
    chmod 0755 $RUST_HOME
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > ${RUST_HOME}/rustup.sh \
    && chmod +x ${RUST_HOME}/rustup.sh \
    && ${RUST_HOME}/rustup.sh -y --profile default --component rls rust-analysis
ENV PATH=$PATH:$CARGO_HOME/bin

RUN curl -L https://releases.rocket.chat/${RC_VERSION}/download -o /tmp/rocket.chat.tgz
RUN tar -xzvf /tmp/rocket.chat.tgz -C /tmp
WORKDIR /tmp/bundle/programs/server
#RUN rm npm/node_modules/@rocket.chat/forked-matrix-sdk-crypto-nodejs/lib/index.linux-x64-gnu.node

RUN set -eux
#RUN npm install --unsafe-perm --production \
RUN npm install \
    && npm install --arch=${ARCH} --force
RUN cd /tmp/bundle/programs/server \
    && rm -rf npm/node_modules/sharp \
    && npm install --platform=linux --arch=arm64v8 sharp \
    && mv node_modules/sharp npm/node_modules/sharp
RUN cd /tmp/bundle/programs/server \
    && rm -rf npm/node_modules/bcrypt \
    && npm install --platform=linux --arch=arm64v8 bcrypt \
    && mv node_modules/bcrypt npm/node_modules/bcrypt
RUN cd /tmp/bundle/programs/server \
    && rm -rf npm/node_modules/bcrypt \
    && npm install --platform=linux --arch=arm64v8 bcrypt \
    && mv node_modules/bcrypt npm/node_modules/bcrypt
RUN cd /tmp/bundle/programs/server/npm/node_modules/meteor/accounts-password \
    && rm -rf /node_modules/bcrypt \
    && npm install --platform=linux --arch=arm64v8 bcrypt

RUN mv /tmp/bundle /opt/Rocket.Chat
RUN chown -R rocketchat:rocketchat /opt/Rocket.Chat
RUN mkdir /var/snap
RUN cd /var/snap && mkdir rocketchat-server
RUN chown -R rocketchat:rocketchat /var/snap

USER rocketchat
WORKDIR /opt/Rocket.Chat
