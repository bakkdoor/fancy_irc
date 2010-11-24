class FancyIRC {
  class Message {
    read_slots: ['text, 'author, 'channel, 'timestamp]

    def initialize: @text author: @author channel: @channel timestamp: @timestamp client: @client {
    }

    def reply: message {
      @client message: message channel: @channel
    }
  }
}