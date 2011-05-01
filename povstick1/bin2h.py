#!/usr/bin/env python

import sys, os, string, re, time

if len(sys.argv) > 1:
    name = sys.argv[1]
else:
    name = 'bindata'

print "/*"
print " *"
print " * Generated by %s" % sys.argv[0]
print " * on %s" % time.ctime(time.time())
print " *"
print " */"
    
t = name
t = re.sub('\..*$', '', t)
t = re.sub('[^a-zA-Z_0-9]', '_', t)
if re.search('^[^a-zA-Z_]', t):
    t = '_' + t
print 'BINTYPE %s[] BINSUFFIX = {' % t,

byte_count = 0
output = []
while 1:
    c = sys.stdin.read(1)
    if not c:
        break
    if (byte_count % 8) == 0:
        output.append('\n\t')
    output.append('0x%02x,' % ord(c))
    byte_count = byte_count + 1

print string.join(output, '')
print '\n};'

sys.exit(0)
