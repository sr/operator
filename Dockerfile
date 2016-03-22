FROM teampass/teampass:2.1.25.2

COPY docker-entrypoint.sh /

ENTRYPOINT /docker-entrypoint.sh

CMD /start.sh