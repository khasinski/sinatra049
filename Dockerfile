FROM alpine:3.21

# Grab the APE loader so we can run Cosmopolitan binaries
RUN apk add --no-cache curl \
 && curl -sLo /usr/bin/ape https://cosmo.zip/pub/cosmos/bin/ape-$(uname -m).elf \
 && chmod +x /usr/bin/ape

# Fetch ruby-0.49.com from the ancient_ruby gem on RubyGems
RUN curl -sL https://rubygems.org/downloads/ancient_ruby-0.49.0.gem -o /tmp/gem.tar \
 && cd /tmp && tar xf gem.tar data.tar.gz && tar xzf data.tar.gz exe/ruby-0.49.com \
 && mv exe/ruby-0.49.com /usr/local/bin/ && chmod +x /usr/local/bin/ruby-0.49.com \
 && rm -rf /tmp/* \
 && printf '#!/bin/sh\nexec /usr/bin/ape /usr/local/bin/ruby-0.49.com "$@"\n' > /usr/local/bin/ruby-0.49 \
 && chmod +x /usr/local/bin/ruby-0.49 \
 && apk del curl

WORKDIR /app
COPY sinatra049.rb app.rb ./

EXPOSE 8049
CMD ["ruby-0.49", "app.rb"]
