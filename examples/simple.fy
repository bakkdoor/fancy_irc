require: "fancy_irc.fy"

require("open-uri")
require("uri")

bot = FancyIRC Client new: {
  configuration: {
    nickname: "fancy_irc"
    server: "irc.freenode.net"
    port: 6667
    channels: ["#fancy"]
  }

  # define some helper methods
  helpers: {
    def shorten: url {
      try {
        url = open("http://tinyurl.com/api-create.php?url=" ++ (URI escape(url))) read()
        if: (url == "Error") then: {
          return nil
        } else: {
         return url
        }
      } catch OpenURI::HTTPError {
        nil
      }
    }
  }

  on: 'channel pattern: /^hello/ do: |msg| {
    msg reply: $ "Hello to you too, " ++ (msg author) ++ "!"
  }

  on: 'channel pattern: /^!shorten (.+)$/ do: |msg, url| {
    urls = URI extract(url, "http")
    unless: (urls empty?) do: {
      short_urls = urls map: |url| { shorten: url } . compact
      unless: (short_urls empty?) do: {
        msg reply: $ short_urls join: ", "
      }
    }
  }
}

"starting bot" println

bot connect
bot message: "Hello, Fancy team. This is a fancy-written irc client =)" channel: "#fancy"
bot run