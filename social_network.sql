/* Introduction to SQL Stanford Social network query exercise
Students at your hometown high school have decided to organize their social network using databases. 
So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema: 

Highschooler ( ID, name, grade ) 
English: There is a high school student with unique ID and a given first name in a certain grade. 

Friend ( ID1, ID2 ) 
English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123). 

Likes ( ID1, ID2 ) 
English: The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual, 
so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present. 

Your queries will run over a small data set conforming to the schema. View the database. (You can also download the schema and data.) 

For your convenience, here is a graph showing the various connections between the students in our database. 
9th graders are blue, 10th graders are green, 11th graders are yellow, and 12th graders are purple. 
Undirected black edges indicate friendships, and directed red edges indicate that one student likes another student.

Highschooler
ID	name	grade
1510	Jordan	9
1689	Gabriel	9
1381	Tiffany	9
1709	Cassandra	9
1101	Haley	10
1782	Andrew	10
1468	Kris	10
1641	Brittany	10
1247	Alexis	11
1316	Austin	11
1911	Gabriel	11
1501	Jessica	11
1304	Jordan	12
1025	John	12
1934	Kyle	12
1661	Logan	12

Friend
ID1	ID2
1510	1381
1510	1689
1689	1709
1381	1247
1709	1247
1689	1782
1782	1468
1782	1316
1782	1304

Likes
ID1	ID2
1689	1709
1709	1689
1782	1709
1911	1247*/

-- Q1: Find the names of all students who are friends with someone named Gabriel. 
SELECT Highschooler.name FROM
(SELECT f1.ID2 ID FROM Highschooler
join friend f1 on Highschooler.ID = f1.ID1
where name = "Gabriel") s
join Highschooler 
on s.ID = Highschooler.ID

-- Q2: For every student who likes someone 2 or more grades younger than themselves, 
-- return that student's name and grade, and the name and grade of the student they like. 
select h1.name, h1.grade, h2.name, h2.grade from likes l1
join Highschooler h1 on h1.ID = l1.ID1
join Highschooler h2 on h2.ID = l1.ID2
where h1.grade - h2.grade > 1

-- Q3: For every pair of students who both like each other, return the name and grade of both students. 
-- Include each pair only once, with the two names in alphabetical order. 
Select h1.name, h1.grade, h2.name, h2.grade FROM
(select l1.ID1 ID1, l1.ID2 ID2 from likes l1
join likes l2 on l1.ID1 = l2.ID2
where l1.ID2 = l2.ID1) S
join Highschooler h1 on S.ID1 = h1.ID
JOIN Highschooler h2 on S.ID2 = h2.ID
where h1.name < h2.name

-- Q4: Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. 
-- Sort by grade, then by name within each grade. 
select name, grade from Highschooler where ID not in
(select ID1 from likes
union
select ID2 from likes)
order by grade, name

-- Q5: For every situation where student A likes student B, but we have no information about whom B likes 
-- (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
select h1.name, h1.grade, h2.name, h2.grade from
(select ID1, ID2 from likes l1
where l1.ID2 not in (select ID1 from likes l2)) S
join Highschooler h1 on S.ID1 = h1.ID
join Highschooler h2 on S.ID2 = h2.ID

-- Q6: Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 
SELECT name, grade
FROM Highschooler
WHERE ID NOT IN
(SELECT ID1
FROM Friend F1 JOIN Highschooler H1
ON H1.ID = F1.ID1
JOIN Highschooler H2
ON H2.ID = F1.ID2
WHERE H1.grade <> H2.grade)
ORDER BY grade, name

-- Q7: Find the difference between the number of students in the school and the number of different first names. 
select count(ID) - count(distinct name) from Highschooler

-- Q8: Find the name and grade of all students who are liked by more than one other student.
SELECT name, grade FROM likes 
join Highschooler on Highschooler.ID = likes.ID2
GROUP BY ID2
HAVING count(ID1)>1

-- Q9: For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.
SELECT h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade FROM
(select l1.ID1 ID1, l1.ID2 ID2, l2.ID2 ID22 from likes l1
join likes l2 on l1.ID2 = l2.ID1
where l1.ID1 <>l2.ID2) S
join Highschooler h1 on h1.ID = S.ID1
join Highschooler h2 on h2.ID = S.ID2
join Highschooler h3 on h3.ID = S.ID22

-- Q10: Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades. 
select distinct h1.name, h1.grade from friend f
join highschooler h1 on f.ID1 = h1.ID
join highschooler h2 on f.ID2 = h2.ID
where f.ID1 not in
(select f.ID1 from friend f
join highschooler h1 on f.ID1 = h1.ID
join highschooler h2 on f.ID2 = h2.ID
WHERE h1.grade = h2.grade)

-- Q11: What is the average number of friends per student? (Your result should be just one number.) 
select avg(NUM) from 
(select count(*) NUM from friend 
group by ID1)

-- Q12: Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. 
-- Do not count Cassandra, even though technically she is a friend of a friend. 
select count(*)+(select count(*) from friend f1
join friend f2 on f1.ID2 = f2.ID1
join highschooler h2 on f2.ID2 = h2.ID
join highschooler h3 on f1.ID1 = h3.ID
where h2.name = "Cassandra" and h3.name <> "Cassandra") 
from friend 
join highschooler h on friend.ID1 = h.ID
where h.name = "Cassandra"

-- Q13: Find the name and grade of the student(s) with the greatest number of friends
select name, grade from highschooler
join
(select ID1 from friend 
group by ID1
having count(ID1) = 
(select max(a) from 
(select count(*) a from friend 
group by ID1))) S
on s.ID1 = highschooler.ID