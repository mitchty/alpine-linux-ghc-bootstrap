FROM alpine:latest

# Add the apk repository
RUN echo "https://s3-us-west-2.amazonaws.com/alpine-ghc/7.10" >> /etc/apk/repositories

# Make sure I built my own apks... >.<
COPY mitch.tishmack@gmail.com-55881c97.rsa.pub /etc/apk/keys/mitch.tishmack@gmail.com-55881c97.rsa.pub

RUN apk update && apk upgrade

# Prereqs
RUN apk add ghc ghc-dev cabal stack

ENV PATH ${PATH}:/root/.cabal/bin
RUN cabal update && stack update

# Install some stuff
RUN cabal install alex happy

CMD ["bash"]
