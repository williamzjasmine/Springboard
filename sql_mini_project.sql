/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT *
FROM country_club.Facilities
WHERE membercost > 0

/* 
Facilities that charge a fee for members:
	- Squash Court
	- Tennis Court 1 
	- Tennis Court 2
	- Massage Room 1
	- Massage Room 2
*/

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name) as ' # of Facilities Not Free For Members'
FROM country_club.Facilities
WHERE membercost = 0

-- 4 facilities are not free for members. 

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid AS "Facility ID",
	   name AS "Facility Name",
	   membercost AS "Member Cost",
	   monthlymaintenance AS "Monthly Maintenance Cost"
FROM country_club.Facilities
WHERE membercost > 0 
AND membercost < 0.2 * monthlymaintenance

-- All of the facilities from question 1 fit this criteria 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities
WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name AS "Facility Name",
	   monthlymaintenance AS "Cost of Monthly Maintenance",
	   CASE WHEN monthlymaintenance > 100 THEN 'Expensive'
			ELSE 'Cheap' END as "Cheap or Expensive?"
FROM country_club.Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname AS "First Name",
	   surname AS "Surname"
FROM country_club.Members
WHERE memid = (
	  SELECT MAX(memid)
	  FROM country_club.Members)

-- This works since the memid goes up by 1 each time a new member joins. 

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT CONCAT(m_tab.surname, ", ", m_tab.firstname) AS "Name",
	   f_tab.name AS "Tennis Court Used"
FROM country_club.Bookings b_tab
INNER JOIN country_club.Facilities f_tab ON b_tab.facid = f_tab.facid
INNER JOIN country_club.Members m_tab ON b_tab.memid = m_tab.memid
WHERE b_tab.facid IN (0, 1)
GROUP BY 1,2
ORDER BY 1


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f_tab.name AS  "Facility Name",
	   CONCAT( m_tab.surname,  ", ", m_tab.firstname ) AS "Name", 
	   CASE WHEN b_tab.memid = 0 THEN f_tab.guestcost * b_tab.slots
			ELSE f_tab.membercost * b_tab.slots END AS "Cost"
FROM country_club.Bookings b_tab
JOIN country_club.Members m_tab ON b_tab.memid = m_tab.memid
JOIN country_club.Facilities f_tab ON b_tab.facid = f_tab.facid
WHERE b_tab.starttime LIKE '2012-09-14%'
HAVING Cost > 30
ORDER BY 3 DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT subq.facilname AS "Facility Name",
	   subq.fullname AS "Name",
	   subq.totalcost AS "Cost"
FROM (

	SELECT f_tab.name AS facilname,
	   	   CONCAT( m_tab.surname,  ", ", m_tab.firstname ) AS fullname, 
	       CASE WHEN b_tab.memid = 0 THEN f_tab.guestcost * b_tab.slots
			    ELSE f_tab.membercost * b_tab.slots END AS totalcost
	FROM country_club.Bookings b_tab
	JOIN country_club.Members m_tab ON b_tab.memid = m_tab.memid
	JOIN country_club.Facilities f_tab ON b_tab.facid = f_tab.facid
	WHERE b_tab.starttime LIKE '2012-09-14%'
	) subq

WHERE subq.totalcost > 30
ORDER BY 3 DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT f_tab.name AS  "Facility Name", 
	   SUM(CASE WHEN b_tab.memid = 0 THEN f_tab.guestcost * b_tab.slots
			ELSE f_tab.membercost * b_tab.slots END) AS "Revenue"
FROM country_club.Bookings b_tab
JOIN country_club.Members m_tab ON b_tab.memid = m_tab.memid
JOIN country_club.Facilities f_tab ON b_tab.facid = f_tab.facid
GROUP BY 1
HAVING Revenue < 1000
ORDER BY Revenue DESC
