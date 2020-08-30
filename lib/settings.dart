import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'saved_vals.dart';
import 'classes_and_types.dart';

class SettingsThreePage extends StatefulWidget {
  @override
  _SettingsThreePageState createState() => _SettingsThreePageState();

  AppBar getAppBar() {
    return AppBar(
      backgroundColor: Colors.green,
      title: Text(
        'Settings',
      ),
    );
  }

  Color getColor() {
    return Colors.grey.shade200;
  }
}

class _SettingsThreePageState extends State<SettingsThreePage> {
  SharedPreferences prefs;
  bool getNotifications = false;
  static final String path = "lib/src/pages/settings/settings3.dart";
  final TextStyle headerStyle = TextStyle(
    color: Colors.grey.shade800,
    //color: Colors.blue,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "GENERAL",
            style: headerStyle,
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 0.5,
            margin: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 0,
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  //leading: CircleAvatar(
                  //child: Icon(Icons.person_outline),
                  //),
                  leading: Icon(Icons.palette, color: Colors.blue, size: 30),
                  title: Text("Theme"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _theme();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            "PLANNER",
            style: headerStyle,
          ),
          Card(
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 0,
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.view_list, color: Colors.blue, size: 30),
                  title: Text("Manage classes and types"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Launch.manage(context);
                  },
                ),
                _buildDivider(),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.blue, size: 30),
                  title: Text("Clear items"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _clearItems();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            "FOREST",
            style: headerStyle,
          ),
          Card(
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 0,
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.flare, color: Colors.blue, size: 30),
                  title: Text("Photon settings"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _photon();
                  },
                ),
                _buildDivider(),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.blue, size: 30),
                  title: Text("Clear forest"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _clearForest();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            "NOTIFICATIONS",
            style: headerStyle,
          ),
          Card(
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 0,
            ),
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  activeColor: Colors.blue,
                  value: getNotifications,
                  title: Text("Receive Notifications"),
                  onChanged: (val) {
                    getNotifications = val;
                    if (prefs != null) prefs.setBool('getNotifications', val);
                    setState(() {});
                  },
                ),
                _buildDivider(),
                ListTile(
                  leading:
                      Icon(Icons.notifications, color: Colors.blue, size: 30),
                  title: Text("Customize Notifications"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _notifications();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 60.0),
        ],
      ),
    );
  }

  Future<void> getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    getNotifications = prefs.getBool(Prefs.getNotifications) ?? false;
    if (this.mounted) setState(() {});
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }

  void _theme() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Change Theme'),
        ),
        body: Container(),
        resizeToAvoidBottomPadding: false,
      );
    }));
  }

  void _clearItems() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Clear Items'),
        ),
        body: Container(),
        resizeToAvoidBottomPadding: false,
      );
    }));
  }

  void _photon() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Photon Settings'),
        ),
        body: Container(),
        resizeToAvoidBottomPadding: false,
      );
    }));
  }

  void _clearForest() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Clear Forest'),
        ),
        body: Container(),
        resizeToAvoidBottomPadding: false,
      );
    }));
  }

  void _notifications() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Manage Notifications'),
        ),
        body: Container(),
        resizeToAvoidBottomPadding: false,
      );
    }));
  }
}
