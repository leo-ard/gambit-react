#!/bin/python3

from livereload import Server, shell
from subprocess import Popen, PIPE

import os, argparse


parser = argparse.ArgumentParser(description="A command line util for live-reload servers")
parser.add_argument('--command', type=str, help="Command line to be called when reloading", default="make")
parser.add_argument('--commandcwd', type=str, help="Current directory to call the command from", default=os.getcwd())
parser.add_argument('--cwd', type=str, help="current directory", default=os.getcwd())
parser.add_argument('--watch', action='append')



args = parser.parse_args()

print(args.watch)

GENERATED_NAME = "index.generated.html"


def gen_error(error):
    return f"""
<html>
    <head>
    </head>
    <body>
        <div>
            <textarea style="width:100%; height:100%">
            {error}
            </textarea>
        </div>
    </body>
</html>"""

#os.system("cd "+ args.cwd)
os.chdir(args.cwd)
os.system("pwd")


serve = Server()

def update():
    p = Popen(args.command.split(" "),cwd=args.commandcwd, stdout=PIPE, stderr=PIPE)
    output = p.stdout.read()
    print(p.returncode)
    print(output.decode("utf-8"))
    p.wait()
    if p.returncode == 0:
        os.system("cp index.html " + GENERATED_NAME)
    else:
        s = open(GENERATED_NAME, "w")
        s.write(gen_error(output.decode("utf-8")))
        s.close()

os.system("cp index.html " + GENERATED_NAME)
for watch in args.watch:
    serve.watch(watch, update)

serve.serve(root=".", default_filename=GENERATED_NAME)
