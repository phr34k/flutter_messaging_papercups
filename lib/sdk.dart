import 'dart:async';
import 'dart:convert';

//import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart';
//import 'package:chatwoot_client_sdk/data/local/dao/chatwoot_contact_dao.dart';
//import 'package:chatwoot_client_sdk/data/local/local_storage.dart';
//import 'package:chatwoot_client_sdk/data/remote/service/chatwoot_client_api_interceptor.dart';
//import 'package:chatwoot_client_sdk/di/modules.dart';
//import 'package:chatwoot_client_sdk/chatwoot_callbacks.dart';
//import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart';
//import 'package:chatwoot_client_sdk/data/chatwoot_repository.dart';
//import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_contact.dart';
//import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_conversation.dart';
//import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
//import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_action_data.dart';
//import 'package:chatwoot_client_sdk/data/remote/requests/chatwoot_new_message_request.dart';
//import 'package:chatwoot_client_sdk/di/modules.dart';
//import 'package:chatwoot_client_sdk/chatwoot_parameters.dart';
//import 'package:chatwoot_client_sdk/repository_parameters.dart';

import 'package:uuid/uuid.dart';

//import 'widgets/widgets.dart' as papercups;
import 'models/models.dart' as papercups;
import 'papercups_flutter.dart' as papercups;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:flutter_messaging_base/sdk.dart';
import 'package:flutter_messaging_base/ui.dart';
import 'package:flutter_messaging_base/model.dart' as types;

import 'l10n.dart';
import 'theme.dart';

class PapercupsPersistance extends Persistance {
  final PapercupsSDK sdk;
  PapercupsPersistance(this.sdk);
  @override
  void clear() {}
}

class PapercupsSDK extends SDK {
  final papercups.Props props;
  final idGen = const Uuid();
  final ChatTheme? theme;
  final ChatL10n? l10n;
  List<papercups.Conversation> _conversations = [];
  late types.User _author;
  late types.User _bot;
  bool _isonline = false;

  @override
  types.User get author => _author;

  bool get online => _isonline;

  //final _logger = Logger('papercups.chathistoryscreen');
  papercups.PaperCupsConnectionState _connectionState =
      papercups.PaperCupsConnectionState.none;
  late papercups.PaperCupsController messagingController;
  late papercups.PaperCupsViewController viewController;
  StreamController<List<Conversation>> _inbox =
      StreamController<List<Conversation>>();

  void dispose() {
    messagingController.disposeA();
    viewController.disposeA();
  }

