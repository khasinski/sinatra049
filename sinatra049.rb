# sinatra049.rb - Sinatra-style DSL for Ruby 0.49 (18 Jul 1994)
#
# Usage:
#   app = Sinatra049.new(8049)
#   app.get("/",            "index")
#   app.get("/hello/:name", "hello")
#   app.run()
#
# Handlers are methods defined on the app's class via apply().
# See app.rb for a full example.

%CRLF = "\r\n"
%CSS = "body{font-family:Georgia,serif;max-width:660px;margin:40px auto;padding:0 20px;color:#222;line-height:1.6}h1{color:#c41;border-bottom:2px solid #c41;padding-bottom:8px}h2{color:#333}a{color:#c41}code{background:#f4f4f4;padding:2px 6px;font-size:90%}pre{background:#f4f4f4;padding:12px;overflow-x:auto}nav{margin:20px 0}nav a{margin-right:16px}.footer{margin-top:40px;padding-top:12px;border-top:1px solid #ddd;color:#999;font-size:85%}"

class Sinatra049
  def Sinatra049.new(port)
    super.init(port)
  end

  def init(port)
    @port = port
    @route_methods  = []
    @route_handlers = []
    @route_params   = []
    @route_paths    = []
    @route_count    = 0
    @params         = {}
    self
  end

  # --- DSL: route registration ---

  def get(path, handler)
    @add_route("GET", path, handler)
  end

  def post(path, handler)
    @add_route("POST", path, handler)
  end

  def @add_route(method, path, handler)
    # Extract param names from path segments using split
    param_names = []
    parts = path.split("/")
    for part in parts
      if part.length > 0 && part[0] == ?:
        param_names.push(part[1, part.length - 1])
      end
    end

    @route_methods[@route_count]  = method
    @route_handlers[@route_count] = handler
    @route_params[@route_count]   = param_names
    @route_paths[@route_count]    = path
    @route_count = @route_count + 1
  end

  # --- Request state ---

  def params(key)
    $sinatra_params[key]
  end

  # --- Route matching ---

  def @match_route(method, path)
    $sinatra_params = {}
    path_parts = path.split("/")
    plen = path_parts.length
    i = 0
    while i < @route_count
      if @route_methods[i] == method
        route_parts = @route_paths[i].split("/")
        if plen == route_parts.length
          if @try_match(path_parts, route_parts, @route_params[i])
            return @route_handlers[i]
          end
        end
      end
      i = i + 1
    end
    return nil
  end

  def @try_match(path_parts, route_parts, names)
    result = {}
    j = 0
    pi = 0
    while j < route_parts.length
      rp = route_parts[j]
      pp = path_parts[j]
      if rp.length > 0 && rp[0] == ?:
        result[names[pi]] = pp
        pi = pi + 1
      else
        if rp != pp then return nil end
      end
      j = j + 1
    end
    $sinatra_params = result
    return %TRUE
  end

  # --- HTTP plumbing ---

  def @send_response(client, status, body)
    resp = "HTTP/1.0 " + status + "\r\nContent-Type: text/html\r\nContent-Length: " + body.length.to_s + "\r\nConnection: close\r\n\r\n" + body
    client.write(resp)
  end

  # --- Server ---

  def run
    printf("\n  sinatra049 has taken the stage on port %d\n\n", @port)
    server = TCPserver.open(@port)

    protect
      while %TRUE
        client = server.accept
        client.sync = %TRUE

        protect
          line = client.gets
          if line
            line.chop
            parts = line.split(" ")
            method = parts[0]
            path   = parts[1]

            printf("  %s %s\n", method, path)

            # Consume all headers before responding
            while %TRUE
              header = client.gets
              if header
                header.chop
                if header == "" then break end
                if header == "\r" then break end
              else
                break
              end
            end

            # Dispatch
            handler = @match_route(method, path)
            if handler
              body = self.apply(handler)
              @send_response(client, "200 OK", body)
            else
              @send_response(client, "404 Not Found", @not_found(path))
            end
          end
        ensure
          client.flush
          client.close
          client = nil
        end
      end
    ensure
      server.close
    end
  end

  # --- HTML helpers ---

  def @not_found(path)
    html("404 Not Found",
      h1("404") +
      p("Nothing here for " + path) +
      p(a("/", "Take me home")))
  end

  def h1(text)
    "<h1>" + text + "</h1>"
  end

  def h2(text)
    "<h2>" + text + "</h2>"
  end

  def p(text)
    "<p>" + text + "</p>"
  end

  def em(text)
    "<em>" + text + "</em>"
  end

  def strong(text)
    "<strong>" + text + "</strong>"
  end

  def code(text)
    "<code>" + text + "</code>"
  end

  def pre(text)
    "<pre>" + text + "</pre>"
  end

  def a(href, text)
    "<a href=\"" + href + "\">" + text + "</a>"
  end

  def ul(items)
    out = "<ul>"
    for item in items
      out = out + "<li>" + item + "</li>"
    end
    out + "</ul>"
  end

  def html(title, body)
    "<html><head><title>" + title + " - sinatra049</title><style>" + %CSS + "</style></head><body>" + body + "<div class=\"footer\"><a href=\"https://github.com/khasinski/sinatra049\">sinatra049</a> / Ruby 0.49 (18 Jul 1994)</div></body></html>"
  end

  def nav(links)
    out = "<nav>"
    for link in links
      out = out + link + " "
    end
    out + "</nav>"
  end
end
