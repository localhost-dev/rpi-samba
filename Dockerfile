# Samba share for Raspberry Pi
FROM balenalib/rpi-raspbian:stretch
ENV DEBIAN_FRONTEND=noninteractive

# Update libs & install things
RUN apt-get update && \
apt-get install -y --no-install-recommends samba-common-bin samba && \
apt-get autoremove && \
apt-get autoclean && \
apt-get clean

# Add entrypoint script
ADD entryfile.sh /entryfile.sh
RUN chmod u+x /entryfile.sh

# Expose ports from services
EXPOSE 445

ENTRYPOINT ["/entryfile.sh"]
