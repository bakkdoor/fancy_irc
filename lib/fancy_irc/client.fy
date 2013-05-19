class IRCSocket {
  forwards_unary_ruby_methods
  alias_method: 'read for_ruby: 'read
}

class FancyIRC {
  class Client {
    """
    FancyIRC Client class.
    Represents a connected IRC client, possibly receiving messages and
    reacting/replying to those.

    Example usage:

        bot = FancyIRC Client new: {
          configuration: {
            server: \"irc.freenode.net\"
            nickname: \"foobarbaz\"
            channels: [\"#fancy\", \"#bot_chat\"]
          }

          # respond to channel messages
          on: 'channel pattern: /^echo: (.*)$/ do: |msg, echo_str| {
            msg reply: echo_str # reply with echo_str
          }
        }

    Also have a look at the examples/ directory for more complete
    example clients.
    """

    def initialize: block {
      """
      @block @Block@ to be called with @self as receiver for initialization.

      Client constructor.
      Takes a @Block@ to be called with @self as receiver to initialize it.
      """

      @handlers = <[]>
      block call_with_receiver: self
    }

    def configuration: conf_block {
      """
      @conf_block @Block@ to be used to create the Configuration object.

      Example usage:

          configuration: {
            server: \"irc.freenode.net\"
            port: 6667
            ssl: false
            nickname: \"foobar\"
          }
      """

      @config = Configuration new: conf_block
    }

    def connect {
      """
      Connects the client with the specified configuration settings or fails.
      """

      @irc = IRCSocket new(@config server, @config port, @config ssl)
      @irc connect
      unless: (@irc connected?) do: {
        "Could not connect to server!" raise!
      }

      { @irc pass(@config password) } if: $ @config password
      @irc nick(@config nickname)
      @irc user(@config nickname, 0, "*", "fancy_irc_bot")

      # join channels
      @config channels each: |c| {
        @irc join(c)
      }
    }

    def disconnect {
      """
      Disconnects the client from the server, if connected.
      """

      if: @irc then: {
        @irc close
        @irc = nil
      }
    }

    def reconnect {
      """
      Reconnects the client with the server.
      """

      disconnect
      connect
    }

    def on: msg_type pattern: msg_pattern do: callback {
      """
      @msg_type Type of message to handle (possible one of: 'channel,
      'private)

      @msg_pattern Message pattern (anything that can be matched
      against, e.g. Regexp or String)

      @callback Callback (usually a @Block@) to be called with at
      least the Message object received. If the resulting MatchData
      object returned from matching againg @pattern has more than one
      match values, pass those in to the callback along as well.

      Defines a new message handler with a given message type, pattern and callback.

      Example usage:

         on: 'channel pattern: /^hello, (.*)$/ do: |msg, name| {
           msg reply: $ \"Yeah, hello from me too, \" ++ name ++ \"!\"
         }
      """

      if: (msg_type == 'message) then: {
        on: 'channel pattern: msg_pattern do: callback
        on: 'private pattern: msg_pattern do: callback
        return nil
      }


      { @handlers[msg_type]: [] } unless: $ @handlers[msg_type]
      @handlers[msg_type] << (msg_pattern, callback)
    }

    def on: msg_type do: callback {
      on: msg_type pattern: Object do: callback
    }

    def handle_message: msg {
      """
      @msg Message to be handled (processed by any matching handler).
      @return Return value of the handler's callback that matched, if any.

      Handles a given message of a given type.
      """

      @handlers[msg type] each: |handler| {
        pattern, callback = handler
        match msg text {
          case pattern -> |matcher|
            try {
              args = matcher to_a
              args[0]: msg
              callback call: args
            } catch Exception => e {
              STDERR println: "ERROR: #{e}"
              STDERR println: $ e backtrace
            }
        }
      }
    }

    def message: message channel: channel {
      """
      @message Message (@String@) to be sent.
      @channel Channel (@String@) to send the @message to.

      Sends a message (@String@) to a given channel (@String@).
      """

      @irc privmsg(channel, message)
    }

    def message: message to_user: user {
      @irc privmsg(user, message)
    }

    def broadcast: message {
      @config channels each: |c| {
        message: message channel: c
      }
    }

    def parse_line: line {
      """
      @line Line to be parsed

      Parses a line of incoming data from irc, creates a Message
      object and handles the message with handle_message.
      """

      match line {
        case /^:(\S+)\!\S+ (JOIN|PART|QUIT) :?(\S+).*/ -> |_ user type channel|
          timestamp = Time now
          handle_message: $ Message new: @{
            type: $ type lowercase to_sym
            text: type
            author: user
            channel: channel
            timestamp: timestamp
            client: self
          }

        # channel msg
        case /^:(\S+)\!\S+ PRIVMSG (\S+) :(.*)$/ -> |_ author chan text|
          timestamp = Time now
          type = if: (chan[0] == "#") then: { 'channel } else: { 'private }
          handle_message: $ Message new: @{
            type: type
            text: text
            author: author
            channel: chan
            timestamp: timestamp
            client: self
          }

        case /^PING (.+)$/ -> |_ server|
          @irc pong(server)
      }
    }

    def run {
      """
      Starts the IRC client and let it handle incoming messages, as defined.
      """

      while: { @irc read } do: |line| {
        "#{Time now} - #{line}" println
        self @@ parse_line: line
      }
    }

    def helpers: block {
      """
      @block @Block@ of code that can contain method definitions to be added to @self's class.

      Allows definition of custom helper methods etc. via passing in a
      @Block@ that contains those method defnitions.
      """

      self class class_eval: block
    }
  }
}

# Don't display stacktrace when quitting execution.
trap("INT") {
  Console newline
  System exit
}
