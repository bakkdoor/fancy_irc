require: "fancy_irc"

require("open-uri")
require("uri")
require("open3")
require("timeout")
require("net/http")

FANCY_DIR = ARGV[0]
FANCY_CMD = "#{FANCY_DIR}/bin/fancy -I #{FANCY_DIR}"
LOGDIR = ARGV[1] || "."
API_DOC_DESTDIR = ARGV[2]

class Seen {
  def initialize: @message {
  }

  def to_s {
    "[#{@message timestamp asctime()}] #{@message author} was seen in #{@message channel} saying #{@message text}"
  }
}

bot = FancyIRC Client new: {
  configuration: {
    nickname: "fancy_bot2"
    server: "irc.freenode.net"
    port: 6667
    channels: ["#fancy_test"]
  }

  @seen_users = <[]>
  @start_time = Time now

  # define helper methods:
  helpers: {
    def log_message: msg {
      time = Time now
      logfile println: "[#{time}] #{msg author}: #{msg text}"
      logfile flush
    }

    def logfile {
      @current_date = @current_date || { Date today }
      @logfile = @logfile || { File open: "#{LOGDIR}/#fancy_#{Date.today}.txt" modes: ['append] }
      today = Date today
      if: (@current_date != today) then: {
        @logfile close
        @current_date = today
        @logfile = File open: "#{LOGDIR}/#fancy_#{today}.txt" modes: ['append]
      }
      @logfile
    }

    def shutdown {
      "Shutting down bot!" println
      { @logfile close } if: @logfile
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
    @seen_users[msg author]: $ Seen new: msg
  }

  on: 'channel pattern: /^!seen (.+)/ do: |msg, nick| {
    match nick {
      case @config nickname -> msg reply: "That's me!"
      case msg author -> msg reply: "That's you!"
      case _ ->
        if: (@seen_users[nick]) then: |seen| {
          msg reply: $ seen to_s
        } else: {
          msg reply: "Sorry, I haven't seen #{nick}"
        }
    }
  }

  on: 'channel pattern: /^!uptime/ do: |msg| {
    time_diff = Time at(Time now - @start_time) gmtime() strftime("%R:%S")
    text = "I'm running since #{@start_time}, which is #{time_diff}"
    msg reply: text
  }

  on: 'channel pattern: /^!(info|help)$/ do: |msg, _| {
    msg reply: "This is FancyBot v0.3 running @ irc.fancy-lang.org"
    msg reply: "Possible commands are: !seen <nick>, !uptime, !shorten <url> [<urls>], !info, !help"
  }

  on: 'channel pattern: /^!(info|help) (.+)$/ do: |msg, _, command_name| {
    match command_name {
      case "!seen" ->
        msg reply: "!seen <nickname> : Displays information on when <nickname> was last seen."
      case "!uptime" ->
        msg reply: "!uptime : Displays uptime information for FancyBot."
      case "!shorten" ->
        msg reply: "!shorten <url> [<urls>] : Displays a shorted version of any given amount of urls (using tinyurl.com)."
      case /!(info|help)/ ->
        msg reply: "!info/!help [<command>]: Displays help text for <command>. If <command> is ommitted, displays general help text."
      # case "!" ->
      #   msg reply: "! <code> : Evaluates the <code> given (expects it to be Fancy code) and displays any output from evaluation."
      #   msg reply: "! <code> : Maximum timeout for any computation is 5 seconds and only up to 5 lines will be displayed here (seperated by ';' instead of a newline)."
      case _ ->
        msg reply: "Unknown command: #{command_name}."
    }
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

trap("INT") {
  bot shutdown
  Console newline
  System exit
}

bot connect
bot run
