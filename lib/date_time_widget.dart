import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class DateTimeWidget extends StatefulWidget {
  DateTimeWidgetState myState;
  final DateTime inDateTime;
  final DateTime spareConstant = DateTime.utc(1990, 12, 6, 3, 1, 7);

  DateTimeWidget({this.inDateTime});

  @override
  DateTimeWidgetState createState() {
    myState = DateTimeWidgetState();
    return myState;
  }

  DateTime getDateTime() {
    if (myState.dateParsable != " " && myState.timeParsable != " ")
      return DateTime.parse('${myState.dateParsable} ${myState.timeParsable}');
    else if (myState.dateParsable != " ")
      return DateTime.parse(
          '${myState.dateParsable} ${DateTime.utc(2020, 7, 3, 21, 21, 21).toString().substring(11)}');
    else if (myState.timeParsable != " ")
      return (DateTime.parse(
          '${DateTime.now().toString().substring(0, 10)} ${myState.timeParsable}'));

    return spareConstant;
  }
}

class DateTimeWidgetState extends State<DateTimeWidget> {
  String dateAsStr = "Not set";
  String timeAsStr = "Not set";
  String dateParsable = " ";
  String timeParsable = " ";
  DateTime savedDate = DateTime.now();
  DateTime savedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.inDateTime != null &&
        !widget.inDateTime.isAtSameMomentAs(widget.spareConstant)) {
      dateAsStr =
          '${widget.inDateTime.year} - ${widget.inDateTime.month} - ${widget.inDateTime.day}';
      if (widget.inDateTime.hour < 12 && widget.inDateTime.hour != 0)
        timeAsStr = '${widget.inDateTime.hour} : ' +
            '${widget.inDateTime.minute}'.padLeft(2, "0") +
            ' AM';
      else if (widget.inDateTime.hour > 12)
        timeAsStr = '${widget.inDateTime.hour - 12} : ' +
            '${widget.inDateTime.minute}'.padLeft(2, "0") +
            ' PM';
      else if (widget.inDateTime.hour == 0)
        timeAsStr = '${widget.inDateTime.hour + 12} : ' +
            '${widget.inDateTime.minute}'.padLeft(2, "0") +
            ' AM';
      else
        timeAsStr = '${widget.inDateTime.hour} : ' +
            '${widget.inDateTime.minute}'.padLeft(2, "0") +
            ' PM';
      savedDate = widget.inDateTime;
      savedTime = widget.inDateTime;
      dateParsable = widget.inDateTime.toString().substring(0, 10);
      timeParsable = widget.inDateTime.toString().substring(11);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              elevation: 4.0,
              onPressed: () {
                DatePicker.showDatePicker(context,
                    theme: DatePickerTheme(
                      containerHeight: 210.0,
                    ),
                    showTitleActions: true,
                    minTime: DateTime(2000, 1, 1),
                    maxTime: DateTime(2030, 12, 31), onConfirm: (date) {
                  dateParsable = date.toString().substring(0, 10);
                  print('confirm $date');
                  print('dateParsable: $dateParsable');
                  dateAsStr = '${date.year} - ${date.month} - ${date.day}';
                  savedDate = date;
                  setState(() {});
                }, currentTime: savedDate, locale: LocaleType.en);
              },
              child: Container(
                alignment: Alignment.center,
                height: 45.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.date_range,
                                size: 18.0,
                                color: Theme.of(context).appBarTheme.color,
                              ),
                              Text(
                                " $dateAsStr",
                                style: TextStyle(
                                    color: Theme.of(context).appBarTheme.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      "  Change",
                      style: TextStyle(
                          color: Theme.of(context).appBarTheme.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ],
                ),
              ),
              color: Colors.white,
            ),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              elevation: 4.0,
              onPressed: () {
                DatePicker.showPicker(
                  context,
                  pickerModel: CustomPicker(
                      currentTime: savedTime, locale: LocaleType.en),
                  theme: DatePickerTheme(
                    containerHeight: 210.0,
                  ),
                  showTitleActions: true,
                  onConfirm: (time) {
                    timeParsable = time.toString().substring(11);
                    print('confirm $time');
                    print('timeParsable: $timeParsable');
                    if (time.hour < 12 && time.hour != 0)
                      timeAsStr = '${time.hour} : ' +
                          '${time.minute}'.padLeft(2, "0") +
                          ' AM';
                    else if (time.hour > 12)
                      timeAsStr = '${time.hour - 12} : ' +
                          '${time.minute}'.padLeft(2, "0") +
                          ' PM';
                    else if (time.hour == 0)
                      timeAsStr = '${time.hour + 12} : ' +
                          '${time.minute}'.padLeft(2, "0") +
                          ' AM';
                    else
                      timeAsStr = '${time.hour} : ' +
                          '${time.minute}'.padLeft(2, "0") +
                          ' PM';
                    savedTime = time;
                    setState(() {});
                  },
                );
                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                height: 45.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.access_time,
                                size: 18.0,
                                color: Theme.of(context).appBarTheme.color,
                              ),
                              Text(
                                " $timeAsStr",
                                style: TextStyle(
                                    color: Theme.of(context).appBarTheme.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      "  Change",
                      style: TextStyle(
                          color: Theme.of(context).appBarTheme.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ],
                ),
              ),
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({DateTime currentTime, LocaleType locale})
      : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    var _dayPeriod = 0;
    if (this.currentTime.hour < 12)
      this.setLeftIndex(this.currentTime.hour);
    else {
      this.setLeftIndex(this.currentTime.hour - 12);
      _dayPeriod = 1;
    }
    if (this.currentTime.minute % 5 != 0) {
      this.setMiddleIndex((this.currentTime.minute / 5).round() + 1);
    } else {
      this.setMiddleIndex((this.currentTime.minute / 5).round());
    }
    this.setRightIndex(_dayPeriod);
    _fillRightList();
  }

  @override
  String leftStringAtIndex(int index) {
    if (index >= 1 && index < 13) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < 12) {
      return this.digits(index * 5, 2);
    } else {
      return null;
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index == 0) {
      return 'AM';
    } else if (index == 1) {
      return 'PM';
    }
    return null;
  }

  void _fillRightList() {
    this.rightList = List.generate(2, (int index) {
      return '$index';
    });
  }

  @override
  void setRightIndex(int index) {
    super.setRightIndex(index);
    _fillRightList();
  }

  void _fillMiddleList() {
    this.middleList = List.generate(12, (int index) {
      return '${index * 5}';
    });
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    _fillMiddleList();
  }

  @override
  String leftDivider() {
    return ":";
  }

  @override
  String rightDivider() {
    return " ";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  DateTime finalTime() {
    if (this.currentLeftIndex() == 12) {
      if (this.currentRightIndex() == 0) {
        return currentTime.isUtc
            ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
                this.currentLeftIndex() - 12, this.currentMiddleIndex() * 5, 0)
            : DateTime(currentTime.year, currentTime.month, currentTime.day,
                this.currentLeftIndex() - 12, this.currentMiddleIndex() * 5, 0);
      }

      return currentTime.isUtc
          ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
              this.currentLeftIndex(), this.currentMiddleIndex() * 5, 0)
          : DateTime(currentTime.year, currentTime.month, currentTime.day,
              this.currentLeftIndex(), this.currentMiddleIndex() * 5, 0);
    }
    if (this.currentRightIndex() == 0) {
      return currentTime.isUtc
          ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
              this.currentLeftIndex(), this.currentMiddleIndex() * 5, 0)
          : DateTime(currentTime.year, currentTime.month, currentTime.day,
              this.currentLeftIndex(), this.currentMiddleIndex() * 5, 0);
    } else {
      return currentTime.isUtc
          ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
              this.currentLeftIndex() + 12, this.currentMiddleIndex() * 5, 0)
          : DateTime(currentTime.year, currentTime.month, currentTime.day,
              this.currentLeftIndex() + 12, this.currentMiddleIndex() * 5, 0);
    }
  }
}