  PapercupsSDK(
      {bool showUserAvatars = true,
      bool showUserNames = true,
      DateFormat? timeFormat,
      DateFormat? dateFormat,
      bool enablePersistence = false,
      required this.props,
      WidgetBuilder? conversationBuilder,
      WidgetBuilder? inboxBuilder,
      this.theme,
      this.l10n})
      : super(
            dateFormat: dateFormat,
            timeFormat: timeFormat,
            showUserNames: showUserNames,
            showUserAvatars: showUserAvatars,
            conversationBuilder: conversationBuilder,
            inboxBuilder: inboxBuilder) {
    messagingController = papercups.PaperCupsController();
    viewController = papercups.PaperCupsViewController(messagingController);

    messagingController.stateStreamController.stream.handleError((error) {
      /*
      ModalRoute? route = ModalRoute.of(context);
      if (route!.isCurrent) {
        String _desc = error.toString();
        Alert.show(
          _desc,
          context,
          backgroundColor: Theme.of(context).bottomAppBarColor,
          textStyle: Theme.of(context).textTheme.bodyText2,
          gravity: Alert.bottom,
          duration: Alert.lengthLong,
        );
      }
      */

      FlutterError.reportError(FlutterErrorDetails(exception: error));
    });

    messagingController.stateStreamController.stream
        .where((event) => event is papercups.PaperCupsConnectionEvent)
        .cast<papercups.PaperCupsConnectionEvent>()
        .listen((event) {
      if (event is papercups.PaperCupsConnectedEvent) {
        onconnected();
      } else if (event is papercups.PaperCupsDisconnectedEvent) {
        ondisconnected();
      }
    });

    messagingController.stateStreamController.stream
        .where((event) => event is papercups.PaperCupsConversationEvent)
        .cast<papercups.PaperCupsConversationEvent>()
        .listen((event) {
      if (event is papercups.PaperCupsConversationMessageSendEvent) {
        _conversations = messagingController.conversations.values.toList();
        notifyInboxChanged();
      } else if (event is papercups.PaperCupsConversationMessageReceivedEvent) {
        _conversations = messagingController.conversations.values.toList();
        notifyInboxChanged();
      }
    });

    messagingController.stateStreamController.stream
        .where((event) => event is papercups.PaperCupsCustomerIdentifiedEvent)
        .cast<papercups.PaperCupsCustomerIdentifiedEvent>()
        .listen((event) {
      _author = types.User(
          id: event.customer.id!, firstName: event.customer.name, lastName: "");
    });

    /*
    messagingController.stateStreamController.stream
        .where(
            (event) => event is papercups.PaperCupsConversationNavigatedEvent)
        .cast<papercups.PaperCupsConversationNavigatedEvent>()
        .listen((event) {
      setConversation(event.conversation);
    });
    */

    /*
    messagingController.stateStreamController.stream.handleError((error) {
      ModalRoute? route = ModalRoute.of(context);
      if (route!.isCurrent) {
        String _desc = error.toString();
        Alert.show(
          _desc,
          context,
          backgroundColor: Theme.of(context).bottomAppBarColor,
          textStyle: Theme.of(context).textTheme.bodyText2,
          gravity: Alert.bottom,
          duration: Alert.lengthLong,
        );
      }
    });    
    */

    /*
    FakeData data = FakeData();
    data.generate(4);
    _author = data.author;
    messages.addAll(data.messages);
    conversations.addAll(data.conversations);    
    */

    _bot = const types.User(id: "bot", firstName: "bot", lastName: "");
    _author = types.User(
        id: props.customer?.externalId ?? "",
        firstName: props.customer?.name,
        lastName: "");

    /*
    var selfCallbacks = ChatwootCallbacks(
        onMessageUpdated: (value) {
          int convIdx = _conversations
              .indexWhere((element) => element.id == value.conversationId);
          int msgIndx = _conversations[convIdx]
              .messages
              .indexWhere((element) => element.id == value.id);
          _conversations[convIdx].messages[msgIndx] = value;
          notifyInboxChanged();
        },
        onConversationOpened: (value) =>
            setConversationOpened(value.toString()),
        onConversationResolved: (value) =>
            setConversationResolved(value.toString()),
        onMessageReceived: (value) {
          int convIdx = _conversations
              .indexWhere((element) => element.id == value.conversationId);
          _conversations[convIdx].messages.add(value);
          notifyInboxChanged();
        });

    listen(selfCallbacks);
    */

    /*
    //create a new contact or reuse the contact persisted on disk
    getOrCreate().then((value) async {
      _contact = value;

      //refresh the inbox
      var convs = await _clientService.getConversations(
          inboxId: inboxIdentifier, contactId: _contact!.contactIdentifier!);
      _conversations.addAll(convs);
      notifyInboxChanged();

      //start a websocket event
      listenForEvents();
    });
    */

    messagingController.initStateA(props);
    messagingController.connect(props);
  }

  types.Message? convert(papercups.PapercupsMessage message, {String? echoId}) {
    //Sets avatar url to null if its a gravatar not found url
    //This enables placeholder for avatar to show

    String? avatarUrl = message.user?.profilePhotoUrl;
    if (avatarUrl?.contains("?d=404") ?? false) {
      avatarUrl = null;
    }

    return types.TextMessage(
        id: echoId ?? message.id.toString(),
        author: message.customer != null
            ? author
            : types.User(
                id: message.user?.id ?? "",
                firstName: message.user?.fullName ?? "",
                lastName: "",
                imageUrl: avatarUrl,
              ),
        text: message.body ?? "",
        status: message.seenAt != null ? types.Status.seen : types.Status.sent,
        createdAt: message.createdAt?.millisecondsSinceEpoch);
  }

