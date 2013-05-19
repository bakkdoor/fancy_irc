require: "fancy_irc"

bot = FancyIRC Client new: {
  configuration: {
    nickname: "hello_bot"
    server: "irc.freenode.net"
    port: 6667
    channels: ["#fancy"]
  }

  on: 'message pattern: /^hello/ do: |msg| {
    msg reply: "Hello to you too, #{msg author}!"
  }

  on: 'message do: |msg| {
    "Got message (channel or private): #{msg text}" println
  }

  on: 'channel do: |msg| {
    "Got channel message: #{msg text}" println
  }

  on: 'private do: |msg| {
    "Got private message: #{msg text}" println
  }
}

"starting bot" println

bot connect
bot broadcast: "Hello, everyone."
bot run
