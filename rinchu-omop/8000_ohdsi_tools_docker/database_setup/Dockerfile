FROM postgres:15

# Install Japanese locale
RUN apt-get update && apt-get install -y locales && \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen ja_JP.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8
