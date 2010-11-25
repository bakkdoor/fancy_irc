require: "fancy_irc.fy"

echo_bot = FancyIRC Client new: {
  configuration: {
    nickname: "echo_bot"
    server: "irc.freenode.net"
    port: 6667
    channels: ["#fancy_test"]
  }

  on: 'channel pattern: /.*/ do: |msg| {x
    msg reply: $ msg author ++ " wrote: " ++ (msg text)
  }
}

echo_bot connect
echo_bot run