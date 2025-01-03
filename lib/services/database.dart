import 'package:final_cv/Models/course_info_model.dart';
import 'package:final_cv/Models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final User user;

  Database({required this.user});

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  final CollectionReference courseCollection = FirebaseFirestore.instance.collection('Courses');

  Future<int> isRegistered() async {
    // return 0 if the user is not registered, 1 if the user is a teacher, 2 if the user is a student
    DocumentSnapshot doc1 = await usersCollection.doc(user.uid).get();
    DocumentSnapshot doc2 = await usersCollection.doc(user.email!.substring(0, 11)).get();
    int Teacher = 0;
    if (doc1.exists) {
      Teacher = 1;
    } else if (doc2.exists) {
      Teacher = 2;
    }
    return Teacher;
  }

  Future<void> updateUserNameInDatabase(String newName) async{
    DocumentSnapshot doc1 = await usersCollection.doc(user.uid).get();
    DocumentSnapshot doc2 = await usersCollection.doc(user.email!.substring(0, 11)).get();
    if(doc1.exists){
      await usersCollection.doc(user.uid).update({
        'Name': newName
      });
      List<String> teachingCoursesId = List<String>.from(doc1['teachingCoursesId']);
      for (String courseId in teachingCoursesId){
        await courseCollection.doc(courseId).update({
          'Instructor Name' : newName
        });
      }
    } else if(doc2.exists){
      await usersCollection.doc(user.email!.substring(0, 11)).update({
        'Name': newName
      });
    }
  }

  // Checks if the user is a teacher
  Future<bool> isTeacher() async {
    final User user = this.user;
    DocumentSnapshot doc = await usersCollection.doc(user.uid).get();
    if (!doc.exists) {
      return false;
    }
    return doc['isTeacher'];
  }

  // Sets up the teacher's collection for a new user
  void setTeachersCollection() async {
    return await usersCollection.doc(user.uid).set({
      'Name': user.displayName ?? "",
      'email': user.email!,
      'isTeacher': true,
      'teachingCoursesId': [],
      'studyingCoursesId' : []
    });
  }

  // Sets up the student's collection for a new user
  void setStudentsCollection() async{
    return await usersCollection.doc(user.email!.substring(0, 11)).set({
      'Name': user.displayName ?? "",
      'email': user.email!,
      'isTeacher': false,
      'teachingCoursesId' : [],
      'studyingCoursesId' : []
    });
  }

  // Adds a new course to the database and modifies the teachingCoursesId of the teacher
  Future<void> addCourse(Course course) async{
    DocumentReference courseRef =  await courseCollection.add({
      'Title': course.courseTitle,
      'Code': course.courseCode,
      'Academic Year': course.academicYear,
      'Instructor Name': course.instructorName,
      'Instructor Uid': course.instructorUid,
      'Students Uid': [],
      'isCheckingAttendance' : false,
      'image': course.image
    });
    String courseId = courseRef.id;
    DocumentSnapshot doc = await usersCollection.doc(user.uid).get();
    List<String> teachingCoursesId = List<String>.from(doc['teachingCoursesId']);
    teachingCoursesId.add(courseId);
    await usersCollection.doc(user.uid).update({'teachingCoursesId' : teachingCoursesId});
  }

  // Retrieves the courses of the current user
  Future<List<Course>> getUserCourses() async {
    bool isTeacher = await this.isTeacher();
    List<Course> courses = [];

    if (isTeacher) {
      List<String> teachingCoursesId = [];
      DocumentSnapshot doc = await usersCollection.doc(user.uid).get();
      teachingCoursesId = List<String>.from(doc['teachingCoursesId']);
      for (String courseId in teachingCoursesId) {
        DocumentSnapshot courseDoc = await courseCollection.doc(courseId).get();
        courses.add(Course(
            courseTitle: courseDoc['Title'],
            courseCode: courseDoc['Code'],
            instructorName: courseDoc['Instructor Name'],
            academicYear: courseDoc['Academic Year'],
            instructorUid: courseDoc['Instructor Uid'],
            image: courseDoc['image'],
            isCheckingAttendance : courseDoc['isCheckingAttendance'],
            courseReferenceId: courseId
        ));
      }
    } else {
      List<String> studyingCoursesId = [];
      DocumentSnapshot doc = await usersCollection.doc(user.email!.substring(0, 11)).get();
      studyingCoursesId = List<String>.from(doc['studyingCoursesId']);
      for (String courseId in studyingCoursesId) {
        DocumentSnapshot courseDoc = await courseCollection.doc(courseId).get();
        courses.add(Course(
            courseTitle: courseDoc['Title'],
            courseCode: courseDoc['Code'],
            instructorName: courseDoc['Instructor Name'],
            academicYear: courseDoc['Academic Year'],
            instructorUid: courseDoc['Instructor Uid'],
            image: courseDoc['image'],
            isCheckingAttendance : courseDoc['isCheckingAttendance'],
            courseReferenceId: courseId
        ));
      }
    }
    return courses;
  }

  // Joins a user to a course and modifies the studyingCoursesId of the student
  Future<void> joinCourse(String courseId) async {
    DocumentSnapshot doc = await courseCollection.doc(courseId).get();
    print(doc.data().toString());
    List<String> studentsUid = List<String>.from(doc['Students Uid']);
    if (studentsUid.contains(user.email!.substring(0, 11))) {
      return;
    }
    studentsUid.add(user.email!.substring(0, 11));
    List<String> studyingCoursesId = [];
    DocumentSnapshot userDoc = await usersCollection.doc(user.email!.substring(0, 11)).get();
    studyingCoursesId = List<String>.from(userDoc['studyingCoursesId']);
    studyingCoursesId.add(courseId);
    await usersCollection.doc(user.email!.substring(0, 11)).update({'studyingCoursesId' : studyingCoursesId});
    return await courseCollection.doc(courseId).update({
      'Students Uid': studentsUid
    });
  }

  // Add student to a course manually by teacher
  Future<void> addStudentToCourse(String studentEntryNumber, String courseId) async {
    final courseDocumentSnapshot = await courseCollection.doc(courseId).get();
    final courseData = courseDocumentSnapshot.data() as Map<String, dynamic>;
    List<String> studentsUidList = courseData['Students Uid'].cast<String>();
    if(studentsUidList.contains(studentEntryNumber)){
      return ;
    } // to avoid duplication of entries

    final studentDocumentSnapshot = await usersCollection.doc(studentEntryNumber).get();
    if(studentDocumentSnapshot.exists){
      final studentData = studentDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studyingCoursesId = studentData['studyingCoursesId'].cast<String>();
      studyingCoursesId.add(courseId);
      await usersCollection.doc(studentEntryNumber).update({
        'studyingCoursesId': studyingCoursesId
      }); // updates the studyingCoursesId of the student in usersCollection

      studentsUidList.add(studentEntryNumber);
      await courseCollection.doc(courseId).update({
        'Students Uid' : studentsUidList
      }); // updates the studentsNameList and studentsUidList in the Course document
    }
  }

  // Remove student from a course manually by teacher
  Future<void> removeStudentFromCourse(String studentEntryNumber, String courseId) async {
    final courseDocumentSnapshot = await courseCollection.doc(courseId).get();
    final courseData = courseDocumentSnapshot.data() as Map<String, dynamic>;
    List<String> studentsUidList = courseData['Students Uid'].cast<String>();
    if(!(studentsUidList.contains(studentEntryNumber))){
      return ;
    }

    final studentDocumentSnapshot = await usersCollection.doc(studentEntryNumber).get();
    if(studentDocumentSnapshot.exists){
      final studentData = studentDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studyingCoursesId = studentData['studyingCoursesId'].cast<String>();
      studyingCoursesId.remove(courseId);
      await usersCollection.doc(studentEntryNumber).update({
        'studyingCoursesId': studyingCoursesId
      }); // updates the studyingCoursesId of the student in usersCollection

      studentsUidList.remove(studentEntryNumber);
      await courseCollection.doc(courseId).update({
        'Students Uid' : studentsUidList
      }); // removes the student's info from Students Name and Students Uid list of Course database
    }
  }

  // Teacher deletes a course from the database
  Future<void> deleteCourse(String courseId) async {
    final courseDocumentSnapshot = await courseCollection.doc(courseId).get();
    final courseData = courseDocumentSnapshot.data() as Map<String, dynamic>;

    List<String> studentsUidList = courseData['Students Uid'].cast<String>();
    for (String studentId in studentsUidList){
      final studentDocumentSnapshot = await usersCollection.doc(studentId).get();
      final studentData = studentDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studyingCoursesId = studentData['studyingCoursesId'].cast<String>();
      studyingCoursesId.remove(courseId);
      await usersCollection.doc(studentId).update({
        'studyingCoursesId': studyingCoursesId
      }); // updates the studyingCoursesId of the student in usersCollection
    } // deletes the courseId from the studyingCoursesId of all the students in the Course

    final teacherDocumentSnapshot = await usersCollection.doc(user.uid).get();
    final teacherData = teacherDocumentSnapshot.data() as Map<String, dynamic>;
    List<String> teachingCoursesId = teacherData['teachingCoursesId'].cast<String>();
    teachingCoursesId.remove(courseId);
    await usersCollection.doc(user.uid).update({
      'teachingCoursesId': teachingCoursesId
    }); // removes the courseId from teacher's teachingCoursesId

    await courseCollection.doc(courseId).delete(); // deletes the entire course document from the courseCollection
  }

  // User leaves a course
  Future<void> studentLeaveCourse(String courseId) async {
    final userDocumentSnapshot = await usersCollection.doc(user.email!.substring(0, 11)).get();
    if(userDocumentSnapshot.exists) {
      final userData = userDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studyingCoursesId = userData['studyingCoursesId'].cast<String>();
      studyingCoursesId.remove(courseId);
      await usersCollection.doc(user.email!.substring(0, 11)).update({'studyingCoursesId' : studyingCoursesId});
    } // removes courseId from the user's studying course's id

    final courseDocumentSnapshot = await courseCollection.doc(courseId).get();
    if(courseDocumentSnapshot.exists){
      final courseData = courseDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studentsUidList = courseData['Students Uid'].cast<String>();

      studentsUidList.remove(user.email!.substring(0, 11));
      await courseCollection.doc(courseId).update({
        'Students Uid' : studentsUidList
      }); // removes the student's info from Students Name and Students Uid list of Course database
    }
  }

  // Deletes the user from the database 
  Future<void> deleteUser() async {
    DocumentSnapshot doc1 = await usersCollection.doc(user.uid).get();
    DocumentSnapshot doc2 = await usersCollection.doc(user.email!.substring(0, 11)).get();
    
    if (doc1.exists) { // means user is a teacher
      List<String> teachingCoursesId = List<String>.from(doc1['teachingCoursesId']);
      for (String courseId in teachingCoursesId){
        await deleteCourse(courseId);
      }  
      await usersCollection.doc(user.uid).delete();
    } 
    else if (doc2.exists) { // means user is a student
      List<String> studyingCoursesId = List<String>.from(doc2['studyingCoursesId']);
      for(String courseId in studyingCoursesId){
        await studentLeaveCourse(courseId);
      }
      await usersCollection.doc(user.email!.substring(0, 11)).delete();
    }
  }

  Future<List<Student>> getPresentStudents(String courseId, String sessionId) async{
    DocumentSnapshot todayAttendenceDocumentSnapshot= await courseCollection.doc(courseId).collection('Attendance').doc(sessionId).get();
    DocumentSnapshot courseSnapshot = await courseCollection.doc(courseId).get();

    List<String> studentsUidList = List<String>.from(courseSnapshot['Students Uid']);
    Map<String, dynamic> todayAttendenceData = todayAttendenceDocumentSnapshot.data() as Map<String, dynamic>;

    List<Student> presentStudents = [];
    for(String studentUid in studentsUidList){
      if(todayAttendenceData[studentUid] == true){
        presentStudents.add(Student(entryNumber: studentUid, isPresent: true));
      } else {
        presentStudents.add(Student(entryNumber: studentUid, isPresent: false));
      }
    }
    return presentStudents;
  }

  Future<void> markstudentInCourseOnSession(String courseId, String sessionId, String studentEntryNumber, bool markPresent) async {
    DocumentSnapshot todayAttendenceDocumentSnapshot= await courseCollection.doc(courseId).collection('Attendance').doc(sessionId).get();
    Map<String, dynamic> todayAttendenceData = todayAttendenceDocumentSnapshot.data() as Map<String, dynamic>;
    todayAttendenceData[studentEntryNumber] = markPresent;
    await courseCollection.doc(courseId).collection('Attendance').doc(sessionId).update(todayAttendenceData);
  }

  Future<bool> isStudentPresentInCourseOnSession(String courseId, String sessionId) async {
    DocumentSnapshot todayAttendenceDocumentSnapshot= await courseCollection.doc(courseId).collection('Attendance').doc(sessionId).get();
    if (!todayAttendenceDocumentSnapshot.exists) {
      return false;
    }
    Map<String, dynamic> todayAttendenceData = todayAttendenceDocumentSnapshot.data() as Map<String, dynamic>;
    if (todayAttendenceData[user.email!.substring(0, 11)] == true) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getStudentStats(String courseId) async {
    // returns the stats of a particular student
    CollectionReference attendanceCollection = courseCollection.doc(courseId).collection('Attendance');
    int totalAttendance = 0;
    int presentCount = 0;
    int absentCount = 0;
    await attendanceCollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data[user.email!.substring(0, 11)] == true) {
          presentCount++;
        } else {
          absentCount++;
        }
        totalAttendance++;
      });
    });
    
    Map<String, dynamic> studentStats = {};
    
    studentStats['totalCount'] = totalAttendance;
    studentStats['presentCount'] = presentCount;
    studentStats['absentCount'] = absentCount;

    CollectionReference marksCollection = courseCollection.doc(courseId).collection('Marks');
    Map<String, dynamic> maxMarks = {};
    DocumentSnapshot maxMarksDoc = await marksCollection.doc('max').get();
    if(maxMarksDoc.exists){
      maxMarks = maxMarksDoc.data() as Map<String, dynamic>;
    }

    DocumentSnapshot studentMarksDocument = await marksCollection.doc(user.email!.substring(0, 11)).get();
    if (studentMarksDocument.exists) {
      studentStats['Marks'] = studentMarksDocument.data() as Map<String, dynamic>;
      studentStats['Marks'].forEach((key, value) {
        studentStats['Marks'][key] = '$value / ${maxMarks[key]}';
       });
    } else {
      studentStats['Marks'] = {'No Marks Available': ''};
    }
    // print(studentStats['Marks']);
    return studentStats;
  }

  Future<List<Student>> getAllStudentsdata(String courseId) async {
    List<String> studentsUidList = [];
    await courseCollection.doc(courseId).get().then((courseDocumentSnapshot){
      studentsUidList = List<String>.from(courseDocumentSnapshot['Students Uid']);
    });
    Map<String, int> studentAttendence = {};
    for (String studentUid in studentsUidList) {
      studentAttendence[studentUid] = 0;
    }
    CollectionReference attendanceCollection = courseCollection.doc(courseId).collection('Attendance');
    await attendanceCollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> SessionData = doc.data() as Map<String, dynamic>;
        for (String studentUid in studentsUidList) {
          if (SessionData[studentUid] == true) {
            studentAttendence[studentUid] = studentAttendence[studentUid]! + 1;
          }
        }
      });
    });

    Map<String, String> studentNames = {};
    for (String StudentId in studentsUidList) {
      DocumentSnapshot studentDocumentSnapshot = await usersCollection.doc(StudentId).get();
      studentNames[StudentId] = studentDocumentSnapshot['Name'];
    }

    Map<String, dynamic> studentMarks = {};
    CollectionReference marksCollection = courseCollection.doc(courseId).collection('Marks');
    await marksCollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        studentMarks[doc.id] = doc.data() as Map<String, dynamic>;
      });
    });

    List<Student> allStudents = [];
    for (String studentUid in studentsUidList) {
      allStudents.add(Student(
        entryNumber: studentUid,
        name: studentNames[studentUid] ?? "",
        totalAttendance: studentAttendence[studentUid] ?? 0,
        marks: studentMarks[studentUid] ?? {'No Quiz Marks Available': ''},
      ));
    }

    return allStudents;
  }
}