  @override
  Future<List<Conversation>> conversation() {
    var list = _conversations
        .map((e) => Conversation(e.id.toString(),
            unread: 0,
            status: e.status == "open" ? 0 : 1,
            messsages: e.messages?.map((e) => convert(e)!).toList()))
        .toList();
    return Future.value(list);
  }

  @override
  Future<List<types.Message>> getMessages({required String? conversationId}) {
    var list = _conversations
        .where((element) => element.id!.toString() == conversationId)
        .map((e) => Conversation(e.id.toString(),
            unread: 0, messsages: e.messages!.map((e) => convert(e)!).toList()))
        .toList();
    return Future.value(list.isNotEmpty ? list.first.messsages : []);

    /*  
      messagingController.fetch(props, conversation).then((update) {
        viewController.selectChannel(
            update.oldConversation, update.newConversation);
      }, onError: (error) {
        _errors.addError(
            "There was an issue retrieving your details. Please try again!");
      });    
      */
  }

  @override
  Future<bool> getStatus({required String? conversationId}) {
    int convIdx = _conversations
        .indexWhere((element) => element.id.toString() == conversationId);
    return Future.value(_conversations[convIdx].status == "open");
  }

  /*
  Future<ChatwootContact> getOrCreate() async {
    var box = await Hive.openBox<ChatwootContact>('contact');
    ChatwootContact? _contact = box.get("contactid");
    if (_contact == null) {
      _contact = await _authService.createNewContact(_user,
          inboxIdentifier: _parameters.inboxIdentifier);
      await box.put("contactid", _contact!);
    } else {
      await _clientService.updateContact(
          {"email": _user.email, "name": _user.name},
          inboxId: _parameters.inboxIdentifier,
          contactId: _contact.contactIdentifier!);
      var s = await _clientService.getContact(
          inboxId: _parameters.inboxIdentifier,
          contactId: _contact.contactIdentifier!);
      _contact = ChatwootContact(
          id: _contact.id,
          contactIdentifier: _contact.contactIdentifier,
          pubsubToken: _contact.pubsubToken,
          name: _user.name!,
          email: _user.email!);
    }

    await box.close();
    return _contact!;
  }
  */

  void onconnected() {
    bool wasDisconnected =
        _connectionState == papercups.PaperCupsConnectionState.disconnected;
    _connectionState = papercups.PaperCupsConnectionState.connected;
    messagingController.fetch(props, null).then((update) {
      _conversations = messagingController.conversations.values.toList();
      notifyInboxChanged();
    }, onError: (error) {
      FlutterError.reportError(FlutterErrorDetails(exception: error));
    });
  }

  //@override
  void ondisconnected() {
    _connectionState = papercups.PaperCupsConnectionState.disconnected;
  }

  @override
  void addMessage(types.Message message) {
    /*
    var matchingConversations =
        conversations.where((element) => element.uuid == message.roomId);
    if (matchingConversations.isEmpty) {
      var conv = Conversation(message.roomId!, unread: 0);
      messages.add(message);
      conversations.add(conv);
      _conversationController.add(conv);
    } else {
      messages.add(message);
      _conversationController.add(matchingConversations.first);
    }
    */
  }

  @override
  Future<Conversation> create() async =>
      Future.value(Conversation(await newConversationId()));

  @override
  ChatTheme getTheme() => theme ?? const PapercupsDefaultChatTheme();
  @override
  ChatL10n getl10n() => l10n ?? const PapercupsDefaultL10n();
  @override
  Persistance getPersistances() {
    //final container = providerContainerMap[_parameters.clientInstanceKey]!;
    //final localStorage = container.read(localStorageProvider(_parameters));
    //return ChatwootPersistance(this, localStorage);
    throw UnimplementedError();
  }

