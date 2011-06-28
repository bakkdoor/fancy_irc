class FancyIRC {
  class Testing {
    class MockedClient : FancyIRC Client {
      def initialize: block {
        super initialize: block
        @incoming = []
        @outgoing = <[]>
      }

      def connect {
      }

      def incoming: message{
        @incoming << message
      }

      def message: message channel: channel {
        { @outgoing[channel]: [] } unless: $ @outgoing[channel]
        @outgoing[channel] << message
      }

      def outgoing_on: channel {
        @outgoing[channel] || []
      }

      def handle_incoming {
        if: (@incoming shift) then: |msg| {
          handle_message: msg type: 'channel
        }
      }

      def clear_outgoing {
        @outgoing = <[]>
      }
    }
  }
}