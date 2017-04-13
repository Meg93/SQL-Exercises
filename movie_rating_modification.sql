/*You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. 
There's not much data yet, but you can still try out some data modifications. Here's the schema: 

Movie ( mID, title, year, director ) 
English: There is a movie with ID number mID, a title, a release year, and a director. 

Reviewer ( rID, name ) 
English: The reviewer with ID number rID has a certain name. 

Rating ( rID, mID, stars, ratingDate ) 
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate. 

Your modifications will run over a small data set conforming to the schema. View the database. (You can also download the schema and data.) 

Instructions: You are to write each of the following data modification commands using SQL. 
Our back-end runs each modification using SQLite on the original state of the sample database. 
It then performs a query over the modified database to check whether your command made the correct modification, and restores the database to its original state. 

You may perform these exercises as many times as you like, so we strongly encourage you to keep working with them until you complete the exercises with full credit.*/
-- Q1: Add the reviewer Roger Ebert to your database, with an rID of 209.
insert into reviewer
values (209,"Roger Ebert")

-- Q2: Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL. 
insert into Rating  ( rID, mID, stars, ratingDate )
select Reviewer.rID , Movie.mID, 5, null from Movie
left outer join Reviewer
where Reviewer.name='James Cameron'

-- Q3: For all movies that have an average rating of 4 stars or higher, add 25 to the release year. 
-- (Update the existing tuples; don't insert new tuples.) 
update movie
set year = year + 25
where mID in (
  select mID from (
  select AVG(stars) as astar, mID from Rating
  group by mID
  having astar >=4)
)

-- Q4: Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
delete from rating
where mID in 
(select mID from movie 
where year < 1970 or year > 2000)
and 
rating < 4