  @override
  Future<String> newConversationId() async {
    /*
    var res = await _authService.createNewConversation(
        inboxIdentifier: _parameters.inboxIdentifier,
        contactIdentifier: _contact!.contactIdentifier!);
    _conversations.add(res);
    notifyInboxChanged();
    return res.id.toString();
    */

    return Future.value(idGen.v4());
  }

  /*
  Future<ChatwootMessage> send(types.TextMessage message) async 
  {

    var res = await _clientService.createMessage(
        ChatwootNewMessageRequest(content: message.text, echoId: message.id),
        inboxId: _parameters.inboxIdentifier,
        contactId: _contact!.contactIdentifier!,
        conversationId: message.roomId!);
    _conversations
        .where((element) => element.id == res.conversationId)
        .first
        .messages
        .add(res);
    notifyInboxChanged();
    return res;
  }
  */

  @override
  Future<String> newMessageId() => Future.value(idGen.v4());

  /*
  void listen(ChatwootCallbacks chatwootCallbacks) {
    _wscallbacks.add(chatwootCallbacks);
  }

  void unlisten(ChatwootCallbacks chatwootCallbacks) {
    _wscallbacks.remove(chatwootCallbacks);
  }
  */

  @override
  bool get enablePersistence => false;

  @override
  InboxProvider getInboxProvider() => InboxProvider(this);

  @override
  ConversationProvider getConversationProvider({String? conversationId}) =>
      PapercupsConversationProvider(this,
          conversation: messagingController.conversations[conversationId]!,
          messagingController: messagingController,
          viewController: viewController,
          conversationId: conversationId);

  @override
  void setConversationResolved(String conversationId) {
    /*
    int convIdx = _conversations
        .indexWhere((element) => element.id.toString() == conversationId);
    _conversations[convIdx] = ChatwootConversation(
        id: _conversations[convIdx].id,
        inboxId: _conversations[convIdx].inboxId,
        status: "resolved",
        messages: _conversations[convIdx].messages,
        contact: _conversations[convIdx].contact);
    notifyInboxChanged();
    */
  }

  @override
  void setConversationOpened(String conversationId) {
    /*
    int convIdx = _conversations
        .indexWhere((element) => element.id.toString() == conversationId);
    _conversations[convIdx] = ChatwootConversation(
        id: _conversations[convIdx].id,
        inboxId: _conversations[convIdx].inboxId,
        status: "open",
        messages: _conversations[convIdx].messages,
        contact: _conversations[convIdx].contact);
    notifyInboxChanged();
    */
  }

  Future<bool> canReply(String conversationId) {
    return Future.value(true);
  }
}

class PapercupsConversationProvider extends ConversationProvider {
  final PapercupsSDK _sdk;
  //ChatwootClient? chatwootClient;
  String? _conversationId;
  final papercups.Conversation conversation;
  final papercups.PaperCupsController messagingController;
  final papercups.PaperCupsViewController viewController;
  final MessageCollection<types.Message> _messages =
      MessageCollection<types.Message>();
  final ValueNotifier<bool> _typing = ValueNotifier(false);
  final ValueNotifier<bool> _status = ValueNotifier(true);
  final ValueNotifier<bool> _canReply = ValueNotifier(true);
  final Completer<bool> _events = Completer<bool>();
  late ValueNotifier<bool> _isonline;
  final StreamController _errors = StreamController.broadcast();

  @override
  Future<bool> get loaded => _events.future;

  @override
  Stream get errors => _errors.stream;

  @override
  SDK get sdk => _sdk;

  @override
  types.User get author => sdk.author;

  @override
  List<types.Message> get messages => _messages.collection;

  @override
  Listenable get changes => _messages;

  @override
  ValueListenable<bool> get online => _isonline;

  @override
  ValueListenable<bool> get typing => _typing;

  @override
  ValueListenable<bool> get status => _status;

  @override
  ValueListenable<bool> get canReply => _canReply;

  @override
  Future<String> getConversationId() async {
    if (_conversationId == null) {
      _conversationId = await _sdk.newConversationId();
      _canReply.value = await _sdk.canReply(_conversationId!);
      return Future.value(_conversationId!);
    } else {
      return Future.value(_conversationId!);
    }
  }

