# GraphiteAggregator

Small graphite aggregator to push data each interval via UDP to graphite

## Installation

The package can be installed by adding `graphite_aggregator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:graphite_aggregator, "~> 0.0.1"}
  ]
end
```

## Configuration

Add process to be started as child in application.ex
```elixir
children = [
	GraphiteAggregator
]
Supervisor.start_link(children, [])
```

Configuration to add to config.exs

```elixir
config :graphite_aggregator,
  host: "graphite-host",
  port: 2025,
  prefix: "company.department.team.service.",
  interval: 60
```

## Usage

Send metric to Graphite (default value is 1, default timestamp is now)

```elixir
GraphiteAggregator.metric("key")

GraphiteAggregator.metric("key", 10)
```
