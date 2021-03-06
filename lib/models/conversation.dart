import 'message.dart';

/// This is the class which contains the details of the conversation.
class Conversation {
  /// The account ID used for the conversation.
  String? accountId;

  /// Who has the conversation assigned on the papercups dashboard, is an integer
  /// but converted to string so it can be nullable.
  String? asigneeId;

  /// When the conversation was created.
  String? createdAt;

  /// The customer ID, should be unique to the person,
  /// may be assigned to multiple conversations.
  String? customerId;

  /// Unique ID used to identify the conversation.
  String? id;

  /// How much priority the ocnvesation has.
  String? priority;

  /// If the convesation has been read by an agent.
  bool? read;

  /// The status of a conversation, can be open or closed.
  String? status;

  /// Messages part of a conversation
  List<PapercupsMessage>? messages;
  PapercupsMessage? get first {
    return messages != null && messages!.isNotEmpty ? messages![0] : null;
  }

  PapercupsMessage? get last {
    return messages != null && messages!.isNotEmpty
        ? messages![messages!.length - 1]
        : null;
  }

  Conversation({
    this.accountId,
    this.asigneeId,
    this.createdAt,
    this.customerId,
    this.id,
    this.priority,
    this.read,
    this.status,
    this.messages,
  });
}
