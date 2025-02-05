import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../models/occasion_model.dart';

class CustomCalendarScreen extends StatefulWidget {
  @override
  _CustomCalendarScreenState createState() => _CustomCalendarScreenState();
}

class _CustomCalendarScreenState extends State<CustomCalendarScreen> {
  List<Occasion> _occasions = [];
  DateTime _selectedMonth = DateTime.now();
  List<Occasion> _selectedOccasions = [];


  @override
  void initState() {
    super.initState();
    _loadOccasions();
  }

  void _loadOccasions() {
    // Replace this with your data loading logic
    _occasions = [
      Occasion(
        title: "زواج السيد موسى حسن",
        date: DateTime(2024, 8, 3),
        familyId: 1,
        description: "زواج السيد موسى حسن العبدالمحسن",
      ),
      Occasion(
        title: "زواج علي العبدالمحسن",
        date: DateTime(2024, 7, 3),
        familyId: 1,
        description: "يبدأ الحفل بعد صلاة العشاء",
      ),
      Occasion(
        title: "الذكري الخامسة لوفاة خالد العبدالمحسن",
        date: DateTime(2024, 7, 5),
        familyId: 1,
        description: "اجتماع لرجال العائلة في الاستراحة الخاصة بالعائلة",
      ),
      Occasion(
        title: "اجتماع لرجال العائلة",
        date: DateTime(2024, 7, 10),
        familyId: 1,
        description: "اجتماع لرجال العائلة في الاستراحة الخاصة بالعائلة لمناقشة بعض المواضيع",
      ),
    ];
  }

  List<Occasion> _getOccasionsForDay(DateTime day) {
    return _occasions.where((occasion) {
      return occasion.date.year == day.year &&
          occasion.date.month == day.month &&
          occasion.date.day == day.day;
    }).toList();
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedOccasions = _getOccasionsForDay(day);
    });
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('تفاصيل المناسبة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: _selectedOccasions.map((occasion) => ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("تاريخ المناسبة: ${occasion.date.day} / ${occasion.date.month} / ${occasion.date.year}",style: TextStyle(
                      fontSize: 18,
                    ),),
                    Text("عنوان المناسبة: ${occasion.title}",style: TextStyle(
                      fontSize: 18,
                    ),),
                  ],
                ),
                subtitle: Text("وصف المناسبة: ${occasion.description}",style: TextStyle(
                  fontSize: 16,
                ),),
              )).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('إغلاق',style: TextStyle(
                  color: Colors.black,
                ),),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCalendarDays() {
    List<Widget> days = [];

    DateTime firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    int daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    int firstWeekdayOfMonth = firstDayOfMonth.weekday;

    // Add empty widgets for days before the first day of the month
    for (int i = 1; i < firstWeekdayOfMonth; i++) {
      days.add(Container());
    }

    // Add widgets for each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDay = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      List<Occasion> occasions = _getOccasionsForDay(currentDay);

      days.add(
        GestureDetector(
          onTap: () => _onDaySelected(currentDay),
          child: Container(
            margin: const EdgeInsets.all(2.0),
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
              color: occasions.isNotEmpty ? Color(0xffE8D0B4) : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(fontSize: 16.0),
                ),
                ...occasions.map((occasion) => Text(
                  occasion.title,
                  style: TextStyle(fontSize: 10.0, color: Colors.black87),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),
        ),
      );
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقويم مناسبات العائلة'),
        centerTitle: true,
        backgroundColor: Color(0xffE8D0B4),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousMonth,
                ),
                Text(
                  intl.DateFormat.yMMMM().format(_selectedMonth),
                  style: TextStyle(fontSize: 20.0),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            padding: const EdgeInsets.all(8.0),
            children: _buildCalendarDays(),
          ),
        ],
      ),
    );
  }
}
