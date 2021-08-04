(require :abcl-contrib)
(require :abcl-asdf)
(require :jss)
(setf jss:*muffle-warnings* nil)

(setf imports '("io.jooby:jooby"
		"io.jooby:jooby-netty"
		"io.pebbletemplates:pebble"))
(loop for import in imports
      do (java:add-to-classpath
	  (abcl-asdf:as-classpath (abcl-asdf:resolve import))))

(defun route (app method path handler)
  (let ((handler (jss:new (java:jnew-runtime-class
			     (substitute #\$ #\/ (substitute #\$ #\- path))
			     :interfaces (list "io.jooby.Route$Handler")
			     :methods (list
					; Need to define this one to make Jooby figure out the return type
					; Otherwise it tries to read "this file" which isn't a Java file so cannot be parsed
				       (list "apply" "java.lang.String" '("io.jooby.Context")
					     (lambda (this ctx) nil))
					; This one actually gets called
				       (list "apply" "java.lang.Object" '("io.jooby.Context")
					     (lambda (this ctx)
					       (funcall handler ctx))))))))
    (#"route" app method path handler)))

(defun hashmap (alist)
  (let ((map (jss:new 'HashMap)))
    (loop for el in alist
	 do (#"put" map (car el) (cadr el)))
    map))

(defun template (filename context-alist)
  (let* ((ctx (hashmap context-alist))
	 (path (java:jstatic "of" "java.nio.file.Path" filename (java:jnew-array "java.lang.String" 0)))
	 (file (#"readString" 'java.nio.file.Files path))
	 (engine (#"build" (jss:new 'PebbleEngine.Builder)))
	 (compiledTmpl (#"getTemplate" engine filename))
	 (writer (jss:new 'StringWriter)))
    (#"evaluate" compiledTmpl writer ctx)))

(defun register-endpoints (app)
  (route app "GET" "/"
	 #'(lambda (ctx) "An index!"))
  (route app "GET" "/search"
	 #'(lambda (ctx)
	     (template "search.tmpl" '(("version" "1.0.0")
				       ("results" '("cat" "dog" "mouse"))))))
  (route app "GET" "/hello-world"
	 #'(lambda (ctx) "Hello world!")))

(let* ((port 8080)
       (server (jss:new 'Netty))
       (app (jss:new 'Jooby)))
  (register-endpoints app)
  (#"setOptions" server (#"setPort" (jss:new 'ServerOptions) port))
  (#"start" server app)
  (#"join" server))
