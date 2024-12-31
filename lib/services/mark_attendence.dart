import 'package:final_cv/Models/session_info.dart';
import 'package:final_cv/bluetooth/ble_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // For date formatting

Future<String> markAttendance(String courseId, {String sessionId = "", int timeout = 60}) async {
  // Reference to the attendance subcollection for the specified course
  CollectionReference courseAttendanceReference = FirebaseFirestore.instance.collection('Courses').doc(courseId).collection('Attendance');

  //Setting the session id-
  // print('yaha tak aagya');
  if(sessionId == ""){
    await courseAttendanceReference.get().then((QuerySnapshot querySnapshot){
      int numberOfSessions = querySnapshot.size;
      sessionId = (numberOfSessions+1).toString();
      // print('creation $sessionId');
    });
  }
  // print('yaha bhi aagya');
  
  // Get the list of all students in the course
  DocumentSnapshot courseDoc = await FirebaseFirestore.instance.collection('Courses').doc(courseId).get();
  List<String> allStudesnts = List<String>.from(courseDoc['Students Uid']);


  Map<String, dynamic> attendanceData = {};
  // reading the current data that is present in the session
  
  DocumentSnapshot sessionDoc = await courseAttendanceReference.doc(sessionId).get();
  // print(sessionId);
  if(sessionDoc.exists){
    // print(sessionDoc);
    attendanceData = sessionDoc.data() as Map<String, dynamic>;
    attendanceData['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    attendanceData['time'] = DateFormat('HH:mm:ss').format(DateTime.now());
  } else {
  // Initialize the attendance data with all students absent
    attendanceData['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    attendanceData['time'] = DateFormat('HH:mm:ss').format(DateTime.now());
    for (String studentId in allStudesnts) {
      attendanceData[studentId] = false;
    }
    // print(attendanceData);
  }

  await FirebaseFirestore.instance.collection('Courses').doc(courseId).update({'isCheckingAttendance': true});
  
  // Mark the students present
  // List<String> studentsToMarkPresent = await scanDevices(timeout: timeout);
  await FirebaseFirestore
      .instance
      .collection('Checking')
      .doc('checking')
      .delete();
  await Future.delayed(const Duration(minutes: 1));

  // List<String> studentsToMarkPresent = ['phanhuy0406'];
  List<String> studentsToMarkPresent = [];
  // Reference to the 'checking' document
  DocumentSnapshot docSnapshot = await FirebaseFirestore
      .instance
      .collection('Checking')
      .doc('checking')
      .get();

  if (docSnapshot.exists) {
    // Retrieve the 'students' array
    List<dynamic> students = docSnapshot['students'];
    studentsToMarkPresent = students.cast<String>();
    // print('Students: $checkingStudent');d
  } else {
    print('Document does not exist');
  }
  for (String studentId in studentsToMarkPresent) {
    if (allStudesnts.contains(studentId)) {
      attendanceData[studentId] = true;
    }
  }
  // Create a new document with Session Id with the attendance data
  if (sessionId == "") {
    await courseAttendanceReference.add(attendanceData).then((value) => sessionId = value.id);
    return sessionId;
  }
  await courseAttendanceReference.doc(sessionId).set(attendanceData);
  await FirebaseFirestore.instance.collection('Courses').doc(courseId).update({'isCheckingAttendance': false});
  return sessionId;
  
}