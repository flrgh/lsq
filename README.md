# lsq
A miniature bash framework for querying the livestatus API

## Setup

* Clone the repo (of course):
```$ git clone https://github.com/michaeljmartin/lsq```

* Create a file called ```.lsqrc``` in your home directory and set your variables:
```
LSQ_BASEDIR=$HOME/lsq                 # Path to repo
PORT=4000                             # Port livestatus is listening on
TIMEOUT=5                             # Time (in seconds) to timeout when querying livestatus
MONITORS=(192.168.0.5 192.168.0.6)    # Nagios/Livestatus servers
```
(Alternatively you could just export these variables via your ```.bashrc```)

* Optionally, copy or symlink the lsq script to someplace in your ```$PATH```

```
$ ln -s $HOME/lsq/lsq $HOME/bin/lsq
```

## Basic Usage
* Add a livestatus query:

```
$ cat > $HOME/lsq/queries/broken.lql <<EOF
> GET services
> Columns: host_name description state
> Filter: state != 0
> EOF
```

* Run it:

```
$ lsq broken
my_host;smtp;1
my_host;apache;1
my_other_host;mysql;2
```

As you can see, lsq takes the argument, looks for the corresponding ```.lql``` file, and runs that query against your monitor endpoints.

Add a line to source ```lsq/lsq_completion.sh``` to your ```.bashrc```, and your query names will be tab-completed!

## Customization

### Post-processing
If you find yourself commonly piping a query through some other commands to alter the presentation (sort it, beautify it, etc), add a ```.post``` script in the queries directory and have it read from ```stdin```:

```
$ cat > lsq/queries/broken.post <<EOF
> #!/bin/sh
> column -s ';' -t </dev/stdin
> EOF
$ chmod u+x lsq/queries/broken.post
```

Now the output of your query is written out to that script:
```
$ lsq broken
my_host        smtp    1
my_host        apache  1
my_other_host  mysql   2
```

Before you end up with a bunch of queries that have the same content in their ```.post``` script, add a ```default.post``` script, and lsq will use that if no ```.post``` script exists for the query you are running.


### Pre-processing
This all works great for queries that are always the same. What if we want to do some more filtering or modify the query before we run it? That's where the ```.pre``` script comes in:

```
$ cat > lsq/queries/broken.pre <<EOF
> host=$1
> cat $qfile                          # The $qfile variable here is exported by the primary lsq script and corresponds to your .lql file
> echo "Filter: host_name = $host"
> EOF
$ chmod u+x lsq/queries/broken.pre
```

The array ```$@``` is shifted and then passed to your ```.pre``` script, so now we can do this:
```
$ lsq broken my_host
my_host        smtp    1
my_host        apache  1
```

If you want, you can validate user input from your ```.pre``` script by exiting with a non-zero status:

```
$ cat > lsq/queries/broken.pre <<EOF
> host=$1
> if [[ -z $host ]]; then
>     echo "ERROR: No hostname provided"
>     exit 1
> fi
> cat $qfile
> echo "Filter: host_name = $host"
> EOF
$ lsq broken
Pre-query script exited with error:

ERROR: No hostname provided
```
