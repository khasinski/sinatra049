# sinatra049

A Sinatra-style web framework for [Ruby 0.49](https://github.com/ruby/ruby/tree/v0_49) (18 July 1994) -- the oldest surviving version of Ruby.

```ruby
load("sinatra049.rb")

class MyApp : Sinatra049
  def MyApp.new(port)
    super.init(port)
  end

  def index
    html("Home", h1("Hello!") + p("Welcome to 1994."))
  end

  def hello
    html("Hi", h1("Hello, " + params("name") + "!"))
  end
end

app = MyApp.new(8049)
app.get("/",            "index")
app.get("/hello/:name", "hello")
app.run()
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
2. `load("sinatra049.rb")`
3. Subclass `Sinatra049` with your handlers
4. Register routes with `app.get()` / `app.post()`
5. Call `app.run()` to start the server

## API

### Routing

```ruby
app.get("/path",        "handler_name")
app.get("/users/:id",   "show_user")
app.post("/submit",     "handle_form")
```

Routes map an HTTP method + path to a handler method on your app class. Path segments prefixed with `:` become named parameters. Up to 5 named parameters per route (limited by `$1`..`$5` capture groups).

Handlers are dispatched via `apply()` -- the Ruby 0.49 ancestor of `send()`.

### Parameters

```ruby
def show_user
  id = params("id")
  html("User", h1("User #" + id))
end
```

### HTML helpers

| Helper | Output |
|---|---|
| `html(title, body)` | Full HTML page with `<head>`, inline CSS, and footer |
| `h1(text)`, `h2(text)` | Headings |
| `p(text)` | Paragraph |
| `a(href, text)` | Link |
| `strong(text)`, `em(text)`, `code(text)` | Inline formatting |
| `pre(text)` | Preformatted block |
| `ul(items_array)` | Unordered list from an array of strings |
| `nav(links_array)` | Navigation bar from an array of `a()` calls |

### 404 handling

Any request that doesn't match a registered route gets an automatic styled 404 page.

## Ruby 0.49 features used

The framework uses idiomatic Ruby 0.49 throughout:

- **Classes** with `:` inheritance (`class MyApp : Sinatra049`), `init` instead of `initialize`, and explicit `self` return.
- **Private methods** via `@` prefix (`def @match_route`, `def @send_response`) instead of `private`.
- **`apply("method")`** for dynamic dispatch instead of `send(:method)`.
- **`protect`/`ensure`** for connection cleanup instead of `begin`/`ensure`.
- **`select([server])`** for connection handling.
- **`while %TRUE`** -- `true` doesn't exist bare; `%TRUE` is the constant.
- **`for item in array`** -- the primary iteration construct (blocks use `do func() using var; ... end` but can't be stored as objects).
- **`TCPserver.open(port)`** -- built-in, no `require 'socket'` needed.
- **`printf()`** for formatted output instead of `puts`.
- **Constants** use `%` prefix (`%CRLF`, `%TRUE`).
- **`sub`/`gsub`** mutate in place; strings are copied with `"" + str`.

## Files

| File | Description |
|---|---|
| `sinatra049.rb` | The framework (load this in your app) |
| `app.rb` | Example application with 5 routes including a Ruby 0.49 syntax guide |

## See also

- [sampersand/ruby-0.49](https://github.com/sampersand/ruby-0.49) -- Ruby 0.49 source code, examples, and syntax reference
- [ancient_ruby gem](https://rubygems.org/gems/ancient_ruby) -- Cosmopolitan binary of Ruby 0.49

## License

MIT
