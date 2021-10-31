--Question 1. Find the most common industry out of all the companies that were `contacted`.
SELECT co.id AS CompanyID
  , co.industry
  ,	COUNT(DISTINCT co.id) AS Record_Count
FROM companies co
--	Left Join persons p ON p.id = (SELECT p.id FROM persons p WHERE p.company_id = co.id AND p.job_seniority NOT IN ('Individual Contributor', 'Unknown') ORDER BY p.id DESC LIMIT 1)
	Inner Join persons p ON p.company_id = co.id AND p.job_seniority NOT IN ('Individual Contributor', 'Unknown')
	Inner Join touches t ON t.person_id = p.id AND t.status = 'completed'
WHERE co.industry != ''
GROUP BY co.industry
ORDER BY Record_Count DESC
LIMIT 0,10;



--Question 2. What is the most common touch type sellers use when they’re making their first touch with a person? What about first touch with a company?
SELECT touch_type, COUNT(touch_type) AS Count FROM (
SELECT ROW_NUMBER() OVER(PARTITION BY t.person_id ORDER BY t.person_id, t.touch_scheduled_on) AS RowNum,
		t.id,
       t.person_id,
       t.touch_scheduled_on,
       t.status, 
       t.touch_type,
       p.company_id,
       p.job_seniority
FROM touches t 
	Inner Join persons p ON p.id = (SELECT p.Id FROM persons p WHERE p.id = t.person_id ORDER BY p.id LIMIT 1)
ORDER BY t.person_id, t.id 
) t
WHERE RowNum = 1
GROUP BY touch_type 
ORDER BY COUNT(touch_type) DESC

SELECT touch_type, COUNT(touch_type) AS Count FROM (
SELECT ROW_NUMBER() OVER(PARTITION BY co.id ORDER BY co.id, t.touch_scheduled_on) AS RowNum,
		t.id,
       t.person_id,
       t.touch_scheduled_on,
       t.status, 
       t.touch_type,
       p.job_seniority,
       co.id AS company_id,
       co.industry       
FROM touches t 
	Inner Join persons p ON p.id = (SELECT p.Id FROM persons p WHERE p.id = t.person_id ORDER BY p.id LIMIT 1)
	Inner Join companies co ON co.id = (SELECT co.id FROM companies co WHERE co.id = p.company_id ORDER BY co.id LIMIT 1)
ORDER BY co.id, t.id 
) t
WHERE RowNum = 1
GROUP BY touch_type 
ORDER BY COUNT(touch_type) DESC


/*Question 3. Describe the distribution of the job seniorities of people that a seller will first try to contact within a company.

To answer this question, you may use visuals, graphs, bunch of scores, tables, writeups - whatever you want. We literally want you to "describe" the distribution to us in the best way you can!
(Note: this question doesn't really have one right answer. It's more about your style of communicating the results.)*/

SELECT job_seniority, COUNT(job_seniority) AS Count FROM (
SELECT ROW_NUMBER() OVER(PARTITION BY p.id ORDER BY p.id, t.touch_scheduled_on) AS RowNum,
		t.id,
       t.person_id,
       t.touch_scheduled_on,
       t.status, 
       t.touch_type,
       p.job_seniority,
       co.id AS company_id,
       co.industry       
FROM touches t 
	Inner Join persons p ON p.id = (SELECT p.Id FROM persons p WHERE p.id = t.person_id ORDER BY p.id LIMIT 1)
	Inner Join companies co ON co.id = (SELECT co.id FROM companies co WHERE co.id = p.company_id ORDER BY co.id LIMIT 1)
ORDER BY co.id, t.id 
) t
WHERE RowNum = 1
GROUP BY job_seniority 
ORDER BY COUNT(job_seniority) DESC
 
 
 
/*Question 4. Describe the distribution of the mixture of job seniorities of people that a seller will touch during the entire engagement with a company.
Keep in mind that you get to decide what “mixture” means, so do begin your answer by defining it - and explaining why you think this definition makes sense. Again, feel free to use whatever visuals, graphs, bunch of scores, tables, writeups etc. that you think is appropriate for this question.

(Note: this question doesn't really have one right answer. It's more about your style of communicating the results.)*/

SELECT industry, job_seniority, COUNT(job_seniority) AS Mix_Count FROM (
SELECT ROW_NUMBER() OVER(PARTITION BY co.id ORDER BY co.id , t.touch_scheduled_on) AS RowNum,
		t.id,
       t.person_id,
       t.touch_scheduled_on,
       t.status, 
       t.touch_type,
       p.job_seniority, 
       co.id AS company_id,
       co.industry       
FROM touches t 
	Inner Join persons p ON p.id = (SELECT p.Id FROM persons p WHERE p.id = t.person_id ORDER BY p.id LIMIT 1)
	Inner Join companies co ON co.id = (SELECT co.id FROM companies co WHERE co.id = p.company_id AND co.industry != '' ORDER BY co.id LIMIT 1)
ORDER BY co.id, t.id
--LIMIT 0,200
) t
--WHERE RowNum = 1
GROUP BY industry, job_seniority
ORDER BY industry, COUNT(job_seniority) DESC
LIMIT 0,200
