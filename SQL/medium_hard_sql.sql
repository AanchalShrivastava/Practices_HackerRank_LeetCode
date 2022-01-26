JOINS

--problem: https://www.hackerrank.com/challenges/harry-potter-and-wands/problem

SELECT id, age, coins_needed, power FROM ( SELECT w.id, wp.age, coins_needed, MIN(w.coins_needed) OVER (PARTITION BY w.power, wp.age) AS min_coins, w.power FROM Wands w 
INNER JOIN Wands_Property wp ON w.code=wp.code WHERE wp.is_evil=0) sub
WHERE min_coins=coins_needed ORDER BY power DESC, age DESC;

--problem: https://www.hackerrank.com/challenges/challenges/problem

WITH data
AS
(
SELECT c.hacker_id as id, h.name as name, count(c.hacker_id) as counter
FROM Hackers h
JOIN Challenges c on c.hacker_id = h.hacker_id
GROUP BY c.hacker_id, h.name
)
/* select records from above */
SELECT id,name,counter
FROM data
WHERE
counter=(SELECT max(counter) FROM data) /*select user that has max count submission*/
OR
counter in (SELECT counter FROM data
GROUP BY counter
HAVING count(counter)=1 ) /*filter out the submission count which is unique*/
ORDER BY counter desc, id;

--problem: https://www.hackerrank.com/challenges/contest-leaderboard/problem

SELECT h.hacker_id, h.name, SUM(score) FROM (
    SELECT hacker_id, challenge_id, MAX(score) AS score FROM SUBMISSIONS
    GROUP BY hacker_id, challenge_id
)t 
JOIN Hackers h on t.hacker_id = h.hacker_id
GROUP BY h.hacker_id, h.name
HAVING SUM(score) > 0
ORDER BY SUM(score) desc, h.hacker_id ;

-- problem: https://www.hackerrank.com/challenges/draw-the-triangle-1/problem

set serveroutput on
declare
n number(2) := 20;
i number;
j number;
begin
for i in reverse 1..n
loop
for j in reverse 1..i
loop
dbms_output.put(' *');
end loop;
dbms_output.new_line;
end loop;
end;
/

-- problem: https://www.hackerrank.com/challenges/draw-the-triangle-2/problem

set serveroutput on
declare
n number(2) := 20;
i number;
j number;
begin
for i in  1..n
loop
for j in reverse 1..i
loop
dbms_output.put(' *');
end loop;
dbms_output.new_line;
end loop;
end;
/

-- problem : https://www.hackerrank.com/challenges/print-prime-numbers/problem

SET SERVEROUTPUT ON;

DECLARE
    counter NUMBER;
    k NUMBER;
    output CLOB;
BEGIN
    output := '';
    FOR n in 2..1000 LOOP
    counter := 0;
    k := floor(n/2);
    FOR i in 2..k LOOP
        IF(mod(n,i)=0) THEN
          counter :=1;
        END IF;
    END LOOP;
    IF (counter = 0) THEN
       output := output||n||'&';
    END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(SUBSTR(output,0,length(output)-1));
END;
/

-- https://www.hackerrank.com/challenges/sql-projects/problem ( understood from discussion- used TABIBITOSAN METHOD

link - https://community.oracle.com/tech/developers/discussion/4417554/pl-sql-101-grouping-sequence-ranges-tabibitosan-method

SELECT START_DATE, END_DATE FROM (SELECT START_DATE, END_DATE, END_DATE - START_DATE AS DIFF 
FROM (SELECT MIN(TEMP.START_DATE) AS START_DATE, MAX(TEMP.END_DATE) AS END_DATE FROM (SELECT START_DATE, END_DATE, 
ROW_NUMBER() OVER(ORDER BY END_DATE) ROWNUMBER, END_DATE - ROW_NUMBER() OVER (ORDER BY END_DATE) NEW_END_DATE FROM PROJECTS)
TEMP GROUP BY TEMP.NEW_END_DATE)) ORDER BY DIFF, START_DATE;

-- problem :- https://www.hackerrank.com/challenges/placements/problem?

SELECT S.Name
FROM Students S 
INNER JOIN Friends F  ON S.ID = F.ID
INNER JOIN Packages P  ON P.ID = S.ID
INNER JOIN Packages PF ON PF.ID = F.Friend_ID AND P.Salary < PF.Salary
ORDER BY PF.Salary;

-- problem :- https://www.hackerrank.com/challenges/symmetric-pairs/problem

SELECT A.x, A.y
FROM FUNCTIONS A JOIN FUNCTIONS B ON
    A.x = B.y AND A.y = B.x
GROUP BY A.x, A.y
HAVING COUNT(A.x) > 1 OR A.x < A.y
ORDER BY A.x;

-- problem :- https://www.hackerrank.com/challenges/interviews/problem

select t1.contest_id, c.hacker_id, c.name, t1.st_submissions1, t1.sta_submissions1, t1.st_views1, t1.stu_views1 from (select c.contest_id, sum(t.st_views) st_views1, sum(t.stu_views) stu_views1, sum(t.st_submissions) st_submissions1, sum(t.sta_submissions) sta_submissions1 from (select v.college_id, v.st_views, v.stu_views, s.st_submissions, s.sta_submissions from (select c.college_id, sum(v.total_views) st_views, sum(v.total_unique_views) stu_views from challenges c, view_stats v where c.challenge_id = v.challenge_id group by c.college_id) v, (select c.college_id, sum(s.total_submissions) st_submissions, sum(s.total_accepted_submissions) sta_submissions from challenges c, submission_stats s where c.challenge_id = s.challenge_id group by c.college_id) s where v.college_id=s.college_id and (v.st_views<>0 or v.stu_views<>0 or s.st_submissions<>0 or s.sta_submissions<>0)) t, 
colleges c where t.college_id=c.college_id group by c.contest_id) t1, 
contests c where t1.contest_id = c.contest_id order by t1.contest_id;


-- problem :- https://www.hackerrank.com/challenges/15-days-of-learning-sql/problem

SELECT s.submission_date ,s.unique_hackers_count ,s.hacker_id ,h.name FROM ( SELECT s.* ,COUNT(DISTINCT CASE WHEN TO_NUMBER(TO_CHAR(s.submission_date, 'DD')) = s.daily_submit_increment THEN s.hacker_id ELSE NULL END) OVER (PARTITION BY s.submission_date) unique_hackers_count ,
ROW_NUMBER() OVER(PARTITION BY s.submission_date ORDER BY s.hacker_submits DESC, s.hacker_id) row_num FROM ( SELECT submission_date ,hacker_id ,
DENSE_RANK() OVER (PARTITION BY hacker_id ORDER BY submission_date) daily_submit_increment ,
COUNT(1) OVER (PARTITION BY hacker_id, submission_date) hacker_submits FROM submissions ) s ) s ,hackers h WHERE s.hacker_id = h.hacker_id AND s.row_num = 1;