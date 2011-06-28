require: "../lib/fancy_irc"
require: "mocks/client"

MockedClient = FancyIRC Testing MockedClient

FancySpec describe: FancyIRC Message with: {
  before_each: {
    @client = MockedClient new: {}

    @message = FancyIRC Message new: "hello, world!" author: "bakkdoor" channel: "#fancy" timestamp: (Time now) client: @client
  }

  it: "sends a reply message to channel" for: 'reply: when: {
    reply = "Hello to you too!"
    @message reply: reply
    @client outgoing_on: (@message channel) . last is == reply
  }
}