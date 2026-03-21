FROM steamcmd/steamcmd:debian-12

USER root
RUN apt-get update && apt-get install -y libgcc-s1 && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

# 포트는 환경변수 PORT, QUERY_PORT, RCON_PORT로 설정 가능
EXPOSE 7778/udp
EXPOSE 27018/udp
EXPOSE 8889/tcp

ENTRYPOINT ["/start.sh"]