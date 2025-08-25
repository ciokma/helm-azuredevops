#!/usr/bin/env bash
set -e
/app/handler.sh;
echo -ne "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"; 