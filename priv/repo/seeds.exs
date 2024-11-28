# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Chat.Repo.insert!(%Chat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Chat.Repo.insert!(%Chat.Rooms.Room{url_id: "demo", lang1: "English", lang2: "Spanish"})
