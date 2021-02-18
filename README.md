# flutter_messaging_papercups

This is an papercups backend implementation for the flutter_messaging_base library that aims to expose messaging backends in an unified approach. Making it easier for developers to integrate various backends in their app and provide rich customisations for it. This is an unofficial library, and is not supported by the origional authors.

## Main repository

https://github.com/phr34k/flutter_messaging_papercups

## Installing

To get started simply add `flutter_messaging_papercups:` and the latest version to your pubspec.yaml. Then run `flutter pub get`

## Using the widget

Integration with your app requires just a few lines of code. All that it requires is that you provide the `PapercupsSDK` provider, and the provider
will help you generate page routes to navigate to your inbox or specific chats.

```Dart
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

    
```
That should get you up and running in just a few seconds ⚡️.

## Configuration

### Available Props paramaters
| Prop | Type | Value | Default |
| :--- | :--- | :----- | :------ |
| **`accountId`** | `string` | **Required**, your Papercups account token | N/A |
| **`title`** | `string` | The title in the header of your chat widget | Welcome! |
| **`subtitle`** | `string` | The subtitle in the header of your chat widget | How can we help you? |
| **`newMessagePlaceholder`** | `string` | The placeholder text in the new message input | Start typing... |
| **`primaryColor`** | `Color` | The theme color of your chat widget | `Theme.of(context).primaryColor` without alpha |
| **`primaryGradient`** | `Gradient` | Gradient to specify, should be used instead of primaryColor, DO NOT USE BOTH. | N/A |
| **`greeting`** | `string` | An optional initial message to greet your customers with | N/A |
| **`customer`** | `CustomerMetadata` | Identifying information for the customer, including `name`, `email`, `external_id`, and `metadata` (for any custom fields) | N/A |
| **`baseUrl`** | `string` | The base URL of your API if you're self-hosting Papercups. Ensure you do not include the protocol (https) of a trailing dash (/) | app.papercups.io |
| **`requireEmailUpfront`** | `boolean` | If you want to require unidentified customers to provide their email before they can message you | `false` |
| **`companyName`** | `String` | Company name to show on greeting | `"Bot"` |
| **`enterEmailPlaceholer`** | `String` | This is the placeholder text in the email input section | `"Enter your email"` |

### Available CustomerMetaData paramaters
| Parameters | Type | Value | Default |
| :--- | :--- | :----- | :------ |
| **`email`** | `string` | The customer's email| N/A |
| **`externalId`** | `string` | The customer's external ID | N/A |
| **`name`** | `string` | The customer's name | N/A |
| **`otherMetadata`** | `Map<String, String>` | Extra metadata to pass such as OS info. | N/A |


