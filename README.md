# JVM lisp examples

This repo contains examples of running non-trivial lisp programs
integrating with major JVM libraries to make a web application with
support for text templates.

# Running the Armed Bear Common Lisp example

Install and build a patched version of abcl (assuming you already have Java SDK):

```
$ mkdir ~/vendor
$ cd ~/vendor
$ git clone https://github.com/eatonphil/abcl
$ cd abcl
$ git checkout pe/more-variadic
$ sudo {dnf/brew/apt} install ant maven
$ ant -f build.xml
```

Start the application server:

```
$ cd ~/vendor
$ git clone https://github.com/eatonphil/jvm-lisp-examples
$ cd jvm-lisp-examples/abcl
$ mvn install
$ ~/vendor/abcl/abcl --load main.lisp
```

In another terminal:

```
$ curl localhost:8080/search
<html>
<title>Version 1.0.0</title>
  <h2>cat</h2>
  <h2>dog</h2>
  <h2>mouse</h2>
</html>
$ curl localhost:8080/hello-world
Hello world!% 
```

Huzzah!

# Running the Kawa Scheme example

WIP...
