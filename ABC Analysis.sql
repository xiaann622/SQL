DROP TABLE Employees;
CREATE TABLE Employees
(
	employee_id VARCHAR(20) NOT NULL PRIMARY KEY,
 	full_name VARCHAR(300) NOT NULL,
 	gender VARCHAR(100) NOT NULL,
	department VARCHAR(100) NOT NULL,
	job_title VARCHAR(300) NOT NULL,
	employment_type VARCHAR(200) NOT NULL,
	location  VARCHAR(200) NOT NULL,
	hire_date DATE NOT NULL,
	 monthly_salary_bdt INT NOT NULL,
	 manager_id VARCHAR(50)
)

CREATE TABLE Performance_Review
(
	employee_id VARCHAR(50) NOT NULL ,
	review_period_start DATE NOT NULL, 
	review_period_end DATE NOT NULL,
	performance_rating INT NOT NULL,
	manager_score INT NOT NULL,
	peer_score INT NOT NULL,
	bonus_pct FLOAT NOT NULL,
	trainings_completed INT NOT NULL,
	 leaves_taken INT,
	attrition_risk VARCHAR(150)
)

 SELECT *
 FROM Employees

 SELECT *
 FROM Performance_Review

--- Ensure that employee_id in the reviews dataset matches with employee_id in the employees master dataset. 
SELECT r.employee_id
FROM Performance_Review r
LEFT JOIN Employees e 
ON r.employee_id = e.employee_id
WHERE e.employee_id IS NULL;
--- Validate that all manager IDs in the employees table exist in the same table. 
SELECT e.manager_id
FROM Employees e
LEFT JOIN employees m 
ON e.manager_id = m.employee_id
WHERE e.manager_id IS NOT NULL
AND m.employee_id IS NULL;

--- Identify missing values in columns like manager_id or location. 
SELECT *
FROM employees
WHERE 
    manager_id IS NULL
    OR location IS NULL
    OR department IS NULL
    OR job_title IS NULL;

--- Confirm that all salary values are positive. 
SELECT*
FROM Employees 
WHERE monthly_salary_bdt <= 0;

--- Verify that review dates fall within the year 2024. 
SELECT *
FROM Performance_Review
WHERE review_period_start < '2024-01-01'
   OR review_period_end > '2024-12-31';

--- Count employees by department and employment_type. Count employees by department and employment_type. 
SELECT 
    department,
    employment_type,
    COUNT(*) AS employee_count
FROM Employees
GROUP BY department, employment_type
ORDER BY department, employment_type;

--- Identify which department has the highest overall headcount.
SELECT 
    department,
    
    COUNT(*) AS employee_count
FROM Employees
GROUP BY department
ORDER BY employee_count DESC
LIMIT 1;
--- Calculate the average and median monthly_salary_bdt by department. 
SELECT 
    department,
    AVG(monthly_salary_bdt) AS avg_salary,
    PERCENTILE_CONT(1/2) WITHIN GROUP (ORDER BY monthly_salary_bdt) AS median_salary
FROM Employees
WHERE monthly_salary_bdt IS NOT NULL
GROUP BY department
ORDER BY median_salary DESC;

--- Compare salaries across location to see which branch pays higher on average. 
SELECT AVG(monthly_salary_bdt) AS salary,location
FROM Employees
GROUP BY location
ORDER BY salary DESC

--- Compute the average performance_rating by department.
SELECT 
    e.department,
    AVG(r.performance_rating) AS avg_rating
FROM employees e
JOIN Performance_Review r 
    ON e.employee_id = r.employee_id
WHERE r.performance_rating IS NOT NULL
GROUP BY e.department
ORDER BY avg_rating DESC;
--- Compare manager_score and peer_score averages to find discrepancies in evaluations. 
SELECT 
    AVG(manager_score) AS avg_manager_score,
    AVG(peer_score) AS avg_peer_score,
    AVG(manager_score) - AVG(peer_score) AS score_difference
FROM Performance_Review;

SELECT 
    e.department,
    AVG(r.manager_score) AS avg_manager_score,
    AVG(r.peer_score) AS avg_peer_score,
    AVG(r.manager_score) - AVG(r.peer_score) AS score_difference
FROM Employees e
JOIN  Performance_Review r 
    ON e.employee_id = r.employee_id
GROUP BY e.department
ORDER BY score_difference DESC;
--- INTERPRETATION
-- Departments with large positive discrepancy (Product, Marketing, HR) might have manager bias or stricter peer standards.

-- Departments with negative discrepancy (Customer Success, Sales) might indicate peer leniency or manager strictness.

---Departments with minimal difference (Engineering, Operations) → good alignment in evaluations.

