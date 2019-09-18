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

#### Resetting the Test Database after a schema change
```
dropdb focal_api_test
mix ecto.migrate
```
#### Deploying to Heroku from CLI
```
git push heroku <branch_name>:master
```
#### Resetting Deployed Heroku Databases
```
heroku pg:info // get db_name from add-on field. 
heroku pg:reset DB_NAME
heroku run MIX_ENV=prod mix ecto.migrate
heroku run MIX_ENV=prod mix run priv/repo/seeds.exs
heroku restart
```

## Setting up Environment Variables + Starting Local Server
-  Create a .env file in your root and add the following
```
export GOOGLE_CLIENT_ID="Get from Teammate"
export GOOGLE_CLIENT_SECRET="Get from Teammate"
export CLIENT_HOST=http://localhost:<client_port>
```
- `source .env`
- `mix phx.server`

## Running Tests
- `source .env`
- `mix test`

## Updating a schema
1. Update schema and create new migration record
2. Update any views related to the schema
3. Drop Test database 
4. Run migration
5. Run all tests

Migrations, when run, cannot be updated. If you need to make any updates to the 
migration changes you just made, you will need to either delete the migration 
file and create a new one with all correct chanegs. Or, create a new migration 
file specifying the changes you missed. 

