FROM elixir:1.14

RUN apt update -y \
    && apt install -y \
      inotify-tools

RUN mix local.rebar --force \
    && mix local.hex --force

COPY mix.exs /usr/src/app/
COPY mix.lock /usr/src/app/
WORKDIR /usr/src/app
RUN mix do deps.get, deps.compile

COPY . /usr/src/app
RUN mix compile

CMD ["iex", "-S", "mix"]