  @override
  Future<String> newMessageId() async {
    return sdk.newMessageId();
  }

  PapercupsConversationProvider(this._sdk,
      {required this.conversation,
      required this.messagingController,
      required this.viewController,
      String? conversationId}) {
    _isonline = ValueNotifier(_sdk.online);
    _conversationId = conversationId;

    /*
    ChatwootCallbacks? origional = _sdk.callbacks;
    chatwootCallbacks = ChatwootCallbacks(
      onWelcome: () {
        origional?.onWelcome?.call();
      },
      onPing: () {
        origional?.onPing?.call();
      },
      onConfirmedSubscription: () {
        origional?.onConfirmedSubscription?.call();
      },
      onConversationIsOnline: () {
        _isonline.value = true;
      },
      onConversationIsOffline: () {
        _isonline.value = false;
      },
      onConversationStartedTyping: (convId) {
        if (convId.toString() == conversationId) {
          beginTyping();
        }
      },
      onConversationStoppedTyping: (convId) {
        if (convId.toString() == conversationId) {
          endTyping();
        }
      },
      onPersistedMessagesRetrieved: (persistedMessages) {
        if (sdk.enablePersistence) {
          _messages.addAll(persistedMessages
              .map((message) => _chatwootMessageToTextMessage(message))
              .where((e) => e != null)
              .map((e) => e!));
        }
        origional?.onPersistedMessagesRetrieved?.call(persistedMessages);
      },
      onMessagesRetrieved: (messages) {
        if (messages.isEmpty) {
          return;
        }

        final chatMessages = messages
            .map((message) => _chatwootMessageToTextMessage(message))
            .where((e) => e != null)
            .map((e) => e!)
            .toList();
        final mergedMessages =
            <types.Message>{..._messages.collection, ...chatMessages}.toList();
        final now = DateTime.now().millisecondsSinceEpoch;
        mergedMessages.sort((a, b) {
          return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
        });
        _messages.replaceAll(mergedMessages);
        origional?.onMessagesRetrieved?.call(messages);
      },
      onMessageReceived: (chatwootMessage) {
        if (chatwootMessage.conversationId?.toString() == conversationId) {
          var msg = _chatwootMessageToTextMessage(chatwootMessage);
          if (msg != null) _handleMessageReceived(msg);
        }

        origional?.onMessageReceived?.call(chatwootMessage);
      },
      onMessageDelivered: (chatwootMessage, echoId) {
        if (chatwootMessage.conversationId?.toString() == conversationId) {
          var msg =
              _chatwootMessageToTextMessage(chatwootMessage, echoId: echoId);
          if (msg != null) _handleMessageSent(msg);
        }
        origional?.onMessageDelivered?.call(chatwootMessage, echoId);
      },
      onMessageUpdated: (chatwootMessage) {
        if (chatwootMessage.conversationId?.toString() == conversationId) {
          var msg = _chatwootMessageToTextMessage(chatwootMessage,
              echoId: chatwootMessage.id.toString());
          if (msg != null) _handleMessageUpdated(msg);
        }
        origional?.onMessageUpdated?.call(chatwootMessage);
      },
      onMessageSent: (chatwootMessage, echoId) {
        if (chatwootMessage.conversationId?.toString() == conversationId) {
          if (chatwootMessage.attachments != null &&
              chatwootMessage.attachments!.isNotEmpty) {
            final textMessage = types.TextMessage(
                id: echoId,
                author: author,
                text: chatwootMessage.content ?? "",
                status: types.Status.delivered);
            _handleMessageSent(textMessage);
            origional?.onMessageSent?.call(chatwootMessage, echoId);
          } else {
            final textMessage = types.TextMessage(
                id: echoId,
                author: author,
                text: chatwootMessage.content ?? "",
                status: types.Status.delivered);
            _handleMessageSent(textMessage);
            origional?.onMessageSent?.call(chatwootMessage, echoId);
          }
        }
      },
      onConversationOpened: (int convId) async {
        /*
        final resolvedMessage = types.TextMessage(
            id: idGen.v4(),
            text: widget.l10n.conversationResolvedMessage,
            author: types.User( 
                id: idGen.v4(),
                firstName: "Bot",
                imageUrl:
                    "https://d2cbg94ubxgsnp.cloudfront.net/Pictures/480x270//9/9/3/512993_shutterstock_715962319converted_920340.png"),
            status: types.Status.delivered);
        addMessage(resolvedMessage);
        */
        if (convId.toString() == conversationId) {
          //sdk.setConversationOpened(conversationId!);
          _status.value = false;
        }
      },
      onConversationResolved: (int convId) async {
        /*
        final resolvedMessage = types.TextMessage(
            id: idGen.v4(),
            text: widget.l10n.conversationResolvedMessage,
            author: types.User( 
                id: idGen.v4(),
                firstName: "Bot",
                imageUrl:
                    "https://d2cbg94ubxgsnp.cloudfront.net/Pictures/480x270//9/9/3/512993_shutterstock_715962319converted_920340.png"),
            status: types.Status.delivered);
        addMessage(resolvedMessage);
        */
        if (convId.toString() == conversationId) {
          //sdk.setConversationResolved(conversationId!);
          _status.value = true;
        }
      },
      onError: (error) {
        if (error.type == ChatwootClientExceptionType.SEND_MESSAGE_FAILED) {
          _handleSendMessageFailed(error.data);
        }
        //print("Ooops! Something went wrong. Error Cause: ${error.cause}");
        origional?.onError?.call(error);
      },
    );

    _sdk.listen(chatwootCallbacks!);
    */

