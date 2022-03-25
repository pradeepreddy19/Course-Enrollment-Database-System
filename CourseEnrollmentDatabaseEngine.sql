CREATE TABLE p15_student(sid integer,
						sname text,
						primary key (sid));
						
CREATE TABLE p15_course (cno integer,
						 total integer,
						 max integer,
						 primary key (cno));						

CREATE TABLE p15_prerequisite( cno integer,
							   prereq integer,
							   primary key (cno, prereq),
                               foreign key (cno) references p15_course (cno),
							   foreign key (prereq) references p15_course (cno)
							 );
							
CREATE TABLE p15_HasTaken(sid integer,
						  cno integer,
						  primary key (sid,cno),
						  foreign key (sid) references p15_student (sid),
						  foreign key (cno) references p15_course (cno)
						 );			
						 
CREATE TABLE p15_Enroll(  sid integer,
						  cno integer,
						  primary key (sid,cno),
						  foreign key (sid) references p15_student (sid),
						  foreign key (cno) references p15_course (cno)
						 );	

CREATE TABLE p15_Waitlist (sid integer,
						  cno integer,
						  position integer,
						  primary key (sid,cno),
						  foreign key (sid) references p15_student (sid),
						  foreign key (cno) references p15_course (cno)
						 );	


insert into p15_student values
(1,'pradeep'),
(2, 'Kini'),
(3, 'Sheru'),
(4, 'Prajwal'),
(5, 'Bhavik'),
(6, 'Aditya'),
(7, 'Malmul');

insert into p15_course values
(551,0,5),
(552,0,3),
(553,0,5);

insert into p15_course values
(451,0,4),
(351,0,6),
(401,0, 5);

insert into p15_prerequisite values
(551, 451),
(552, 351),
(552, 401);

insert into p15_hastaken values 
(1,451),
(1,401),
(2,351),
(2,401);

--Total 3 triggers:
--1) Inserting into Enroll Relation
----a)Check if the Student has met Prerequistes
------No: Do Nothing 
------Yes:Check if the Course has still open positions
----------Yes: Enroll the student into Course and Update the Capacity-=1
----------No:  Put the student into Waitlist at the end of the queue
--2) Deleting from Enroll Relation
----Decrease the total by 1
----Check if any student is in the waitlist for this course
-------Yes:Put that student in the Enroll Relation (This will trigger the first trigger)
-----------Delete that student from Waitlist 
----------- decrease the waitlist of all other student by 1
-------No : Do Nothing

--3) Deleting from Waitlist Relation
---------Update waitlist position all the students( decrease by 1) whose position is greater than the position of the deleted student


-- Prerquiste checking trigger on Enroll Relation

CREATE or REPLACE FUNCTION P15_Prerequsite_Check(x int,y int, OUT val bool)
AS 
$$
    select False
	where exists
	(
	  (select distinct prereq from p15_prerequisite where cno=y)
	   except
	  (select distinct cno from p15_hastaken where sid=x)
	)
	
	union 
	
	select True
	where not exists
	(
	  (select distinct prereq from p15_prerequisite where cno=y)
	   except
	  (select distinct cno from p15_hastaken where sid=x)
	)
	
$$  LANGUAGE SQL;

--- Checking if the course has already met the maximum capacity

CREATE or REPLACE FUNCTION P15_Enrollment_Check(x int, OUT val bool)
AS 
$$
 	select distinct case when p.max-p.total>0 then True
					else False
					end as val
	from p15_course p
	where p.cno=x

$$  LANGUAGE SQL;




CREATE OR REPLACE FUNCTION insert_into_p15_enroll() RETURNS 
TRIGGER AS
  $$
   BEGIN
    IF (select P15_Prerequsite_Check(NEW.sid, NEW.cno)) THEN
	
		IF (select P15_Enrollment_Check(NEW.cno)) THEN
			 UPDATE p15_course set total= total+1 where cno=NEW.cno;
			 RETURN NEW;

			 ELSIF (NEW.cno) in (select distinct cno from p15_Waitlist) THEN
			 INSERT INTO p15_Waitlist VALUES (NEW.sid, NEW.cno, (select max(position)+1 from p15_Waitlist where cno=NEW.cno));
			 RETURN NULL;

			 ELSE 
			 INSERT INTO p15_Waitlist VALUES (NEW.sid, NEW.cno,1);
			 RETURN NULL;
		 
		 END IF;	 
	  RETURN NULL;
	END IF;
	RETURN NULL;
    END;
  $$ LANGUAGE 'plpgsql';
  
CREATE TRIGGER insert_into_p15_enroll_relation
BEFORE INSERT ON p15_Enroll
FOR EACH ROW
EXECUTE PROCEDURE insert_into_p15_enroll();

Select * from p15_Enroll;
select * from p15_course;
select * from p15_Waitlist;

insert into p15_Enroll values (1,551);
insert into p15_Enroll values (2,552);
insert into p15_Enroll values (3,451);
insert into p15_Enroll values (4,451);
insert into p15_Enroll values (5,451);
insert into p15_Enroll values (6,451);
insert into p15_Enroll values (7,451);

insert into p15_Student values (8,'Hanish');
insert into p15_Enroll values (8,451);

insert into p15_Student values (9,'Karthik');
insert into p15_Enroll values (9,451);

CREATE or REPLACE FUNCTION P15_Waitlist_Check(x int, OUT val bool)
AS 
$$
 	select True
	where exists (select 1 from p15_Waitlist where cno=x and position>0)
	
	union 
	
	select False
	where not exists (select 1 from p15_Waitlist where cno=x and position>0)

$$  LANGUAGE SQL;


CREATE OR REPLACE FUNCTION delete_from_p15_enroll() RETURNS 
TRIGGER AS
  $$
   BEGIN
   	UPDATE p15_Course SET total=total-1 where cno=OLD.cno;

    IF (select P15_Waitlist_Check(OLD.cno)) THEN
	
		INSERT INTO p15_Enroll Values((select pw.sid from p15_Waitlist pw where cno=OLD.cno and position=1),OLD.cno);
		DELETE FROM p15_Waitlist where cno=OLD.cno and position=1;
		UPDATE p15_Waitlist SET position=position-1 where cno=OLD.cno;
		
	END IF;	 
	  RETURN NULL;
    END;
  $$ LANGUAGE 'plpgsql';
 
CREATE TRIGGER delete_from_p15_enroll_relation
AFTER DELETE ON p15_Enroll
FOR EACH ROW
EXECUTE PROCEDURE delete_from_p15_enroll();

Select * from p15_Enroll;
select * from p15_course;
select * from p15_Waitlist;

delete from p15_Enroll where cno=551 and sid=1;
insert into p15_Enroll values (1,551); 

delete from p15_Enroll where cno=451 and sid=3;

insert into p15_Student values (10,'Charan');
insert into p15_enroll values (10, 451);

insert into p15_student values (11,'Sagar');
insert into p15_enroll values (11, 451);



CREATE OR REPLACE FUNCTION delete_from_p15_waitlist() RETURNS 
TRIGGER AS
  $$
   BEGIN
   	UPDATE p15_waitlist SET position=position-1 where cno=OLD.cno and position>old.position;
	RETURN NULL;
    END;
  $$ LANGUAGE 'plpgsql';


CREATE TRIGGER delete_from_p15_waitlist_relation
AFTER DELETE ON p15_waitlist
FOR EACH ROW
EXECUTE PROCEDURE delete_from_p15_waitlist();

Select * from p15_Enroll;
select * from p15_course;
select * from p15_Waitlist;

delete from p15_waitlist where sid=9 and cno=451;
