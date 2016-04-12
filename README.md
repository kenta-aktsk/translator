# Translator

Translator is a simple model translation/globalization/localization library for Elixir, inspired by [globalize](https://github.com/globalize/globalize).

## Dependencies

You need to use ecto 2.0 or higher.

## Installation

Add translator to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:translator, github: "kenta-aktsk/translator"}]
end
```

Ensure translator is started before your application:

```elixir
def application do
  [applications: [:translator]]
end
```

## Basic Usage

Assume that you have user model like below:

```elixir
defmodule MyApp.User do
  use MyApp.Web, :model

  schema "users" do
    field :email, :string
    field :name, :string
    field :profile, :string

    timestamps
  end

  @required_fields ~w(email name)a
  @optional_fields ~w(profile)a

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
```

And assume that you have user record in your db table like below:

```elixir
%{id: 1, email: "user01@example.com", name: "Kenta Katsumata", profile: "living in Tokyo"}
```

First of all, if you want to translate `name` and `profile` fields, define migration file for translation table like below:

```elixir
defmodule MyApp.Repo.Migrations.CreateUserTranslation do
  use Ecto.Migration

  def change do
    create table(:user_translations) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :locale, :string, null: false
      add :name, :string, null: false
      add :profile, :text

      timestamps
    end

    create index(:user_translations, [:user_id, :locale], unique: true)
  end
end
```

Next, execute migration.

```
mix ecto.migrate
```

Next, define UserTranslation model like below:

```elixir
defmodule MyApp.UserTranslation do
  use MyApp.Web, :model
  use Translator.TranslationModel,
    schema: "user_translations", belongs_to: MyApp.User, required_fields: [:name], optional_fields: [:profile]
end
```

Next, define `has_one` association and preload query function in User model. (function name is up to you.)

```elixir
defmodule MyApp.User do
  alias MyApp.UserTranslation
  ...
  schema "users" do
    ...
    has_one :translation, UserTranslation
    ...
  end
  def preload_all(query, locale) do
    from query, preload: [translation: ^UserTranslation.translation_query(locale)]
  end
end
```

Next, insert some translation record like below:

```
INSERT INTO user_translations (user_id, locale, name, profile) VALUES (1, "en", "Kenta Katsumata", "living in Tokyo");
INSERT INTO user_translations (user_id, locale, name, profile) VALUES (1, "ja", "勝又健太", "東京在住");
```

Now you can get associated translation record like below:

```elixir
alias MediaSample.{Repo, User}
user = User |> User.preload_all("ja") |> Repo.get!(1)
user.translation
# => %{user_id: 1, name: "勝又健太", profile: "東京在住"}

```

## Insert, Update

You can use `insert_or_update/4` function for inserting or updating translation record like below:

```elixir
# create action in user controller 
def create(conn, %{"user" => user_params}) do
  changeset = User.changeset(%User{}, user_params)

  Repo.transaction fn ->
    user = Repo.insert!(changeset)
    UserTranslation.insert_or_update(Repo, user, user_params, "ja")
  end
end

# update action in user controller 
def update(conn, %{"id" => id, "user" => user_params}) do
  user = Repo.get!(User, id)
  changeset = User.changeset(user, user_params)

  Repo.transaction fn ->
    user = Repo.update!(changeset)
    UserTranslation.insert_or_update(Repo, user, user_params, "ja")
  end
end
```

It is up to you what locale to pass.

## View helper

You can use view helper to get translated field like below:

```elixir
# web.ex
def view do
  quote do
    ...
    import Translator.TranslationHelpers
  end
end

# templates/user/show.html.eex
<li>
  <%= translate(@user, :name) %>
</li>

# templates/user/form.html.eex
<%= text_input :user, :name, value: translate(@changeset, @user, :name), class: "form-control" %>
```

## Example

You can check some example at my phoenix example repository [media_sample](https://github.com/kenta-aktsk/media_sample).
