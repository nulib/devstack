FROM ruby:2.5.7

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        sqlite3 \
        libxml2-dev libxslt1-dev \
        nodejs \
        npm \
        yarn \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /usr/src/app
RUN git clone https://github.com/geoblacklight/workshop-app.git .
RUN bundle install
RUN yarn install

EXPOSE 3000
