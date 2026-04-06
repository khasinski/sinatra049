# app.rb - sinatra049 demo
# Run: ruby-0.49 app.rb

load("sinatra049.rb")

class MyApp : Sinatra049
  def MyApp.new(port)
    super.init(port)
  end

  def index
    body = h1("sinatra049") +
      p("A Sinatra-style framework on " + strong("Ruby 0.49") + " from July 1994.") +
      p(a("/about", "About") + " | " + a("/hello/matz", "Hello Matz") + " | " + a("/users/42", "User 42"))
    html("Home", body)
  end

  def about
    body = h1("About") +
      p("Matz started Ruby in Feb 1993. Version 0.49 came out 18 Jul 1994.") +
      p("Built with: classes, " + code("apply()") + ", " + code("protect/ensure") + ", " + code("select()") + ", " + code("TCPserver") + ".") +
      p(a("/", "Home"))
    html("About", body)
  end

  def hello
    name = params("name")
    body = h1("Hello, " + name + "!") +
      p(code(":name") + " = " + strong(name)) +
      p(a("/hello/world", "World") + " | " + a("/hello/ruby", "Ruby") + " | " + a("/", "Home"))
    html("Hello " + name, body)
  end

  def show_user
    id = params("id")
    body = h1("User #" + id) +
      p(code("params(\"id\")") + " = " + strong(id)) +
      p(a("/users/1", "#1") + " | " + a("/users/1994", "#1994") + " | " + a("/", "Home"))
    html("User " + id, body)
  end
end

app = MyApp.new(8049)
app.get("/", "index")
app.get("/about", "about")
app.get("/users/:id", "show_user")
app.get("/hello/:name", "hello")
app.run()
