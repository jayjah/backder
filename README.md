![Dart](https://img.shields.io/badge/Dart-2.12.1-green)

# Backup tool
    CLI dart script to perform some backup actions on 
    provided docker containers. 

    Can interacts with postgres docker container and
    a jayjah/server docker container. 
    It collects data information from
    postgres (pg_dump) and files from jayjah/server.
    These information are zipped and transmitted 
    to a preconfigured restic http server.
    An email error handler is integrated to ensure 
    an interaction is possible from admin side of view.


Written by @jayjah(jayjah1) <markuskrebs93@gmail.com>

