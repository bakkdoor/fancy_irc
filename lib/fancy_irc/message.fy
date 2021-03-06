class FancyIRC {
  class Message {
    """
    FancyIRC Message class.
    Represents a a message sent on IRC that the client received.
    Contains all the relevant information for a message like:
    @author, @text, @channel, @timestamp & @client (the FancyIRC Client instance that got this message).
    """

    read_write_slots: ['type, 'text, 'author, 'channel, 'timestamp, 'client]

    def initialize: block {
      block call: [self]
    }

    def initialize: @type text: @text author: @author channel: @channel timestamp: @timestamp client: @client {
      """
      @type Type of message: 'join, 'part, 'quit, 'message, 'private or 'channel
      @text Text of the message been sent.
      @author Nickname of the user that sent the message.
      @channel Name of the channel on which the message was sent.
      @timestamp Timestamp of the message (when it was received).
      @client FancyIRC Client instance that got this message.

      Message constructor.
      """
    }

    def reply: message {
      """
      @message @String@ that is the message to reply with.

      Replies to a Message with a given message (@String@).
      Replying means writing back to the same @channel this message
      was received from.
      """

      match @type {
        case 'channel ->
          @client message: message channel: @channel
        case _ ->
          @client message: message to_user: @author
      }
    }
  }
}
