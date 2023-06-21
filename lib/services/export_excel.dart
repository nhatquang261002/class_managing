import 'package:excel/excel.dart';
import 'package:study_work_grading_web_based/models/class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_work_grading_web_based/models/group.dart';

void saveExcel(Class desiredClass) async {
  var excel = Excel.createExcel();

  Sheet sheetObject = excel['Sheet1'];

  CellStyle head = CellStyle(
      backgroundColorHex: '#ffde14',
      bold: true,
      horizontalAlign: HorizontalAlign.Right);

  CellStyle body = CellStyle(horizontalAlign: HorizontalAlign.Right);

  // Class $classID at A1
  var headline = sheetObject.cell(CellIndex.indexByString('A1'));
  headline.value = "Class ${desiredClass.classID}";

  // Subject $subjectName at A2
  var headline2 = sheetObject.cell(CellIndex.indexByString('A2'));
  headline2.value = "Subject ${desiredClass.subjectName}";

  // Teacher $teacherName at A3
  var teacherData = await FirebaseFirestore.instance
      .collection('users')
      .doc(desiredClass.classTeacherEmail)
      .get();
  var headline3 = sheetObject.cell(CellIndex.indexByString('A3'));
  headline3.value = "Teacher ${teacherData.data()!['name']}";

  // get studentID at beginning at column A5, name at beginning of B5, group beginning of c5 and score at beginning of D5
  var studentIDCell = sheetObject.cell(CellIndex.indexByString('A5'));
  studentIDCell.value = "Student-ID";
  studentIDCell.cellStyle = head;

  var nameCell = sheetObject.cell(CellIndex.indexByString('B5'));
  nameCell.value = "Full Name";
  nameCell.cellStyle = head;

  var groupCell = sheetObject.cell(CellIndex.indexByString('C5'));
  groupCell.value = "Group";
  groupCell.cellStyle = head;

  var scoreCell = sheetObject.cell(CellIndex.indexByString('D5'));
  scoreCell.value = "AVG Score";
  scoreCell.cellStyle = head;

  List<Group> classGroups = [];
  List<String> queueStudents = desiredClass.classStudents;

  // get all the Groups and save to classGroups
  await FirebaseFirestore.instance
      .collection('classes')
      .doc(desiredClass.classID.toString())
      .collection('classGroups')
      .orderBy('groupName')
      .get()
      .then((value) {
    for (int i = 0; i < value.docs.length; i++) {
      Map<String, List<dynamic>> students =
          Map.from(value.docs.elementAt(i).data()['students']);
      classGroups
          .add(Group(value.docs.elementAt(i).data()['groupName'], students));
    }
  });

  // export all the students in all the groups
  var pos = 5;
  for (int i = 0; i < classGroups.length; i++) {
    var students = classGroups.elementAt(i).students;

    for (int j = 0; j < students.length; j++) {
      var studentData = await FirebaseFirestore.instance
          .collection('users')
          .doc(students.keys.elementAt(j))
          .get();

      var idCell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: pos));
      idCell.value = studentData.data()!['id'];
      idCell.cellStyle = body;

      var nameCell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: pos));
      nameCell.value = studentData.data()!['name'];
      nameCell.cellStyle = body;

      var groupNameCell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: pos));
      groupNameCell.value = classGroups.elementAt(i).groupName;
      groupNameCell.cellStyle = body;

      if (students.values.elementAt(j).isNotEmpty) {
        var scoreCell = sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: pos));
        scoreCell.value = avgScore(students.values.elementAt(j));
        scoreCell.cellStyle = body;
      }
      queueStudents.remove(students.keys.elementAt(j));
      pos++;
    }
  }

  // export the students not in any group
  for (int i = 0; i < queueStudents.length; i++) {
    var studentData = await FirebaseFirestore.instance
        .collection('users')
        .doc(queueStudents[i])
        .get();

    var idCell = sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: pos));
    idCell.value = studentData.data()!['id'];
    idCell.cellStyle = body;

    var nameCell = sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: pos));
    nameCell.value = studentData.data()!['name'];
    nameCell.cellStyle = body;
    pos++;
  }

  excel.save(fileName: 'Class_${desiredClass.classID}.xlsx');
}

double avgScore(List<dynamic> scores) {
  double sum = 0;
  for (int i = 0; i < scores.length; i++) {
    sum += scores[i];
  }
  return (sum / scores.length);
}
