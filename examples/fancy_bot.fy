require: "fancy_irc"

require("open-uri")
require("uri")
require("open3")
require("timeout")
require("net/http")
require("date")

bot = FancyIRC Client new: {
  configuration: {
    nickname: "fancy_bot"
    server: "irc.freenode.net"
    port: 6667
    channels: ["#fancy"]
  }

  # define helper methods:
  helpers: {
    def log_message: msg {
      self logfile println: "[#{msg author}] #{msg author}: #{msg message}"
      self logfile flush
    }

    def logfile {
      unless: @current_date do: {
        @current_date = Date today()
      }
      unless: @logfile do: {
        File open(LOGDIR ++ "/#fancy_#" ++ (Date today()) ++ ".txt", "a")
      }
      if: (@current_date != (Date today())) then: {
        @logfile close()
        @current_date = Date today()
        @logfile = File open(LOGDIR ++ "/#fancy_#" ++ (Date today()) ++ ".txt", "a")
      }
      @logfile
    }

    def shutdown {
      @logfile close()
    }

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
  on: 'channel pattern: /.*/ do: |msg| {
    # log all channel messages
    log_message: msg
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

bot connect
bot run
