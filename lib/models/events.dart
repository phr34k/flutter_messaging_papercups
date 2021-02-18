import 'customer.dart';
import 'conversation.dart';
import 'message.dart';
import 'package:phoenix_socket/phoenix_socket.dart';

class PaperCupsEvent {}

class PaperCupsConnectionEvent extends PaperCupsEvent {}

class PaperCupsConnectedEvent extends PaperCupsConnectionEvent {}

class PaperCupsDisconnectedEvent extends PaperCupsConnectionEvent {}

class PaperCupsCustomerIdentifiedEvent extends PaperCupsEvent {
  PapercupsCustomer customer;
  bool rebuild;
  PaperCupsCustomerIdentifiedEvent(this.customer, this.rebuild);
}

class PaperCupsConversationNavigatedEvent extends PaperCupsEvent {
  Conversation conversation;
  bool rebuild;
  PaperCupsConversationNavigatedEvent(this.conversation, this.rebuild);
}

class PaperCupsSessionIdentifiedEvent extends PaperCupsEvent {}

class PaperCupsConversationStartedEvent extends PaperCupsEvent {}

class PaperCupsConversationClosedEvent extends PaperCupsEvent {}

class PaperCupsConversationEvent extends PaperCupsEvent {
  final String? conversationId;
  final PhoenixChannel? channel;
  PaperCupsConversationEvent({
    this.channel,
    this.conversationId,
  });
}

class PaperCupsConversationFinishedEvent extends PaperCupsEvent {}

class PaperCupsConversationUnloadEvent extends PaperCupsConversationEvent {
  PaperCupsConversationUnloadEvent({
    String? conversationId,
    PhoenixChannel? channel,
  }) : super(conversationId: conversationId, channel: channel);
}

class PaperCupsConversationLoadEvent extends PaperCupsConversationEvent {
  PaperCupsConversationLoadEvent({
    String? conversationId,
    PhoenixChannel? channel,
  }) : super(conversationId: conversationId, channel: channel);
}

class PaperCupsConversationConnectedEvent extends PaperCupsConversationEvent {
  PaperCupsConversationConnectedEvent({
    String? conversationId,
    PhoenixChannel? channel,
  }) : super(conversationId: conversationId, channel: channel);
}

class PaperCupsConversationDisconnectedEvent
    extends PaperCupsConversationEvent {
  PaperCupsConversationDisconnectedEvent({
    String? conversationId,
    PhoenixChannel? channel,
  }) : super(conversationId: conversationId, channel: channel);
}

class PaperCupsConversationMessageStatusEvent
    extends PaperCupsConversationEvent {
  PaperCupsConversationMessageStatusEvent({
    String? conversationId,
    PhoenixChannel? channel,
  }) : super(conversationId: conversationId, channel: channel);
}

class PaperCupsConversationMessageSendEvent extends PaperCupsConversationEvent {
  List<PapercupsMessage> messages;
  PaperCupsConversationMessageSendEvent({
    String? conversationId,
    PhoenixChannel? channel,
    required this.messages,
  }) : super(conversationId: conversationId, channel: channel);
}

class PaperCupsConversationMessageReceivedEvent
    extends PaperCupsConversationEvent {
  List<PapercupsMessage> messages;
  PaperCupsConversationMessageReceivedEvent({
    String? conversationId,
    PhoenixChannel? channel,
    required this.messages,
  }) : super(conversationId: conversationId, channel: channel);
}

class PaperCupsConversationMessageSending
    extends PaperCupsConversationMessageStatusEvent {
  PaperCupsConversationMessageSending({
    String? conversationId,
    PhoenixChannel? channel,
  }) : super(conversationId: conversationId, channel: channel);
}

class PaperCupsConversationMessageDone
    extends PaperCupsConversationMessageStatusEvent {
  PaperCupsConversationMessageDone({
    String? conversationId,
    PhoenixChannel? channel,
  }) : super(conversationId: conversationId, channel: channel);
}
