# Client

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:client, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/client](https://hexdocs.pm/client).

usage: 

curl -X POST http://localhost:8888/entries --data "key=k1&value=v1" | python -mjson.tool
curl -X POST "http://localhost:8888/entries?key=k1&value=v1" | python -mjson.tool
curl -X GET http://localhost:8888/entries/k1
curl -X DELETE http://localhost:8888/entries/k1
curl -X GET http://localhost:8888/entries?values_gt=v2


