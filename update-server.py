#!/bin/python3

from livereload import Server, shell
from subprocess import Popen, PIPE
import os

GENERATED_NAME = "index-generated.html"


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
</html>


    """


serve = Server()

def update():
    p = Popen(['make'], stdout=PIPE, stderr=PIPE)
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

serve.watch('*.scm', update)
serve.serve(root=".", default_filename=GENERATED_NAME)
