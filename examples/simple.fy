bot = FancyIRC Client new: {
  configuration: {
    nickname: "fancy_irc"
    server: "irc.freenode.net"
    port: 6667
    channels: ["#fancy"]
  }

  on: 'channel pattern: /^hello/ do: |msg| {
    msg reply: $ "Hello to you too, " ++ (msg author) ++ "?"
  }
}

bot connect
bot["#fancy"] send: "Hello, Fancy team. This is a fancy-written irc client =)"
bot run