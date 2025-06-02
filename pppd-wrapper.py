#!/usr/bin/python3
import socket
import os
import sys
import pty
import time
import logging
import signal

WIFI2DIALUPCONF = "/WiFi2DialUp/wifi2dialup.conf"
PPPD = ["/usr/sbin/pppd", "nodetach"]  # Added 'nodetach' to keep pppd in foreground

HOST = '127.0.0.1'
PORT = 5432

for line in open(WIFI2DIALUPCONF):
    if line.startswith("PPPDDIALUPDHOST="):
        pppddialupdhostconfig = line.split("=")
        pppddialupdhost = pppddialupdhostconfig[1].split(":")
        HOST = pppddialupdhost[0]
        PORT = int(pppddialupdhost[1])

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
logging.basicConfig(filename='pppd-dialupd.log', level=logging.INFO)
logging.info('Starting pppd-dialupd...')
logging.info('Socket created!')
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

try:
    s.bind((HOST, PORT))
except socket.error as msg:
    logging.info(f'Bind failed. Error Code: {msg[0]} Message: {msg[1]}')
    sys.exit()
logging.info('Socket bind complete!')
s.listen(10)
logging.info('Socket now listening...')

prevOutFd = os.dup(1)
prevInFd = os.dup(0)
prevErrFd = os.dup(2)

# Ignore SIGPIPE to prevent crashes on closed socket writes
signal.signal(signal.SIGPIPE, signal.SIG_IGN)

while True:
    conn, addr = s.accept()
    logging.info(f'Connected with {addr[0]}:{addr[1]}')
    conn.send(b"Connection established. Negotiating PPP...")

    os.dup2(conn.fileno(), 0)
    os.dup2(conn.fileno(), 1)
    os.dup2(conn.fileno(), 2)

    try:
        pty.spawn(PPPD)  # PPPD now includes 'nodetach'
    except OSError as e:
        logging.error(f'Error spawning pppd: {e}')

    os.dup2(prevInFd, 0)
    os.dup2(prevOutFd, 1)
    os.dup2(prevErrFd, 2)

    logging.info("Closing connection....")
    conn.close()
