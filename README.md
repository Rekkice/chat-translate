# Chat-translate
Real-time chat web app that enables seamless conversations between people who speak different languages. Chat-Translate automatically translates messages as they are sent, allowing for fluid multilingual communication. 

Live demo hosted at https://chat-translate.rekkice.dev

## Key Features
- Real-time translation of chat messages through an external API
- Easily join a chatroom just by scanning the QR code shown next to the chat, or by typing the human-friendly URL
- Easily create a chatroom, choosing 2 available languages that will be used to generate the translations
- Dynamically generated OpenGraph images, shown when sharing the URL in social media

## Technologies Used
- Elixir & Phoenix (for backend)
- Svelte (for frontend UI functionality)
- WebSockets (for real-time communication)
- GROQ API (for fast LLM generation)
- Tailwind CSS (for frontend styling)

## Usage

To start the app:

  * Run `devenv shell` to enter a shell with the necessary system dependencies
  * Run `devenv up -d` to start a Postgres instance in the background
  * Run `mix setup` to install and setup Elixir dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

![Screenshot_9-10-2024_192431_chat-translate rekkice dev](https://github.com/user-attachments/assets/51152d75-7b26-44e1-b042-f951ffe05f11)

## Future Features
- Support for more languages
