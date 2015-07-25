FROM alpine:latest

# Add the apk repository
RUN echo "https://s3-us-west-2.amazonaws.com/alpine-ghc/7.10" >> /etc/apk/repositories

# Make sure I built my own apks... >.<
COPY mitch.tishmack@gmail.com-55881c97.rsa.pub /etc/apk/keys/mitch.tishmack@gmail.com-55881c97.rsa.pub

RUN apk update 

# Prereqs
RUN apk add ghc cabal-install bash linux-headers musl-dev gmp-dev zlib-dev make

ENV PATH ${PATH}:/root/.cabal/bin
RUN cabal update 

# Install some stuff
RUN cabal install alex happy stack

CMD ["bash"]
