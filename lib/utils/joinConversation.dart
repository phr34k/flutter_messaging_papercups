import '../models/models.dart';
import 'package:phoenix_socket/phoenix_socket.dart';
import 'package:logging/logging.dart';
import 'dart:async';

/// This function will join the channel and listen to new messages.
PhoenixChannel joinConversationAndListenEx({
  required String convId,
  required PhoenixSocket socket,
  StreamController<PaperCupsConversationEvent>? eventsController,
  StreamController<List<PapercupsMessage>>? controller,
}) {
  final _logger = Logger('papercups.channel');

  // Adding the channel.
  PhoenixChannel conversation =
      socket.addChannel(topic: "conversation:" + convId);
  // Joining channel.
  conversation.join();

  // Give out information to the event
  eventsController?.add(PaperCupsConversationConnectedEvent(
      conversationId: convId, channel: conversation));

  // Add the listener that will check for new messages.
  conversation.messages.listen((event) {
    Map<String, dynamic> payload = event.payload!;
    if (payload["status"] == "error") {
      // If there is an error, shutdown the channels and remove it.
      //conversation.close();
    } else {
      if (event.event.toString().contains("shout") ||
          event.event.toString().contains("message:created")) {
        try {
          // https://github.com/papercups-io/papercups/pull/488
          // "message:created" is still not implemented see the PR above.
          if (payload["customer"] == null) {
            var msg = PapercupsMessage(
              accountId: payload["account_id"],
              body: payload["body"].toString().trim(),
              conversationId: payload["conversation_id"],
              customerId: payload["customer_id"] != null
                  ? payload["customer_id"].toString()
                  : null,
              id: payload["id"],
              user: (payload["user"] != null)
                  ? User(
                      email: payload["user"]["email"],
                      id: payload["user"]["id"] != null
                          ? payload["user"]["id"].toString()
                          : null,
                      role: payload["user"]["role"],
                      fullName: (payload["user"]["full_name"] != null)
                          ? payload["user"]["full_name"]
                          : null,
                      profilePhotoUrl:
                          (payload["user"]["profile_photo_url"] != null)
                              ? payload["user"]["profile_photo_url"]
                              : null,
                    )
                  : null,
              customer: (payload["customer"] != null)
                  ? PapercupsCustomer(
                      email: payload["customer"]["email"],
                      id: payload["customer"]["id"],
                    )
                  : null,
              userId: int.parse(payload["user_id"].toString()),
              createdAt: payload["created_at"] != null
                  ? DateTime.tryParse(payload["created_at"])
                  : null,
              seenAt: payload["seen_at"] != null
                  ? DateTime.tryParse(payload["seen_at"])
                  : null,
              sentAt: payload["sent_at"] != null
                  ? DateTime.tryParse(payload["sent_at"])
                  : null,
            );

            controller?.add([msg]);
          }
        } catch (e) {
          _logger.log(Level.SEVERE, e.toString());
          eventsController?.addError(e);
        }
      }
    }
  }, onDone: () {
    socket.removeChannel(conversation);
    eventsController?.add(PaperCupsConversationDisconnectedEvent(
        conversationId: convId, channel: conversation));
    eventsController?.close();
    //TODO: check this
    //conversation = null;
  }, onError: (error) {
    eventsController?.addError(error);
  });
  return conversation;
}
