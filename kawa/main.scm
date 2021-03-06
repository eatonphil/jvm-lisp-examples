(require 'hash-table)

(define (route app method path handler)
  (let ((rh (object (io.jooby.Route$Handler)
		         #| This method exists just to stop Jooby from trying to introspect Java code that doesn't exist because this isn't written in Java. |#
			 ((apply (ctx ::io.jooby.Context)) ::java.lang.Object
			  (handler ctx))
			 ((apply (ctx ::io.jooby.Context)) ::string
			  #!null))))
    (app:route method path rh)))

(define (template filename context-alist)
  (let* ((ctx (alist->hash-table context-alist))
	 (path (java.nio.file.Path:of filename (string[])))
	 (file (java.nio.file.Files:readString path))
	 (engine ((io.pebble.PebbleEngine.Builder):build))
	 (compiledTmpl (engine:getTemplate filename))
	 (writer (java.io.StringWriter)))
    (compiledTmpl:evaluate writer ctx)))

(define (register-endpoints app)
  (route app "GET" "/"
	 (lambda (ctx) "An index!"))
  (route app "GET" "/search"
	 (lambda (ctx)
	   (template "search.tmpl" '(("version" "1.0.0")
				     ("results" '("cat" "dog" "mouse"))))))
  (route app "GET" "/hello-world"
	 (lambda (ctx) "Hello world!")))

(let* ((port 8080)
       (server (io.jooby.netty.Netty))
       (app (io.jooby.Jooby)))
  (register-endpoints app)
  (server:setOptions ((io.jooby.ServerOptions):setPort port))
  (server:start app)
  (server:join))
