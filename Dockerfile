FROM ruby:3.2.1-bullseye

# Note: This is deprecated
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - 

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    ffmpeg \
    nodejs \
    postgresql-client \
    python3 \
    python3-pip && \
    rm -rf /var/apt/*

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle config set clean true && \
    bundle config set deployment true && \
    bundle config set no-cache true && \
    bundle config set without 'development test' && \
    bundle install

COPY package.json /app/package.json
COPY yarn.lock /app/yarn.lock
RUN npm install -g --python=python3 npm node-gyp yarn && \
    yarn install --production

COPY . /app

RUN chmod +x /app/docker/entrypoint.sh
ENTRYPOINT ["/app/docker/entrypoint.sh"]
EXPOSE 3000

ENV PATH="/app/bin:${PATH}"
ENV RAILS_ENV=production
ENV NODE_ENV=production

# Precompile assets
RUN webpack

ENV RAILS_SERVE_STATIC_FILES="yes"
ENV RAILS_LOG_TO_STDOUT="yes"
ENV PORT=3000

CMD ["start-server"]
