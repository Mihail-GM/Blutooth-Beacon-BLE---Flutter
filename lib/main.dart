import 'package:flutter/material.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retrieve Text Input',
      home: MyCustomForm(),
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  static const UUID = '00000000-0000-0000-0000-000000000000';
  BeaconBroadcast beaconBroadcast = BeaconBroadcast();
  BeaconStatus _isTransmissionSupported;
  bool _isAdvertising = false;
  StreamSubscription<bool> _isAdvertisingSubscription;

  final _key = GlobalKey<FormState>();

  var _minor;
  var _power;
  var _major;

  @override
  void initState() {
    super.initState();

    beaconBroadcast
        .checkTransmissionSupported()
        .then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });

    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon app'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Align(
                alignment: Alignment.topLeft,
                child: Container(
                    padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Text('ALTBeacon'))),
            Divider(),
            Align(
                alignment: Alignment.topLeft,
                child: Container(
                    padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Text('$UUID'))),
            Divider(),
            Form(
              key: _key,
              child: FormUI(),
            ),
            Container(height: 32.0),
            Text('Is transmission supported?',
                style: Theme.of(context).textTheme.headline),
            Text('$_isTransmissionSupported',
                style: Theme.of(context).textTheme.subhead),
            Container(height: 16.0),
            Text('Is beacon started?',
                style: Theme.of(context).textTheme.headline),
            Text('$_isAdvertising', style: Theme.of(context).textTheme.subhead),
            Container(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget FormUI() {
    return new Column(
      children: <Widget>[
        TextFormField(
          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value.isEmpty) {
              return 'The field can not be empty. Only digits are allowed';
            }
            int valValidete = int.parse(value);
            if (valValidete < 1 || valValidete > 65535) {
              return 'Please enter number between 1 and 65 535';
            }

            _major = valValidete;
            return null;
          },
          onSaved: (String val) {
            _major = val;
          },
          decoration: InputDecoration(
            hintText: "Major",
            contentPadding: const EdgeInsets.all(15.0),
          ),
        ),
        TextFormField(
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value.isEmpty) {
                return 'The field can not be empty. Only digits are allowed';
              }
              int valValidete = int.parse(value);
              if (valValidete < 1 || valValidete > 65535) {
                return 'Please enter number between 1 and 65 535';
              }

              _minor = valValidete;
              return null;
            },
            decoration: InputDecoration(
              hintText: "Minor",
              contentPadding: const EdgeInsets.all(15.0),
            ),
            onSaved: (String val) {
              _minor = val;
            }),
        TextFormField(
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value.isEmpty) {
                return 'The field can not be empty. Only digits are allowed';
              }
              int valValidete = int.parse(value);
              if (valValidete < 0 || valValidete > 7) {
                return 'Please enter number between 0 and 7';
              }

              _power = valValidete;
              return null;
            },
            decoration: InputDecoration(
              hintText: "Power",
              contentPadding: const EdgeInsets.all(15.0),
            ),
            onSaved: (String val) {
              _power = val;
            }),
        Container(height: 32.0),
        Center(
          child: RaisedButton(
            onPressed: () {
              if (_key.currentState.validate()) {
                beaconBroadcast
                    .setUUID(UUID)
                    .setMajorId(_major)
                    .setMinorId(_minor)
                    .setTransmissionPower(_power)
                    .start();
              }
            },
            child: Text('Advertise now'),
            color: Colors.green,
            textColor: Colors.white,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0),
            ),
          ),
        ),
        Center(
          child: RaisedButton(
            onPressed: () {
              beaconBroadcast.stop();
            },
            child: Text('Stop advertise'),
            color: Colors.red,
            textColor: Colors.white,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is disposed.

    //Check if
    if (_isAdvertisingSubscription != null) {
      _isAdvertisingSubscription.cancel();
    }
  }
}
