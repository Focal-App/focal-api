# FocalApi
Focal API is a Phoenix/Elixir API that pairs with [Focal App](https://github.com/Focal-App/focal). 

## Local Development Setup
To start your Phoenix server:
1. Clone the project `git clone https://github.com/Focal-App/focal-api.git`
2. Navigate to project `cd focal-api` 
3. Install dependencies with `mix deps.get`
4. Create and migrate your database with `mix ecto.setup`
5. Setup Environment Variables. Create a .env file in your project folder root and add the following
```
export GOOGLE_CLIENT_ID="Get from Teammate"
export GOOGLE_CLIENT_SECRET="Get from Teammate"
export CLIENT_HOST=http://localhost:<client_port>
```
6. Start Phoenix endpoint
```
source .env
mix phx.server
```
7. Run tests
```
source .env
mix text
```

8. Optional - See all routes `mix phx.routes`. Note that all routes are authenticated except for `/api/users`, which I purposely left public for demonstration purposes.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Testing Routes with Postman
Running routes with Postman is easiest on the local development.
1. On your browser, open your developer console to the network tab
2. Run the local frontend application and log in with google
3. Move around the site until you see a cookie header pop up in the network tab
![image](https://i.imgur.com/0HPu0dl.png)
4. Copy this into your Postman Request, COOKIE header
![image](https://i.imgur.com/hAbToTd.png)
5. Proceed with any requests

## Routes
#### Clients
- [`GET` `/api/users/:user_uuid/clients`](https://github.com/Focal-App/focal-api/wiki/API/_edit#get-apiusersuser_uuidclients)
- [`GET` `/api/clients/:client_uuid/data`](https://github.com/Focal-App/focal-api/wiki/API#get-apiclientsclient_uuiddata)
- [`POST` `/api/clients`](https://github.com/Focal-App/focal-api/wiki/API#post-apiclients)
- [`PUT` `/api/clients/:client_uuid`](https://github.com/Focal-App/focal-api/wiki/API#put-apiclientsclient_uuid)
- [`DELETE` `/api/clients/:client_uuid`](https://github.com/Focal-App/focal-api/wiki/API#delete-apiclientsclient_uuid)

#### Packages
- [`GET` `/api/packages/:package_uuid`](https://github.com/Focal-App/focal-api/wiki/API#get-apipackagespackage_uuid)
- [`POST` `/api/clients/:client_uuid/packages`](https://github.com/Focal-App/focal-api/wiki/API#post-apiclientsclient_uuidpackages)
- [`PUT` `/api/packages/:package_uuid`](https://github.com/Focal-App/focal-api/wiki/API#put-apipackagespackage_uuid)
- [`DELETE` `/api/packages/:package_uuid`](https://github.com/Focal-App/focal-api/wiki/API#delete-apipackagespackage_uuid)

#### Events
- [`GET` `/api/events/:event_uuid`](https://github.com/Focal-App/focal-api/wiki/API#get-apieventsevent_uuid)
- [`POST` `/api/packages/:package_uuid/events`](https://github.com/Focal-App/focal-api/wiki/API#post-apipackagespackage_uuidevents)
- [`PUT` `/api/events/:event_uuid`](https://github.com/Focal-App/focal-api/wiki/API#put-apieventsevent_uuid)
- [`DELETE` `/api/events/:event_uuid`](https://github.com/Focal-App/focal-api/wiki/API#delete-apieventsevent_uuid)

#### Workflows
- [`GET` `/api/clients/:client_uuid/workflows`](https://github.com/Focal-App/focal-api/wiki/API#get-apiclientsclient_uuidworkflows)

#### Tasks
- [`PUT` `/api/tasks/:task_uuid`](https://github.com/Focal-App/focal-api/wiki/API#put-apitaskstask_uuid)


## Troubleshooting 
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
#### Updating a schema triggers errors
1. Update schema and create new migration record
2. Update any views related to the schema
3. Drop Test database 
4. Run migration
5. Run all tests

Migrations, when run, cannot be updated. If you need to make any updates to the 
migration changes you just made, you will need to either delete the migration 
file and create a new one with all correct changes. Or, create a new migration 
file specifying the changes you missed. 