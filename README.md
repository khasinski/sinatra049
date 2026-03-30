# sinatra049

A Sinatra-style web framework for [Ruby 0.49](https://github.com/ruby/ruby/tree/v0_49) (18 July 1994) -- the oldest surviving version of Ruby.

```ruby
load("sinatra049.rb")

get("/",            "index")
get("/hello/:name", "hello")

def index()
  html("Home", h1("Hello!") + p("Welcome to 1994."))
end

def hello()
  html("Hi", h1("Hello, " + params("name") + "!"))
end

run(8049)
```

```
$ ruby-0.49 app.rb

  sinatra049 has taken the stage on port 8049
```

## Prerequisites

Install the [ancient_ruby](https://rubygems.org/gems/ancient_ruby) gem to get the `ruby-0.49` binary (a Cosmopolitan universal binary that runs on macOS, Linux, Windows, and FreeBSD):

```
gem install ancient_ruby
```

## Usage

1. Create your app file (see `app.rb` for a full example)
2. Load the framework: `load("sinatra049.rb")`
3. Register routes with `get()` / `post()`
4. Define handler functions that return HTML strings
5. Call `run(port)` to start the server

## API

### Routing

```ruby
get("/path",        "handler_name")
get("/users/:id",   "show_user")
post("/submit",     "handle_form")
```

Routes map an HTTP method + path to a handler function name. Path segments prefixed with `:` become named parameters.

Handlers are regular `def` functions that return an HTML string. They are called by name via `eval` (Ruby 0.49 has no blocks or procs).

### Parameters

```ruby
def show_user()
  id = params("id")
  html("User", h1("User #" + id))
end
```

Up to 5 named parameters per route are supported (limited by `$1`..`$5` capture groups).

### HTML helpers

| Helper | Output |
|---|---|
| `html(title, body)` | Full HTML page with `<head>`, inline CSS, and footer |
| `h1(text)` | `<h1>text</h1>` |
| `h2(text)` | `<h2>text</h2>` |
| `p(text)` | `<p>text</p>` |
| `a(href, text)` | `<a href="href">text</a>` |
| `ul(items_array)` | `<ul><li>...</li></ul>` from an array of strings |

### 404 handling

Any request that doesn't match a registered route gets an automatic 404 page.

## Ruby 0.49 quirks

This framework works around several limitations of Ruby 0.49:

- **No blocks/procs/lambdas.** Handlers are function names dispatched through `eval`.
- **Constants use `%`** instead of uppercase (`%PORT`, not `PORT`).
- **`sub`/`gsub` mutate in place.** Strings must be copied with `"" + str` to avoid side effects.
- **`while 1`** instead of `while true` (`TRUE` is `%TRUE` in 0.49 and doesn't work bare).
- **No `require`, only `load`.** And `load` needs parentheses or `/` gets parsed as regex.
- **`TCPserver.open(port)`** is the built-in TCP server -- no `require 'socket'` needed.
- **`.print`** on any object instead of `puts`.

## Files

| File | Description |
|---|---|
| `sinatra049.rb` | The framework (load this in your app) |
| `app.rb` | Example application with 4 routes |

## License

MIT
