# app.rb - Example Sinatra-style app on Ruby 0.49
#
# Run: ruby-0.49 app.rb

load("sinatra049.rb")

# --- Routes ---

get("/",              "index")
get("/about",         "about")
get("/hello/:name",   "hello")
get("/users/:id",     "show_user")

# --- Handlers ---

def index()
  links = [a("/about", "About"), a("/hello/matz", "Say hello to Matz"), a("/hello/world", "Say hello to World"), a("/users/42", "User #42")]
  body = h1("Welcome!") + p("A Sinatra-style web app running on Ruby 0.49 from 1994.") + ul(links)
  html("Home", body)
end

def about()
  body = h1("About sinatra049") + p("This is a Sinatra-inspired DSL for Ruby 0.49.") + p("Ruby 0.49 was released on 18 July 1994 by Yukihiro Matsumoto.") + p("It has no blocks, no classes (well, barely), no require - but it has TCPserver!") + p(a("/", "Back home"))
  html("About", body)
end

def hello()
  name = params("name")
  body = h1("Hello, " + name + "!") + p("Greetings from Ruby 0.49.") + p(a("/", "Back home"))
  html("Hello", body)
end

def show_user()
  id = params("id")
  body = h1("User Profile") + p("User ID: " + id) + p("This user was loaded from a route with :id parameter.") + p(a("/", "Back home"))
  html("User " + id, body)
end

# --- Start ---

run(8049)
