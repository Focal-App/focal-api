# FocalApi

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

#### Dropping the Entire FocalAPI Database
```
mix ecto.drop --repo FocalApi.Repo
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
```

#### Dropping the Clients Table
```
mix ecto.rollback
mix ecto.migrate
mix run priv/repo/seeds.exs
```