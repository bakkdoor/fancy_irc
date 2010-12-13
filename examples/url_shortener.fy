require: "fancy_irc"

require("open-uri")
require("uri")

bot = FancyIRC Client new: {
  configuration: {
    nickname: "url_shortener"
    server: "irc.freenode.net"
    port: 6667
    channels: ["#fancy"]
  }

  # define helper methods:
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

  # message handlers:
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

bot connect
bot run