# society simulator 2021

# TODO:

# add tailwind

# show citizen count on homepage & show which ones are urs

# way to remove pollution with certain buildings

# pollution listeners

# maybe add global limits for amount of cities… artificial scarcity?
# one per email, in that case? no redos, baybeee
# is this just as simple as changing has_many to has_one in user.ex?
# 10000 possible cities, 2500 in each environment

# add "fun" and "health" calculations to check for for city (like energy)

# add upgrading system for buildables (like a park can have a soccer field, etc) [x]
# make city_calculator check the upgrades when calculating and make changes []
# upgrades are per-buildable, so they can't effect things like price, etc, but only the output

# utilities for

# implement regional differences (check region in generation functions) (done for energy, should do for health & fun)

# add hospitals, doctor offices and other health impacts stats (factory work? parks?)
# add grocery stores? farmers markets? farms?

# figure out how to release prod version




### nice to have —————————————————————————————————————
# add general "policy" options that aren't buildings
# (speed limits — increase sprawl, increase health)
# (bike lanes?)

# error handling/routing for wrong urls — route back to home

# clean up preload situation across the board

# clean up calculate_ functions to only enum through buildables once?
# i think i can do this by just having different preliminary functions before enumerating through the main buildable list
# and maybe I have to store whether they're enabled or not in that enum

# figure out why moving logs make tax logs not appear?
# figure out why taxer stops sometimes

# function to loan/give other cities money?

# eventually could write calculate functions with Stream instead of Enum to speed up

# probably should move treasury out of details and reserve details just for buildables

# — adjust auth so you can only control your own cities (done on front-end)
#   — might need to do this on the backend with a constraint or something in case haxkorz
#   — (although maybe you just couldn't send to the submit action from console?)

# — adjust signin/session time limit (maybe done with persistent session plugin?)



# TYPES:
# https://elixirforum.com/t/struct-vs-type-t/32124

# TIMESTAMPS:
# http://www.creativedeletion.com/2019/06/17/utc-timestamps-in-ecto.html


# ——————————————————————————————————————————————————————————————
# phx.gen.context in terminal to generate different contexts;

# auth context with "user" struct

# "city" context, that belongs to user?
#  - type, atom (forest, ocean, mountain, etc) only one type
#  - title, string. only one title
#  - owner, User struct. belongs to. only one owner
#  - log, of changes, of list?
#  - citizens, of type list of structs Citizen?[]

# "citizen" context, that belongs to city?

# basically, anything that can "have" something else belong to it needs an _id field.
# This is guessed automatically as the foreign key when outlining that stuff

# :rand.uniform() random float between 0 and 1

mix phx.gen.context City Town cities \
  title:string \
  user_id:references:auth_users \
  region:string

mix phx.gen.context City Citizens citizens \
  name:string \
  money:integer \
  city:references:cities \

mix phx.gen.context City Details details \
  roads:integer \
  schools:integer \
  single_family_homes:integer \
  city:references:cities

# so after running all these, they get migration files in /priv/repo/migrations

# run iex for the project
iex -S mix phx.server

# to adjust database:
# first, make an ecto migration
mix ecto.gen.migration _name

# then in /priv/repo/migrations it'll make a file you can edit
mix ecto.migrate
# or
mix ecto.rollback # to undo
# or
mix ecto.reset # to reset the whole db

# to run the seeds:
mix run priv/repo/seeds.exs


# fake user:
# hi@test.com
# barron
# pw: barronbarron


————————————————————————————————————————————————————————
OTP stuff

{:ok, mover} = MayorGame.Mover.start_link(10)

ok so in the rumble example, the *client* starts a task. it does it async
maybe that makes sense in this case? but idk

# ok this worked when trying to preload stuff
Repo.all(MayorGame.City.Citizens) |> Repo.preload([:town])

# get stuff from a struct with the key atom:
Map.get(city.detail, building_type)
