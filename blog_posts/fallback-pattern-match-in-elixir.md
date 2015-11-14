Elixir: Metaprogramming A Default Pattern Matcher Function For GenEvent
2015-11-14

## TL;DR

Using [`@before_compile`](http://elixir-lang.org/docs/v1.0/elixir/Module.html) allows you to define a function which gets matched **after** any other functions in the module:

```elixir
defmodule MyCoolDefaultGenEventHandler do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
      use GenEvent
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_event(event, state) do
        Logger.info("Received unmatched event: #{inspect(event)}")
        {:ok, state}
      end
    end
  end
end

def MyEventHandler do
  use MyCoolDefaultGenEventHandler

  def handle_event(:something_specific, state) do
    Logger.info("Matched something_specific")
    {:ok, state}
  end
end
```

## The Problem I Was Trying To Solve

I was recently working on [a simple chat bot framework](https://github.com/DylanGriffith/bender) using Elixir. I wanted to make a simple API so that people could extend it by adding their own commands by creating modules and configuring the commands they want their bot to make available. To that end I decided I would use the `GenEvent` API as a means of dispatching commands to all possible command handlers. The idea was that you would create some modules that implemented the GenEvent interface and they would be registered and would pattern match the commands they were interested in matching. For example a simple example command was the echo command which in it's first cut looked like:

```elixir
defmodule Bender.Commands.Echo do
  use GenEvent

  def handle_event({{:command, "echo", message}, meta}, state) do
    respond(meta, message)
    {:ok, state}
  end
end
```

The important detail to note is it matches the command tuple `{:command, "echo", message}` and then the bot uses GenEvent to dipatch, for example, the message `@bender echo hello world` as `{:command, "echo", "hello world"}`. The simple thing about this API is that you can just use regular elixir pattern matching to describe the commands you are interested in. The one problem is that the default behaviour with `GenEvent` is that if the handler doesn't match the event in some function definition it then errors and is removed from the event handlers. In this case my `echo` command would crash if somebody tried to execute another command. Or more specifically in my case every command except the one being executed would crash when it received it's first command.

## The Solution: Use `@before_compile`

As I found out from asking in the elixir IRC channel there is a thing called [`@before_compile`](http://elixir-lang.org/docs/v1.0/elixir/Module.html) which allows you to add functions after all other function definitions in a module. This solved my problem as I could combine that with `use` to create a simple API for my event handlers that just ignored unmatched events. This ended up looking like:

Shared Behaviour:

```elixir
defmodule Bender.Command do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
      use GenEvent
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_event(_, state) do
        {:ok, state}
      end
    end
  end
end
```

Commands:

```elixir
defmodule Bender.Commands.Echo do
  use Bender.Command

  def handle_event({{:command, "echo", message}, meta}, parent) do
    respond(message, meta)
    {:ok, parent}
  end
end
```

I suspect there are likely other ways I could have solved this problem and probably ways that didn't make use of `GenEvent` but it seems like what I've got now is at least fairly simple to extend and `GenEvent` provides a really easy way to add all the modules as event handlers without having to implement my own registry. All the code for this bot framework is very concise as a consequence and I intend on trying to make it more flexible in future to support multiple chat services (eg. slack or IRC).
