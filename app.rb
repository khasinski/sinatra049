# app.rb - sinatra049 demo
# Run: ruby-0.49 app.rb

load("sinatra049.rb")

class MyApp : Sinatra049
  def MyApp.new(port)
    super.init(port)
  end

  def index
    body = h1("sinatra049") +
      p("This page is being served by " + strong("Ruby 0.49") + " -- the oldest surviving version of Ruby, released by Yukihiro " + em("Matz") + " Matsumoto on 18 July 1994.") +
      p("sinatra049 is a small Sinatra-style web framework built entirely within the constraints of this 30-year-old language. No modern Ruby, no C extensions, no cheating -- just " + code("TCPserver.open()") + ", classes with " + code(":") + " inheritance, and " + code("apply()") + " for dispatch.") +
      h2("Try it") +
      p(a("/hello/matz", "Hello Matz") + " | " + a("/hello/world", "Hello World") + " | " + a("/users/42", "User 42") + " | " + a("/users/1994", "User 1994") + " | " + a("/about", "About")) +
      h2("Links") +
      p(a("https://github.com/khasinski/sinatra049", "sinatra049 on GitHub") + " -- the framework source code") +
      p(a("https://github.com/sampersand/ruby-0.49", "sampersand/ruby-0.49") + " -- Ruby 0.49 source, examples, and syntax reference") +
      p(a("https://rubygems.org/gems/ancient_ruby", "ancient_ruby gem") + " -- portable Ruby 0.49 binary you can install today") +
      h2("Thanks") +
      p("To " + strong("Matz") + " for creating Ruby in 1993 and sharing it with the world. And to " + strong("sampersand") + " for preserving Ruby 0.49, documenting its quirks, and building the Cosmopolitan binary that makes this possible.")
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
