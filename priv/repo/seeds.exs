# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FocalApi.Repo.insert!(%FocalApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FocalApi.Clients.Client
alias FocalApi.Clients.Package
alias FocalApi.Accounts.User
alias FocalApi.Repo

user = %User{
  avatar: "avatar-image",
  email: "user@gmail.com",
  first_name: "First User",
  provider: "google",
  uuid: Ecto.UUID.generate(),
}
Repo.insert!(user)
user = Repo.get_by(User, uuid: user.uuid)


client = %Client{
  client_name: "Snow White",
  uuid: Ecto.UUID.generate(),
  user_id: user.id
}
Repo.insert!(client)
client = Repo.get_by(Client, uuid: client.uuid)

package = %Package{
  package_name: "Engagements",
  uuid: Ecto.UUID.generate(),
  client_id: client.id
}
Repo.insert!(package)
package = Repo.get_by(Package, uuid: package.uuid)