/*
    (sdk as ChatwootSDK).createWeb(chatwootCallbacks!).then((client) {
      chatwootClient = client;
      //chatwootClient!.loadMessages();
    }).onError((error, stackTrace) {
      origional?.onError?.call(ChatwootClientException(
          error.toString(), ChatwootClientExceptionType.CREATE_CLIENT_FAILED));
    });
    */

    /*
    messagingController?.sendingStatusChanged?.listen((event) {
      if (event is PaperCupsConversationMessageSending) {
        _sending = true;
        if (mounted) setState(() {});
      } else if (event is PaperCupsConversationMessageDone) {
        _sending = false;
        if (mounted) setState(() {});
      }
    });

    messagingController?.stateStreamController.stream
        .where((event) => event is PaperCupsConnectionEvent)
        .cast<PaperCupsConnectionEvent>()
        .listen((event) {
      if (event is PaperCupsConnectedEvent) {
        onconnected();
      } else if (event is PaperCupsDisconnectedEvent) {
        ondisconnected();
      }
    });

    messagingController?.stateStreamController.stream
        .where((event) => event is PaperCupsConversationEvent)
        .cast<PaperCupsConversationEvent>()
        .listen((event) {
      if (event is PaperCupsConversationMessageSendEvent) {
        _logger.log(Level.SHOUT, "Message sending");
        _inbox.add(viewController!.conversation!);
        //rebuild(() {}, animate: true);
        scrollToBottom();
      } else if (event is PaperCupsConversationMessageReceivedEvent) {
        _logger.log(Level.SHOUT, "Message receiving");
        _inbox.add(viewController!.conversation!);
        //rebuild(() {});
        scrollToBottom();
        Timer(Duration(milliseconds: 50), () => scrollToBottom());
      } else if (event is PaperCupsConversationLoadEvent) {
        _inbox.add(viewController!.conversation!);
        scrollToBottom();
      } else if (event is PaperCupsConversationUnloadEvent) {
        _inbox.add(viewController!.conversation!);
      }
    });


    messagingController?.stateStreamController.stream
        .where((event) => event is PaperCupsCustomerIdentifiedEvent)
        .cast<PaperCupsCustomerIdentifiedEvent>()
        .listen((event) {
      setCustomer(event.customer, rebuild: event.rebuild);
    });

    messagingController?.stateStreamController.stream
        .where((event) => event is PaperCupsConversationNavigatedEvent)
        .cast<PaperCupsConversationNavigatedEvent>()
        .listen((event) {
      setConversation(event.conversation);
    });

  
    messagingController?.stateStreamController.stream.handleError((error) {
      _logger.log(Level.FINEST, "handle error...");
      ModalRoute? route = ModalRoute.of(context);
      if (route!.isCurrent) {
        String _desc = error.toString();
        Alert.show(
          _desc,
          context,
          backgroundColor: Theme.of(context).bottomAppBarColor,
          textStyle: Theme.of(context).textTheme.bodyText2,
          gravity: Alert.center,
          duration: Alert.lengthLong,
        );
      }
    });
    */

    if (conversationId != null) {
      sdk.getStatus(conversationId: conversationId).then((value) {
        _status.value = value;
      });

      sdk.getMessages(conversationId: conversationId).then((value) {
        _messages.addAll(value);
        _events.complete(true);
      });
    } else {
      _events.complete(true);
    }
  }

  void _handleMessageReceived(types.Message message) {
    _messages.add(message);
    sdk.addMessage(message);
  }

  void _handleMessageUpdated(types.Message message) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    _messages.replace(index, message);
    sdk.updateMessage(message);
  }

  void _handleSendMessageFailed(String echoId) async {
    final index = _messages.indexWhere((element) => element.id == echoId);
    final msg = _messages.collection[index];
    var updatedMessage = msg.copyWith(status: types.Status.error);
    _messages.replace(index, updatedMessage);
    sdk.updateMessage(updatedMessage);
  }

  void _handleMessageSent(
    types.Message message,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final msg = _messages.collection[index];
    if (msg.status == types.Status.seen) {
      return;
    }

    final updatedMessage = msg.copyWith(status: types.Status.sent);
    _messages.replace(index, updatedMessage);
    sdk.updateMessage(updatedMessage);
  }

  @override
  void updateMessage(types.Message message, types.PreviewData previewData) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final msg = _messages.collection[index];
    final updatedMessage = msg.copyWith(previewData: previewData);
    _messages.replace(index, updatedMessage);
    sdk.updateMessage(updatedMessage);
  }

  @override
  void resendMessage(types.Message message) async {
    if (message is types.TextMessage) {
      //chatwootClient!.sendMessage(content: message.text, echoId: message.id);
    }

    final index = _messages.indexWhere((element) => element.id == message.id);
    final msg = _messages.collection[index];
    var updateMessage = msg.copyWith(status: types.Status.sending);
    _messages.replace(index, updateMessage);
    sdk.updateMessage(message);
  }

  @override
  void sendMessage(types.Message message) async {
    //ChatwootCallbacks? origional = (sdk as ChatwootSDK).callbacks;
    if (message is types.TextMessage) {
      types.TextMessage msg = message;
      _messages.add(message);
      sdk.addMessage(message);

      var timeNow = DateTime.now().toUtc();
      var msg2 = papercups.PapercupsMessage(
        body: msg.text,
        createdAt: timeNow,
        sentAt: timeNow,
        customer: papercups.PapercupsCustomer(),
      );

      viewController.stateMessageController.add(msg2);

      //await _sdk.send(message);
      //chatwootClient!.sendMessage(content: msg.text, echoId: message.id);
      //widget.onSendPressed?.call(message);

    } else if (message is types.FileMessage) {
      _messages.insert(0, message);
      sdk.addMessage(message);
      //widget.onSendPressed?.call(message);
    } else if (message is types.ImageMessage) {
      _messages.insert(0, message);
      sdk.addMessage(message);
      //widget.onSendPressed?.call(message);
    } else {
      _messages.insert(0, message);
      sdk.addMessage(message);
      //widget.onSendPressed?.call(message);
    }
  }

  @override
  void beginTyping() {
    _typing.value = true;
  }

  @override
  void endTyping() {
    _typing.value = false;
  }

  @override
  Future<void> resolve() => Future.value();

  @override
  Future<void> more() => Future.delayed(const Duration(seconds: 1));
}
