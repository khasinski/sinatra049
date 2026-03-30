# sinatra049.rb - Sinatra-style DSL for Ruby 0.49 (1994)
#
# Usage:
#   get "/",           "index"
#   get "/hello/:name", "hello"
#
#   def index()
#     "Welcome!"
#   end
#
#   def hello()
#     "Hello, " + params("name") + "!"
#   end
#
#   run(8049)

%CRLF = "\r\n"

# --- Route storage ---
# Parallel arrays since Ruby 0.49 has no array-of-hashes
$route_methods  = []
$route_patterns = []
$route_handlers = []
$route_params   = []
$route_count    = 0

# --- Request state ---
$params = {}

def params(key)
  $params[key]
end

# --- DSL: route registration ---

def get(path, handler)
  add_route("GET", path, handler)
end

def post(path, handler)
  add_route("POST", path, handler)
end

def add_route(method, path, handler)
  # Extract :param names from a copy
  param_names = []
  tmp = "" + path
  while tmp =~ /:([a-z_]+)/
    param_names.push($1)
    tmp.sub(":([a-z_]+)", "DONE")
  end

  # Build regex string from a copy
  regex_str = "" + path
  regex_str.gsub(":([a-z_]+)", "([^/]+)")
  regex_str = "^" + regex_str + "$"
  # Escape / for use inside eval("path =~ /pattern/")
  regex_str.gsub("/", "\\/")

  $route_methods[$route_count]  = method
  $route_patterns[$route_count] = regex_str
  $route_handlers[$route_count] = handler
  $route_params[$route_count]   = param_names
  $route_count = $route_count + 1
end

# --- Matching ---

def match_route(method, path)
  i = 0
  while i < $route_count
    if $route_methods[i] == method then
      pattern = $route_patterns[i]
      if eval("path =~ /" + pattern + "/") then
        # Extract params
        $params = {}
        names = $route_params[i]
        j = 0
        # Match again to get capture groups
        captures = []
        # $1..$9 are set after =~
        if $1 then captures.push($1) end
        if $2 then captures.push($2) end
        if $3 then captures.push($3) end
        if $4 then captures.push($4) end
        if $5 then captures.push($5) end
        while j < names.length
          $params[names[j]] = captures[j]
          j = j + 1
        end
        return $route_handlers[i]
      end
    end
    i = i + 1
  end
  return nil
end

# --- HTML helpers ---

def h1(text)
  "<h1>" + text + "</h1>"
end

def h2(text)
  "<h2>" + text + "</h2>"
end

def p(text)
  "<p>" + text + "</p>"
end

def a(href, text)
  "<a href=\"" + href + "\">" + text + "</a>"
end

def ul(items)
  html = "<ul>"
  for item in items
    html = html + "<li>" + item + "</li>"
  end
  html + "</ul>"
end

def html(title, body)
  "<html>" + %CRLF +
  "<head><title>" + title + "</title>" +
  "<style>body{font-family:sans-serif;max-width:700px;margin:40px auto;padding:0 20px}" +
  "a{color:#c41}h1{border-bottom:2px solid #c41}</style></head>" + %CRLF +
  "<body>" + body + %CRLF +
  "<hr><em>sinatra049 / Ruby 0.49 (1994)</em></body></html>" + %CRLF
end

# --- HTTP plumbing ---

def parse_request(line)
  parts = line.split(" ")
  result = {}
  result["method"] = parts[0]
  result["path"] = parts[1]
  result
end

def send_response(client, status, content_type, body)
  client.write("HTTP/1.0 " + status + %CRLF)
  client.write("Content-Type: " + content_type + %CRLF)
  client.write("Content-Length: " + body.length.to_s + %CRLF)
  client.write("Connection: close" + %CRLF)
  client.write(%CRLF)
  client.write(body)
end

def not_found(path)
  html("404", h1("404 Not Found") + p("No route matches: " + path) + p(a("/", "Go home")))
end

# --- Server loop ---

def run(port)
  ("\n  sinatra049 has taken the stage on port " + port.to_s + "\n\n").print
  server = TCPserver.open(port)

  while 1
    client = server.accept
    line = client.gets
    if line then
      line.chop

      req = parse_request(line)
      method = req["method"]
      path   = req["path"]

      ("  " + method + " " + path + "\n").print

      # Consume headers
      while 1
        header = client.gets
        if header then
          header.chop
          if header == "" then break end
          if header == "\r" then break end
        else
          break
        end
      end

      # Find matching route
      handler = match_route(method, path)
      if handler then
        body = eval(handler + "()")
        send_response(client, "200 OK", "text/html", body)
      else
        send_response(client, "404 Not Found", "text/html", not_found(path))
      end
    end
    client.close
  end
end
