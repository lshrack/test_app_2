import 'package:flutter/material.dart';
import 'dart:async';
import 'saved_vals.dart';

class MyDropdown extends StatefulWidget {
  final List<String> _items;
  final IconData _icon;
  final List<Color> _colors;
  final StreamController controller;
  String _currPicked;
  MyDropdown(this._items, this._icon, this._colors, this._currPicked,
      {this.controller});
  _MyDropdownState myState = _MyDropdownState();

  @override
  _MyDropdownState createState() {
    return myState;
  }

  String getVal() {
    return _currPicked;
  }
}

class _MyDropdownState extends State<MyDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: widget._currPicked,
        items: toDropdownList(widget._items, widget._icon, widget._colors,
            Vals.textStyle(context)),
        onChanged: (string) {
          if (widget.controller != null) {
            widget.controller.add(ControllerNums.dChangeVal);
          }
          setState(() {
            widget._currPicked = string;
          });
        });
  }

  List<DropdownMenuItem> toDropdownList(List<String> _strings, IconData icon,
      List<Color> _colors, TextStyle style) {
    List<DropdownMenuItem> _items = [];

    for (int i = 0; i < _strings.length && i < _colors.length; i++) {
      if (_colors[i] == Colors.white) {
        _items.add(DropdownMenuItem(
          value: _strings[i],
          child: Row(
            children: <Widget>[Text(_strings[i], style: style)],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ));
      } else {
        _items.add(DropdownMenuItem(
          value: _strings[i],
          child: Row(
            children: <Widget>[
              Icon(icon, color: _colors[i]),
              Text(_strings[i], style: style)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ));
      }
    }

    return _items;
  }
}
