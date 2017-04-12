/* --------Stanford Introduction to SQL-----------*/
/* You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. There's not much data yet, but you can still try out some interesting queries. Here's the schema: 

Movie ( mID, title, year, director ) 
English: There is a movie with ID number mID, a title, a release year, and a director. 

Reviewer ( rID, name ) 
English: The reviewer with ID number rID has a certain name. 

Rating ( rID, mID, stars, ratingDate ) 
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate. 

Movie
mID	title	year	director
101	Gone with the Wind	1939	Victor Fleming
102	Star Wars	1977	George Lucas
103	The Sound of Music	1965	Robert Wise
104	E.T.	1982	Steven Spielberg
105	Titanic	1997	James Cameron
106	Snow White	1937	<null>
107	Avatar	2009	James Cameron
108	Raiders of the Lost Ark	1981	Steven Spielberg

Reviewer
rID	name
201	Sarah Martinez
202	Daniel Lewis
203	Brittany Harris
204	Mike Anderson
205	Chris Jackson
206	Elizabeth Thomas
207	James Cameron
208	Ashley White

Rating
rID	mID	stars	ratingDate
201	101	2	2011-01-22
201	101	4	2011-01-27
202	106	4	<null>
203	103	2	2011-01-20
203	108	4	2011-01-12
203	108	2	2011-01-30
204	101	3	2011-01-09
205	103	3	2011-01-27
205	104	2	2011-01-22
205	108	4	<null>
206	107	3	2011-01-15
206	106	5	2011-01-19
207	107	5	2011-01-20
208	104	3	2011-01-02*/

-- Q1: Find the titles of all movies directed by Steven Spielberg. 
SELECT TITLE FROM MOVIE WHERE DIRECTOR = "Steven Spielberg"

-- Q2: Some reviewers didn't provide a date with their rating. 
-- Find the names of all reviewers who have ratings with a NULL value for the date. 
SELECT name FROM Reviewer JOIN rating ON Reviewer.rID = rating.rID WHERE ratingDate is NULL

-- Q3: For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, 
-- return the reviewer's name and the title of the movie. 
select DISTINCT name, title
from Rating R1 natural join Movie natural join Reviewer
where R1.mID in
(select mID as counter from Rating R2 where R2.rID = R1.rID 
group by R2.mID having count(*) =2) 
and 
(select stars from Rating R3 
where R3.rID = R1.rID and R1.mID = R3.mID 
order by R3.ratingDate LIMIT 1) 
< 
(select stars from Rating R3 
where R3.rID = R1.rID and R1.mID = R3.mID 
order by R3.ratingDate DESC LIMIT 1);

-- Q4: For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. 
-- Sort by rating spread from highest to lowest, then by movie title.
select m.title, max(r.stars)-min(r.stars) as ratingspread 
from movie m
join rating r on m.mID = r.mID
group by m.title
order by ratingspread desc, m.title

-- Q5: Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. 
-- (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. 
-- Don't just calculate the overall average rating before and after 1980.) 
select max(twoavg)-min(twoavg) from
(select avg(cal) twoavg from 
(select avg(r.stars) cal, "before" time from rating r
join movie m on r.mID = m.mID
where m.year < 1980
group by m.mID
union all
select avg(r.stars) cal, "after" time from rating r
join movie m on r.mID = m.mID
where m.year > 1980
group by m.mID)
group by time)
/*second approach*/
select downav-upav
from (select avg(av) as upav
    from (select avg(stars) as av
      from Movie natural join Rating
      where year > 1980
      group by mID) as u ) as up,
  (select avg(av) as downav
    from (select avg(stars) as av
      from Movie natural join Rating
      where year < 1980
      group by mID) as d
) as down

-- Q6: For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 
SELECT reviewer.name, movie.title, rating.stars from rating
natural join reviewer natural join movie
where reviewer.name = movie.director

--Q7: Return all reviewer names and movie names together in a single list, alphabetized. 
-- (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 
SELECT name from 
(SELECT reviewer.name name from reviewer
UNION ALL
SELECT movie.title name from movie)
ORDER BY name

-- Q8: Find the titles of all movies not reviewed by Chris Jackson. 
SELECT movie.title FROM movie
WHERE mID NOT IN 
(SELECT mID FROM rating
NATURAL JOIN reviewer
WHERE reviewer.name = "Chris Jackson")

-- Q9: For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
-- Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 
SELECT distinct RV1.name, RV2.name FROM rating R1, rating R2, reviewer RV1, reviewer RV2
WHERE R1.mID = R2.mID and RV1.name < RV2.name and RV1.rID = R1.rID and RV2.rID = R2.rID

-- Q10: For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. 
SELECT reviewer.name, movie.title, stars 
FROM rating 
NATURAL JOIN movie NATURAL JOIN reviewer
WHERE stars = 
(SELECT min(stars) FROM rating)

-- Q11: List movie titles and average ratings, from highest-rated to lowest-rated. 
-- If two or more movies have the same average rating, list them in alphabetical order. 
SELECT movie.title, avg(stars) FROM rating
NATURAL JOIN movie NATURAL JOIN reviewer
GROUP BY movie.title
ORDER BY avg(stars) desc, movie.title

-- Q12: Find the names of all reviewers who have contributed three or more ratings.
SELECT reviewer.name From rating
NATURAL JOIN reviewer
GROUP BY rID
HAVING count(rating.rID) > 2
/*method 2. Writing the query without HAVING or without SCOUNT*/
SELECT distinct(reviewer.name) from reviewer 
join 
(SELECT reviewer.rID rID from reviewer
NATURAL JOIN rating
WHERE exists 
(SELECT * from rating R WHERE R.rID = reviewer.rID and R.ratingDate <> rating.ratingDate
and exists 
(SELECT * from rating R1 
WHERE R1.rID = reviewer.rID and ((R1.ratingDate <> rating.ratingDate and R1.ratingDate <> R.ratingDate) or R1.ratingDate is NULL)))) S
ON reviewer.rID = S.rID

-- Q13: Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, 
-- along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) 
SELECT movie.title, movie.director from movie
where movie.director in
(SELECT movie.director from movie
GROUP BY movie.director
HAVING count(movie.title) >1)
order by movie.director, movie.title

-- Q14: Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. 
-- (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) 
SELECT movie.title, avg(stars) from rating
NATURAL JOIN movie
GROUP BY mID
having avg(stars) = 
(SELECT max(onem) FROM
(SELECT mID, avg(stars) onem from rating
GROUP BY mID))

-- Q15: For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. 
-- Ignore movies whose director is NULL. 

SELECT S.direct, movie.title, S.ms from
(select movie.mID mID, movie.director direct, max(stars) ms from movie
natural join rating
group by movie.director
having movie.director is not NULL) S
JOIN movie on movie.mID = S.mID
