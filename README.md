# Course-Enrollment-Database-System
## Description
Implemented a course enrollment service in pl/PgSQL. Utilized the relational model to store a persistent waitlist/enrollment queue that maintained Student and Course information. Enforced consistency in this queue through the use of Triggers.

## Problem Statment

Consider a database with the following relations:


|Student(sid, sname)||
| - | :- |
|Prerequisite(cno, prereq)|<p>meaning: course `cno' has as a prerequisite course `prereq' cno is foreign key referencing Course</p><p>prereq is foreign key referencing Course</p>|
|HasTaken(sid,cno)|<p>meaning: student `sid' has taken course 'cno' in the past sid is foreign key referencing Student</p><p>cno is foreign key referencing Course</p>|
|Course(cno, total, max)|<p>cno is primary key</p><p>total is the current number of students enrolled in course cno max is the maximum permitted enrollment for course cno</p>|
|Enroll(sid,cno)|<p>meaning: student sid is currently enrolled in course cno sid is foreign key referencing Student</p><p>cno is foreign key referencing Course</p>|
|Waitlist(sid,cno, position)|<p>meaning: student `sid' is on the waitlist to enroll in `cno', where `pos' is the relative position of student `sid' on the waitlist</p><p>to enroll in course `cno'</p><p>sid is foreign key referencing Student</p><p>cno is foreign key referencing Course</p>|
All attributes have domain `integer', except for the attributes name and cname who have domain `text'.

The database consists of two parts:

1) A historic (i.e., before the current semester) part. The relations in red, Student, Prerequisite, and HasTaken contain data that was created in the past. This data is xed and can no longer undergo changes.
1) A current semester part. The relations in blue Course, Enroll and Waitlist, contain data that can change and that needs to be maintained (using) triggers in accordance with certain requirements:

Requirements for the relations Course, Enroll, and Waitlist: inserts and deletes into these relations are governed by the following rules (requirements):

- The attribute ` total ' is the only attribute in Course that is allowed to change. In particular, no course can be added or deleted, and the `max' enrollment value for a course can not

be changed. Initially, i.e., at the start of the semester and before any student can enroll in any course, the values for attribute `total' are all initialized to 0.

- A student can only enroll in a course if he or she has taken all the prerequisites for that course. If the enrollment succeeds, the total enrollment for that course needs to be incremented by 1.
- A student can only enroll in a course if his or her enrollment would not lead to a enrollment total for that course that exceed the maximum enrollment `max' for that course. If this happens, however, the student must be placed at the next available position (i.e., at the end of the queue) on the waitlist for that course.
- A student can drop a course, either by removing him or her- self from the Waitlist relation or from the Enroll relation. When the latter happens and if there are students on the waitlist for that course, then the student who is at the rst position (i.e., at the front of queue) for that course on the waitlist gets enrolled in that course and removed from the waitlist. If there are no students on the waitlist for that course, then the total enrollment for that course needs to decrease by 1.

Write appropriate triggers to enforce these rules. (It is assumed that you have tested your triggers for several cases.)
