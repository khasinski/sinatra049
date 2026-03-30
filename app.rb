# app.rb - Example app built on sinatra049
#
# Run: ruby-0.49 app.rb

load("sinatra049.rb")

class MyApp : Sinatra049
  def MyApp.new(port)
    super.init(port)
  end

  # --- Handlers ---

  def index
    links = nav([a("/", "Home"), a("/about", "About"), a("/syntax", "Syntax"), a("/hello/matz", "Hello Matz")])
    body = h1("sinatra049") +
      p("A Sinatra-style web framework running on " + strong("Ruby 0.49") + " from 18 July 1994.") +
      p("This is the oldest surviving version of Ruby, predating blocks with " + code("{}") + ", " + code("require") + ", and even " + code("puts") + ". Yet here it is, serving web pages.") +
      links
    html("Home", body)
  end

  def about
    items = []
    items.push("Routes with named parameters via " + code(":name"))
    items.push("Handler dispatch via " + code("apply()") + " -- the 0.49 ancestor of " + code("send()"))
    items.push("Private methods with " + code("@") + " prefix instead of " + code("private"))
    items.push("Error handling with " + code("protect/resque/ensure"))
    items.push("Blocks via " + code("do func() using var; ... end"))
    items.push("Connection handling via " + code("select()"))
    items.push("TCP server via built-in " + code("TCPserver.open()"))
    body = h1("About") +
      p("Yukihiro Matsumoto started Ruby in February 1993. Version 0.49, released on 18 July 1994, is the oldest version whose source code survives.") +
      p("This framework is built entirely within the constraints of Ruby 0.49:") +
      ul(items) +
      nav([a("/", "Home")])
    html("About", body)
  end

  def syntax
    body = h1("Ruby 0.49 Syntax") +
      p("A quick tour of what Ruby looked like in 1994.") +
      h2("Constants") +
      pre("%PORT = 8049        # constants use % prefix\n%TRUE              # instead of true") +
      h2("Blocks") +
      pre("do my_list.each using item\n  item.print\nend") +
      h2("Classes") +
      pre("class Dog : Animal  # inheritance with : not <\n  def Dog.new(name)\n    super.init(name)\n  end\n\n  def init(name)      # not initialize\n    @name = name\n    self              # must return self\n  end\n\n  def @secret         # @ = private method\n    \"shhh\"\n  end\nend") +
      h2("Error handling") +
      pre("protect\n  risky_thing()\nresque\n  printf(\"error: %s\\n\", $!)\nensure\n  cleanup()\nend protect") +
      h2("Other differences") +
      ul(["No " + code("{}") + " blocks -- use " + code("do/using/end"), code("iterator_p()") + " not " + code("block_given?"), code("continue") + " not " + code("next"), code("apply(\"method\")") + " not " + code("send(:method)"), code("\\foo") + " for symbols not " + code(":foo"), code("$ARGV") + " not " + code("ARGV")]) +
      nav([a("/", "Home")])
    html("Syntax", body)
  end

  def hello
    name = params("name")
    body = h1("Hello, " + name + "!") +
      p("Routed from " + code("get(\"/hello/:name\", \"hello\")") + " with " + code(":name") + " = " + strong(name) + ".") +
      p("Try changing the name in the URL.") +
      nav([a("/", "Home"), a("/hello/matz", "Matz"), a("/hello/world", "World"), a("/hello/ruby", "Ruby")])
    html("Hello " + name, body)
  end

  def show_user
    id = params("id")
    body = h1("User #" + id) +
      p("Loaded via route " + code("/users/:id") + " with " + code("params(\"id\")") + " = " + strong(id) + ".") +
      nav([a("/", "Home"), a("/users/1", "#1"), a("/users/42", "#42"), a("/users/1994", "#1994")])
    html("User " + id, body)
  end
end

# --- Wire up routes and start ---

app = MyApp.new(8049)

app.get("/",              "index")
app.get("/about",         "about")
app.get("/syntax",        "syntax")
app.get("/hello/:name",   "hello")
app.get("/users/:id",     "show_user")

app.run()