--- Count employees under each attrition_risk category. 
SELECT attrition_risk,
		COUNT(*) AS EMPLOYEES_COUNT
FROM Performance_Review
GROUP BY attrition_risk
ORDER BY EMPLOYEES_COUNT DESC;



--- Break down attrition risk by department to identify problem areas.
SELECT e.department,
		r.attrition_risk,
		COUNT(*) AS EMPLOYEES_COUNT
FROM Performance_Review r
JOIN Employees e
		ON e.employee_id = r.employee_id
GROUP BY department,attrition_risk
ORDER BY EMPLOYEES_COUNT DESC;

--- find the top 10 employees with the highest calculated bonus (using monthly_salary_bdt * bonus_pct). 
SELECT 
    e.full_name,
    e.monthly_salary_bdt,
    r.bonus_pct,
    (e.monthly_salary_bdt * r.bonus_pct) AS Bonus
FROM Employees e
JOIN Performance_Review r
    ON r.employee_id = e.employee_id
ORDER BY Bonus DESC
LIMIT 10;
--- Determine which department distributes the largest average bonus. 
SELECT 
    e.department,
    SUM(e.monthly_salary_bdt * r.bonus_pct) AS total_bonus
FROM employees e
JOIN performance_review r
    ON r.employee_id = e.employee_id
GROUP BY e.department
ORDER BY total_bonus DESC;

--- Group employees by number of trainings_completed and calculate the average leaves_taken. 
SELECT 
    trainings_completed,
    AVG(leaves_taken) AS avg_leaves_taken
FROM Performance_Review
GROUP BY trainings_completed
ORDER BY trainings_completed;

SELECT 
    trainings_completed,
    COUNT(*) AS num_employees,
    AVG(leaves_taken) AS avg_leaves_taken
FROM Performance_Review
GROUP BY trainings_completed
ORDER BY trainings_completed;

--- Identify if departments with higher training completion have lower attrition risk. 
SELECT 
    e.department,
    r.trainings_completed,
    AVG(
        CASE 
            WHEN r.attrition_risk = 'Low' THEN 1
            WHEN r.attrition_risk = 'Medium' THEN 2
            WHEN r.attrition_risk = 'High' THEN 3
        END
    ) AS avg_attrition_score
FROM Performance_Review r
JOIN Employees e
    ON e.employee_id = r.employee_id

GROUP BY e.department, r.trainings_completed
ORDER BY e.department, r.trainings_completed;
--- There is evidence that higher training completion is associated with lower attrition risk, particularly in departments such as HR, Marketing, Engineering, and Sales, where attrition scores consistently decrease as training increases.

--- However, the relationship is not uniform across all departments. Departments like Customer Success, Finance, and Operations show fluctuations, suggesting that training alone is not sufficient to reduce attrition, and other factors  may influence employee retention.


--- Count the number of direct reports for each manager_id. 
SELECT manager_id,
		COUNT(*) AS direct_reports
FROM Employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id 
ORDER BY direct_reports DESC


--- Highlight managers with more than 5 direct reports. 
SELECT manager_id,
		COUNT(*) AS direct_reports
FROM Employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id 
HAVING COUNT(*) > 5
ORDER BY direct_reports DESC

--- use hire_date to calculate tenure in years. 
SELECT full_name,
    department,
    DATE_PART('year', AGE(CURRENT_DATE, hire_date)) AS tenure
FROM Employees
GROUP BY department,full_name,hire_date
ORDER BY tenure DESC;
--- Compare average tenure across departments and see if longer tenure correlates with lower attrition risk. 
SELECT 
    e.department,
    r.attrition_risk,
    AVG(DATE_PART('year', AGE(CURRENT_DATE, e.hire_date))) AS avg_tenure
FROM Employees e
JOIN Performance_Review r
		ON e.employee_id =r.employee_id
GROUP BY department, attrition_risk,hire_date
ORDER BY department;


--- Inconclusion Analysis reveals that attrition risk is heavily concentrated in the Engineering and Customer Success departments, indicating that departmental pressures, rather than tenure alone, are a primary driver. Employees with 9–10 years of experience are overwhelmingly classified as High or Medium risk, raising concerns about a potential “brain drain” of critical institutional knowledge, while high-risk markers are also evident among new hires, pointing to gaps in onboarding or role clarity. Medium and Low risks appear across all tenure levels, underscoring that attrition is influenced by multiple factors. This pattern highlights the need for targeted retention strategies, including tailored engagement for senior staff, robust onboarding and mentorship for newcomers, and ongoing monitoring of high-risk groups to mitigate turnover proactively.
--- END