class FancyIRC {
  class Configuration {
    """
    FancyIRC Configuration class.
    Represents a configuration of a FancyIRC client.
    Has accessor methods for all the possible setting values.
    """

    read_write_slots: ['server, 'port, 'nickname, 'password, 'channels, 'ssl]

    def initialize: block {
      """
      @block @Block@ of code evaluated with @self as receiver to initialize the Configuration object.

      Configuration constructor.
      Expects a @Block@ that gets called with @self as receiver to set the setting values.
      """

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