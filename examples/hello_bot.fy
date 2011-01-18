require: "fancy_irc"

bot = FancyIRC Client new: {
  configuration: {
    nickname: "hello_bot"
    server: "irc.freenode.net"
    port: 6667
    channels: ["#fancy"]
  }

  on: 'channel pattern: /^hello/ do: |msg| {
    msg reply: "Hello to you too, #{msg author}!"
  }
}

"starting bot" println

bot connect
bot message: "Hello, Fancy team. This is a fancy-written irc client =)" channel: "#fancy"
bot run
