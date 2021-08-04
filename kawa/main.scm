(require <io.jooby>)

(define (route app method path handler)
  (let ((handler (object (<io.jooby.Route$Handler>)
			 ((apply (ctx <io.jooby.Context>)) ::string
			  (handler ctx)))))
    (app.route method path handler)))

(define (hashmap alist)
  (let ((map (java.util.HashMap)))
    (loop for el in alist
	 do (map.put (car el) (cadr el)))
    map))

(define (template filename context-alist)
  (let* ((ctx (hashmap context-alist))
	 (path (java.nio.file.Path:of filename '()))
	 (file (java.nio.file.Files:readString path))
	 (engine ((io.pebble.PebbleEngine.Builder).build))
	 (compiledTmpl (engine.getTemplate filename))
	 (writer (jss:new 'StringWriter)))
    (compiledTmpl.evaluate writer ctx)))

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
  (server.setOptions ((io.jooby.ServerOptions).setPort port))
  (server.start app)
  (server.join))
