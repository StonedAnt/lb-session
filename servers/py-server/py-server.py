import sys
from time import sleep
from random import randint
from werkzeug.wrappers import Request, Response

port = 12000

@Request.application
def application(request):
    sleep(randint(0,2)) # seconds
    return Response("Python-Server: {0}".format(port))

if __name__ == '__main__':

    args = sys.argv[1:]
    if len(args) == 1:
        port = args[0]

    from werkzeug.serving import run_simple
    run_simple('localhost', port, application)
