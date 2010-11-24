class FancyIRC {
  class Client {
    def initialize: block {
      @handlers = <[]>
      block call_with_receiver: self
    }

    def configuration: conf_block {
      @config = Configuration new: conf_block
    }

    def connect {
      @irc = IRCSocket new(@config server, @config port, @config ssl)
      @irc connect()
      unless: (@irc connected?()) do: {
        "Could not connect to server!" raise!
      }

      @irc nick(@config nickname)
      @irc user(@config nickname, 0, "*", "fancy_irc_bot")
      { @irc pass(@config password) } if: $ @config password

      # join channels
      @config channels each: |c| {
        @irc join(c)
      }
    }

    def on: msg_type pattern: msg_pattern do: callback {
      { @handlers at: msg_type put: [] } unless: $ @handlers[msg_type]
      @handlers[msg_type] << [msg_pattern, callback]
    }

    def handle_message: msg type: type {
      @handlers[type] each: |handler| {
        pattern = handler first
        callback = handler second
        match msg text -> {
          case pattern  -> |matcher|
            args = Array new: $ matcher size()
            args at: 0 put: msg
            args size - 1 times: |i| {
              args at: (i + 1) put: (matcher[i + 1])
            }
            callback call: args
        }
      }
    }

    def message: message channel: channel {
      @irc privmsg(channel, message)
    }

    def run {
      { @irc read() } while_do: |line| {
        line println
        match line -> {
          # channel msg
          case /^:(\S+)\!\S+ PRIVMSG (#\S+) :(.*)$/ -> |matcher|
            author = matcher[1]
            channel = (matcher[2])
            text = matcher[3]
            timestamp = Time now()
            msg = Message new: text author: author channel: channel timestamp: timestamp client: self
            handle_message: msg type: 'channel
        }
      }
    }

    def helpers: block {
      self class class_eval(&block)
    }
  }
}