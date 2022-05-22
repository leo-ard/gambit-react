#!/usr/bin/env python2

import sys

if len(sys.argv) != 2:
    print "Usage : " + sys.argv[0] + " certificate_path "
    exit(1)

certificate_path = sys.argv[1]


import os, sys
import BaseHTTPServer
import CGIHTTPServer
import cgitb; cgitb.enable() # enable CGI error reporting
import ssl
server = BaseHTTPServer.HTTPServer
handler = CGIHTTPServer.CGIHTTPRequestHandler
server_address = ("localhost", 4443)
handler.cgi_directories = ["/cgi-bin"]
os.chdir(".")
srvobj = server(server_address, handler)
srvobj.socket = ssl.wrap_socket(srvobj.socket, certfile=certificate_path, server_side=True)
handler.have_fork = False # to use ssl, fork must not be used

print "running on https://localhost:4443"
srvobj.serve_forever()

