import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_papercups/models/models.dart';
import 'package:flutter_messaging_papercups/sdk.dart';
import 'package:provider/provider.dart';

import 'package:flutter_messaging_base/sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<SDK>(
              create: (_) => PapercupsSDK(
                      props: Props(
                    accountId: "843d8a14-8cbc-43c7-9dc9-3445d427ac4e",
                    title: "Welcome!",
                    //primaryColor: Color(0xff1890ff),
                    primaryGradient: const LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                    ),
                    greeting: "Welcome to the test app!",
                    subtitle: "How can we help you?",
                    customer: kDebugMode
                        ? CustomerMetadata(
                            email: "flutter-plugin@test.com",
                            externalId: "123456789876543",
                            name: "Test App",
                            otherMetadata: {
                              "app": "example",
                            },
                          )
                        : null,
                  ))),
        ],
        builder: (_, __) => MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),

              initialRoute: '/',
              onGenerateRoute: (route) {
                if (route.name == '/') {
                  return Provider.of<SDK>(_, listen: false).getDefaultInboxUI();
                }

                return null;
              },

              //home: const InboxPage(title: 'Flutter Demo Home Page'),
            ));
  }
}
