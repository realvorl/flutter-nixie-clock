// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedHour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final formattedMinute = DateFormat('mm').format(_dateTime);

    final hd = formattedHour[0];
    final hu = formattedHour[1];
    final md = formattedMinute[0];
    final mu = formattedMinute[1];

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var ratio = 1.66 / (screenWidth / screenHeight);

    log("screen: " +
        screenWidth.toString() +
        " x " +
        screenHeight.toString() +
        " ratio: " +
        ratio.toString());

    var widthOfTube = screenWidth * 105 / 533.33;
    var widthOfSmallTube = screenWidth * 66 / 533.33;
    var bottomEdge = screenHeight * 36 / 320.0;

    widthOfTube = widthOfTube * ratio;
    widthOfSmallTube = widthOfSmallTube * ratio;

    var hourAnimation =
        new Image.asset("assets/nixies/00" + hd + ".png", width: widthOfTube);
    var hourUAnimation = new Image.asset(
      "assets/nixies/00" + hu + ".png",
      width: widthOfTube,
    );

    var blinker = new Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: bottomEdge, left: 5, right: 5),
      child:
          new Image.asset("assets/nixies/blinker.gif", width: widthOfSmallTube),
    );

    var minuteAnimation = new Image.asset(
      "assets/nixies/00" + md + ".png",
      width: widthOfTube,
    );
    var minuteUAnimation = new Image.asset(
      "assets/nixies/00" + mu + ".png",
      width: widthOfTube,
    );

    return Container(
        color: Theme.of(context).primaryColorDark,
        child: new Stack(
          children: <Widget>[
            new Image.asset("assets/bgrounds/simplebg.png", width: screenWidth),
            new Image.asset("assets/nixies/sep.png", width: screenWidth),
            new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  hourAnimation,
                  hourUAnimation,
                  blinker,
                  minuteAnimation,
                  minuteUAnimation
                ]),
            new Container(
                child: new Image.asset("assets/nixies/mask.png",
                    width: screenWidth))
          ],
        ));
  }
}
