import 'package:adoptive_calendar/src/timePicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'monthYearPicker.dart';

class AdoptiveCalendar extends StatefulWidget {
  final DateTime initialDate;
  final Color? backgroundColor;
  final Color? fontColor;
  final Color? selectedColor;
  final Color? headingColor;
  final Color? barColor;
  final Color? barForegroundColor;
  final Color? iconColor;
  final int? minYear;
  final int? maxYear;
  // final bool? use24hFormat;
  const AdoptiveCalendar({
    super.key,
    required this.initialDate,
    this.backgroundColor,
    this.minYear,
    this.maxYear,
    this.fontColor,
    this.selectedColor,
    this.headingColor,
    this.iconColor,
    this.barColor,
    this.barForegroundColor,
    // this.use24hFormat = false
  });

  @override
  State<AdoptiveCalendar> createState() => _AdoptiveCalendarState();
}

class _AdoptiveCalendarState extends State<AdoptiveCalendar> {
  DateTime? _selectedDate;
  DateTime? returnDate;
  bool? isYearSelected;
  bool? isTimeSelected;
  bool? isAM;
  List<String> monthNames = Constants.repeatMonthNames;

  @override
  void initState() {
    _selectedDate = widget.initialDate;
    isYearSelected = false;
    isTimeSelected = false;
    isAM = _selectedDate!.hour < 12;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    var orientation = MediaQuery.of(context).orientation;
    bool isPortrait = (orientation == Orientation.portrait) ? true : false;

    if (isPortrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    Widget calendarBody = isYearSelected!
        ? SizedBox(
            height: screenHeight * (isPortrait ? 0.29 : 0.55),
            child: DatePicker(
              minYear: widget.minYear,
              maxYear: widget.maxYear,
              initialDateTime: _selectedDate!,
              onMonthYearChanged: (value) {
                _selectedDate = DateTime(
                    value.year,
                    value.month,
                    _selectedDate!.day,
                    _selectedDate!.hour,
                    _selectedDate!.minute);
                returnDate = _selectedDate;
                setState(() {});
              },
            ),
          )
        : isTimeSelected!
            ? SizedBox(
                height: screenHeight * (isPortrait ? 0.29 : 0.55),
                child: TimePicker(
                  initialDateTime: _selectedDate!,
                  onDateTimeChanged: (value) {
                    _selectedDate = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        value.hour,
                        value.minute);
                    isAM = _selectedDate!.hour < 12;
                    returnDate = _selectedDate;
                    setState(() {});
                    print("value===-------===$value");
                  },
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: 7, // 7 days a week, 6 weeks maximum
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: Text(
                            Constants.weekDayName[index].toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: widget.headingColor ??
                                    Colors.grey.shade400),
                          ),
                        );
                      },
                    ),
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: 7 * 6, // 7 days a week, 6 weeks maximum
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1,
                        crossAxisCount: 7,
                      ),
                      itemBuilder: (context, index) {
                        final day = index -
                            DateTime(_selectedDate!.year, _selectedDate!.month,
                                    1)
                                .weekday +
                            2;

                        return GestureDetector(
                          onTap: () {
                            if (day > 0 &&
                                day <=
                                    DateTime(_selectedDate!.year,
                                            _selectedDate!.month + 1, 0)
                                        .day) {
                              setState(() {
                                _selectedDate = DateTime(
                                    _selectedDate!.year,
                                    _selectedDate!.month,
                                    day,
                                    _selectedDate!.hour,
                                    _selectedDate!.minute);
                                returnDate = _selectedDate;
                              });
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: day <= 0 ||
                                        day >
                                            DateTime(_selectedDate!.year,
                                                    _selectedDate!.month + 1, 0)
                                                .day
                                    ? Colors.transparent
                                    : _isSelectedDay(day)
                                        ? (widget.selectedColor ?? Colors.blue)
                                            .withOpacity(0.1)
                                        : Colors.transparent,
                                shape: BoxShape.circle),
                            child: Text(
                              day <= 0 ||
                                      day >
                                          DateTime(_selectedDate!.year,
                                                  _selectedDate!.month + 1, 0)
                                              .day
                                  ? ''
                                  : '$day',
                              style: TextStyle(
                                fontWeight: _isSelectedDay(day)
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: (_isSelectedDay(day) ||
                                        day == DateTime.now().day)
                                    ? (widget.selectedColor ?? Colors.blue)
                                    : widget.fontColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );

    List<Widget> topArrowBody = [
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              isTimeSelected = false;
              isYearSelected = !isYearSelected!;
              setState(() {});
            },
            child: Text(
              "${monthNames[_selectedDate!.month - 1]} ${_selectedDate!.year}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: widget.headingColor),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Icon(
            isYearSelected!
                ? Icons.keyboard_arrow_down_rounded
                : Icons.arrow_forward_ios_rounded,
            color: widget.iconColor ?? Colors.blue,
            size: isYearSelected! ? 30 : 15,
          ),
          Expanded(child: Container()),
          if (!isYearSelected!) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedDate =
                      _selectedDate?.subtract(const Duration(days: 30));
                  returnDate = _selectedDate;
                });
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: widget.iconColor ?? Colors.blue,
                size: 15,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate?.add(const Duration(days: 30));
                  returnDate = _selectedDate;
                });
              },
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: widget.iconColor ?? Colors.blue,
                size: 15,
              ),
            ),
          ]
        ],
      ),
      if (isPortrait)
        const SizedBox(
          height: 10,
        ),
    ];

    List<Widget> pickTimeBody = [
      Text(
        "Time",
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: widget.headingColor),
      ),
      if (isPortrait) Expanded(child: Container()),
      if (!isPortrait) Container(height: screenHeight * 0.1),
      GestureDetector(
        onTap: () {
          isTimeSelected = !isTimeSelected!;
          isYearSelected = false;
          setState(() {});
        },
        child: Container(
          height: 40,
          width: screenWidth * (isPortrait ? 0.25 : 0.3),
          decoration: BoxDecoration(
              color: (widget.barColor ?? Colors.grey.shade300),
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              // child: Text("${_selectedDate.hour}:${_selectedDate.minute}",
              child: FittedBox(
                child: Text(
                  _selectedDate!.format12Hour(),
                  style: TextStyle(
                      color: widget.barColor != null ? widget.fontColor : null,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 3),
                ),
              ),
            ),
          ),
        ),
      ),
      // if (!widget.use24hFormat!)
      ...[
        if (isPortrait) SizedBox(width: screenWidth * 0.02),
        if (!isPortrait) Container(height: screenHeight * 0.1),
        Container(
          height: 40,
          width: screenWidth * (isPortrait ? 0.32 : 0.3),
          decoration: BoxDecoration(
              color: widget.barColor ?? Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: isTimeSelected!
                          ? null
                          : () {
                              isAM = !isAM!;
                              _selectedDate = DateTime(
                                  _selectedDate!.year,
                                  _selectedDate!.month,
                                  _selectedDate!.day,
                                  isAM!
                                      ? _selectedDate!.hour % 12 == 0
                                          ? 12
                                          : _selectedDate!.hour % 12
                                      : _selectedDate!.hour + 12,
                                  _selectedDate!.minute);
                              returnDate = _selectedDate;
                              setState(() {});
                            },
                      child: Container(
                        // height: 40,
                        // width: screenWidth * 0.14,
                        decoration: BoxDecoration(
                            color: isAM!
                                ? widget.barForegroundColor ?? Colors.white
                                : null,
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              "AM",
                              style: TextStyle(
                                color: widget.barForegroundColor != null
                                    ? widget.fontColor
                                    : null,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Expanded(
                    child: GestureDetector(
                      onTap: isTimeSelected!
                          ? null
                          : () {
                              isAM = !isAM!;
                              _selectedDate = DateTime(
                                  _selectedDate!.year,
                                  _selectedDate!.month,
                                  _selectedDate!.day,
                                  isAM!
                                      ? _selectedDate!.hour % 12 == 0
                                          ? 12
                                          : _selectedDate!.hour % 12
                                      : _selectedDate!.hour + 12,
                                  _selectedDate!.minute);
                              returnDate = _selectedDate;
                              setState(() {});
                            },
                      child: Container(
                        // height: 40,
                        // width: screenWidth * 0.14,
                        decoration: BoxDecoration(
                            color: !isAM!
                                ? widget.barForegroundColor ?? Colors.white
                                : null,
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              "PM",
                              style: TextStyle(
                                color: widget.barForegroundColor != null
                                    ? widget.fontColor
                                    : null,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]
    ];

    return WillPopScope(
      onWillPop: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        Navigator.pop(context, returnDate);
        return Future.value(true);
      },
      child: Dialog(
        backgroundColor: widget.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: EdgeInsets.symmetric(horizontal: isPortrait ? 20 : 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15.0,
          ),
          child: isPortrait
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Upper Section
                      ...topArrowBody,
                      calendarBody,
                      // Lower Section
                      const Divider(
                        thickness: 0.5,
                      ),
                      Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: pickTimeBody),
                    ],
                  ),
                )
              : SizedBox(
                  width: screenWidth * 0.7,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...topArrowBody,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                // height: screenHeight * 0.57,
                                // width: screenWidth / 3,
                                child: calendarBody),
                            // const Spacer(),
                            Expanded(
                                // height: screenHeight * 0.57,
                                // width: screenWidth / 3,
                                child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: pickTimeBody,
                              ),
                            )),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  bool _isSelectedDay(int day) {
    return _selectedDate!.day == day;
  }
}

extension DateTimeExtension on DateTime {
  String format12Hour() {
    // Convert hour to 12-hour format
    int hour12 = (hour % 12 == 0 ? 12 : hour % 12);
    // int hour12 = use24HoursFormat! ? hour : (hour % 12 == 0 ? 12 : hour % 12);

    // Add leading zero for single-digit hours
    String hourString = hour12 < 10 ? '0$hour12' : '$hour12';

    // Add leading zero for single-digit minutes
    String minuteString = minute < 10 ? '0$minute' : '$minute';

    // Return formatted time
    return '$hourString:$minuteString';
  }
}
