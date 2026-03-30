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

class Sinatra049
  def Sinatra049.new(port)
    super.init(port)
  end

  def init(port)
    @port = port
    @route_methods  = []
    @route_patterns = []
    @route_handlers = []
    @route_params   = []
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
    param_names = []
    tmp = "" + path
    while tmp =~ /:([a-z_]+)/
      param_names.push($1)
      tmp.sub(":([a-z_]+)", "DONE")
    end

    regex_str = "" + path
    regex_str.gsub(":([a-z_]+)", "([^/]+)")
    regex_str = "^" + regex_str + "$"
    regex_str.gsub("/", "\\/")

    @route_methods[@route_count]  = method
    @route_patterns[@route_count] = regex_str
    @route_handlers[@route_count] = handler
    @route_params[@route_count]   = param_names
    @route_count = @route_count + 1
  end

  # --- Request state ---

  def params(key)
    @params[key]
  end

  # --- Route matching ---

  def @match_route(method, path)
    i = 0
    while i < @route_count
      if @route_methods[i] == method
        pattern = @route_patterns[i]
        if eval("path =~ /" + pattern + "/")
          @params = {}
          names = @route_params[i]
          captures = []
          if $1 then captures.push($1) end
          if $2 then captures.push($2) end
          if $3 then captures.push($3) end
          if $4 then captures.push($4) end
          if $5 then captures.push($5) end
          j = 0
          while j < names.length
            @params[names[j]] = captures[j]
            j = j + 1
          end
          return @route_handlers[i]
        end
      end
      i = i + 1
    end
    return nil
  end

  # --- HTTP plumbing ---

  def @send_response(client, status, body)
    client.write("HTTP/1.0 " + status + %CRLF)
    client.write("Content-Type: text/html" + %CRLF)
    client.write("Content-Length: " + body.length.to_s + %CRLF)
    client.write("Connection: close" + %CRLF)
    client.write(%CRLF)
    client.write(body)
  end

  # --- Server ---

  def run
    printf("\n  sinatra049 has taken the stage on port %d\n\n", @port)
    server = TCPserver.open(@port)

    protect
      while %TRUE
        ns = select([server])
        if ns.is_nil then continue end
        client = ns[0][0].accept

        protect
          line = client.gets
          if line
            line.chop
            parts = line.split(" ")
            method = parts[0]
            path   = parts[1]

            printf("  %s %s\n", method, path)

            # Consume headers
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
          client.close
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
    "<html>" + %CRLF +
    "<head><title>" + title + " - sinatra049</title>" +
    "<style>" +
    "body{font-family:Georgia,serif;max-width:660px;margin:40px auto;padding:0 20px;color:#222;line-height:1.6}" +
    "h1{color:#c41;border-bottom:2px solid #c41;padding-bottom:8px}" +
    "h2{color:#333}" +
    "a{color:#c41}" +
    "code{background:#f4f4f4;padding:2px 6px;font-size:90%}" +
    "pre{background:#f4f4f4;padding:12px;overflow-x:auto}" +
    "nav{margin:20px 0}" +
    "nav a{margin-right:16px}" +
    ".footer{margin-top:40px;padding-top:12px;border-top:1px solid #ddd;color:#999;font-size:85%}" +
    "</style></head>" + %CRLF +
    "<body>" + body + %CRLF +
    "<div class=\"footer\">sinatra049 / Ruby 0.49 (18 Jul 1994)</div>" +
    "</body></html>" + %CRLF
  end

  def nav(links)
    out = "<nav>"
    for link in links
      out = out + link + " "
    end
    out + "</nav>"
  end
end
