class TimeTableItem {
  final String courseCode;     
  final String courseName;     
  final String professor;      
  final String day;           
  final String startTime;      
  final String endTime;  
  final String room;      
  final int credit;            

  TimeTableItem({
    required this.courseCode,
    required this.courseName,
    required this.professor,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.credit,
  });
}
