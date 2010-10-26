require: "tcp_socket"

class FancyIrc {
  read_slots: ['server, 'port]
  read_write_slots: ['nick, 'password]

  def initialize: server port: port {
    initialize: server port: port nick: "NoNick" password: nil
  }

  def initialize: server port: port nick: nick{
    initialize: server port: port nick: nick password: nil
  }

  def initialize: @server port: @port nick: @nick password: @password {
    @connected = false
  }

  def connect {
    try {
      @socket = TCPSocket open: @server port: @port
      "Connecting to " ++ @server ++ " on port " ++ @port println
      @connected = true
      self setup_connection
    } catch Exception => e {
      @connected = false
      "Connection error: " ++ (e message) println
      System exit
    }
  }

  def write: msg {
    @socket writeln: msg
  }

  def read {
    @socket readln
  }

  def connected? {
    @socket eof? not
  }

  def run {
    { self connected? } while_true: {
      self read if_do: |msg| {
        ">> " ++ msg println
      }
    }
  }

  def join: channel {
    write: $ "JOIN " ++ channel
  }

  def setup_connection {
    "Setting nick to '" ++ @nick ++ "'" println
    write: $ "NICK " ++ @nick
    write: "USER FANCYIRC 0 * FANCYIRC"
  }

  def write: msg to_channel: channel {
    write: $ "PRIVMSG " ++ channel ++ " :" ++ msg
  }
}

firc = FancyIrc new: "irc.freenode.net" port: 6667 nick: "fancy_irc"
firc connect
chan = "#fancy"
firc join: chan
firc write: "Hello, Fancy team. This is a fancy-written irc client =)" to_channel: chan
firc run
