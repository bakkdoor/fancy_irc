class FancyIRC {
  class Client {
    def initialize: block {
      block call_with_receiver: self
    }

    def configuration: conf_block {
      @config = Configuration new: block
    }

    def connect {
      @irc = IRCSocket new(@config server, @config port, @config ssl)
      @irc connect()
      unless: (@irc connected?()) do: {
        "Could not connect to server!" raise!
      }

      @irc nick(@config nickname)
      { @irc pass(@config password) } if: $ @config password

      # join all the channels mentioned
      @config channels each: |c| {
        @irc join(c)
      }
    }

    def on: msg_type pattern: msg_pattern do: callback {

    }
  }
}