#! /usr/bin/python
import sys
import subprocess
from datetime import datetime

def write_stdout(s):
    sys.stdout.write(s)
    sys.stdout.flush()

def write_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()

def main(args):
    while 1:
        write_stdout('READY\n') # transition from ACKNOWLEDGED to READY
        line = sys.stdin.readline()  # read header line from stdin
        headers = dict([ x.split(':') for x in line.split() ])
        data = sys.stdin.read(int(headers['len'])) # read the event payload
        write_stderr( datetime.now().strftime("%Y-%m-%d %H:%M:%S,%f")[:-3])
        write_stderr(" INFO Event Listener ")
        res = subprocess.call(args, stdout=sys.stderr, stderr=sys.stderr); # don't mess with real stdout
        write_stdout('RESULT 2\nOK') # transition from READY to ACKNOWLEDGED

if __name__ == '__main__':
    main(sys.argv[1:])
    import sys