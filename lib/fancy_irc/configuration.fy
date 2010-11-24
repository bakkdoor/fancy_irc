class FancyIRC {
  class Configuration {
    read_write_slots: ['server, 'port, 'nickname, 'password, 'channels, 'ssl]
    def initialize: block {
      # default values:
      @port = 6667
      @ssl = false
      @channels = []
      @nickname = "anonymous"
      @password = nil

      block call_with_receiver: self
    }
  }
}