FROM steamcmd/steamcmd:debian-12

USER root
RUN apt-get update && apt-get install -y libgcc-s1 && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 7778/udp
EXPOSE 27018/udp
EXPOSE 8889/tcp

ENTRYPOINT ["/start.sh"]