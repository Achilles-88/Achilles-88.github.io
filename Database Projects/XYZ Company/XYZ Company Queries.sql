# referred to in Part e) of XYZ Company Project.docx

########## NOTE: My data generation is unique, thus I've changed the nouns but kept the syntax of your original queries to work with my data. ##########
#							-----> indicates the syntax was changed to work with my uniquely fake data

use xyz_company;

######### 1. Interviewers for “Hellen Cole” on job 11111 -----> “Diana Howard” on job 30018
SELECT DISTINCT i.Interviewer_ID, person.First_Name, person.Last_Name, i.Round as Interview_Round
FROM Interviews i
JOIN People person ON i.Interviewer_ID = person.ID
JOIN People target ON i.Interviewee_ID = target.ID
WHERE target.First_Name = 'Diane' AND target.Last_Name = 'Howard'
  AND i.Job_ID = 30018;

######### 2. Job IDs posted by department “Marketing” in Jan 2011 -----> July 2024
SELECT j.ID as Job_id, Dept_name, YEAR(j.Posted) as Posted
FROM Job j
JOIN Department d ON j.Dept_ID = d.ID
WHERE d.dept_name = 'Marketing'
  AND MONTH(j.Posted) = 7 AND YEAR(j.Posted) = 2024;

######### 3. Employees with no supervisees
SELECT e.People_id as Emp_id, person.First_Name, person.Last_Name
FROM Employee e
JOIN People person ON e.People_id = person.ID
WHERE e.People_id NOT IN (
    SELECT DISTINCT Supervisor_id FROM Employee WHERE Supervisor_id IS NOT NULL
);

######### 4. Sites with no sales in March 2011 -----> May 2025
SELECT s.ID, s.Location
FROM Site s
WHERE s.ID NOT IN (
    SELECT DISTINCT Site_ID
    FROM Sales
    WHERE MONTH(Date_Sold) = 5 AND YEAR(Date_Sold) = 2025
);

######### 5. Jobs that did not hire anyone one month after posting
SELECT j.ID as Job_id, j.Dept_id as Department, j.Posted
FROM Job j
WHERE NOT EXISTS (
    SELECT 1
    FROM (
        SELECT Interviewee_id, Job_id
        FROM Interviews
        WHERE Grade > 60
        GROUP BY Interviewee_id, Job_id
        HAVING COUNT(*) >= 5
    ) passed
    WHERE passed.Job_id = j.ID
);


######### 6. Sales rep who sold all product types over $200 --------> Count of Items Over $200 Sold Per Salesman
SELECT s.Emp_id as Sales_Rep, COUNT(*) AS Sales_Over_200
FROM Sales s
JOIN Product p ON s.Product_id = p.Id
WHERE p.List_Price > 200
GROUP BY s.Emp_id
ORDER BY Sales_Over_200 DESC;


######### 7. Departments with no job postings between Jan 1–Feb 1, 2011 ------> May 1–Jun 1, 2024
SELECT d.Id, d.Dept_name
FROM Department d
WHERE NOT EXISTS (
    SELECT 1
    FROM Job j
    WHERE j.Dept_Id = d.Id
      AND j.Posted BETWEEN '2024-05-01' AND '2024-06-01'
);

######### 8. Employees who applied to job 12345 -----> job 30002
SELECT e.People_id as Emp_id, e.Current_Dept, p.First_Name, p.Last_Name
FROM Application a
JOIN Employee e ON a.People_id = e.People_id
JOIN People p ON e.People_id = p.Id
WHERE a.Job_id = 30002;


######### 9. Best-selling product type (by quantity)
SELECT p.Product_Type, SUM(s.Quantity) AS Total_Quantity_Sold
FROM Sales s
JOIN Product p ON s.Product_id = p.Id
GROUP BY p.Product_Type
ORDER BY Total_Quantity_Sold DESC
LIMIT 1;

######### 10. Most profitable product type (List_Price - SUM(Parts Cost))
SELECT p.Product_Type,
       ROUND(SUM(p.List_Price - COALESCE(cost.Total_Cost, 0)), 2) AS Net_Profit
FROM Product p
LEFT JOIN (
    SELECT pp.Product_id,
           SUM(pp.Quantity_Used * vp.MinPrice) AS Total_Cost
    FROM Product_Part pp
    JOIN (
        SELECT Part_id, MIN(Price) AS MinPrice
        FROM Vendor_Price
        GROUP BY Part_id
    ) vp ON pp.Part_id = vp.Part_id
    GROUP BY pp.Product_id
) cost ON p.Id = cost.Product_id
GROUP BY p.Product_Type
ORDER BY Net_Profit DESC
LIMIT 1;

######### 11. Employees who worked in all departments -----> Employees who have worked in multiple departments
SELECT e.People_id as Emp_id, p.First_Name, p.Last_Name, e.Current_Dept, e.Previous_Dept
FROM Employee e
JOIN People p ON e.People_id = p.Id
WHERE e.Previous_Dept IS NOT NULL;
##################################################################

######### 12. Selected interviewees Emails (5+ Grades ≥ 60)
SELECT DISTINCT p.First_Name, p.Last_Name, p.Email
FROM Interviews i
JOIN People p ON i.Interviewee_id = p.Id
WHERE i.Interviewee_id IN (
    SELECT Interviewee_id
    FROM Interviews
    WHERE Grade > 60
    GROUP BY Interviewee_id, Job_id
    HAVING COUNT(*) >= 5
);
##################################################################

######### 13. Contact info of selected interviewees for all their jobs ------> selected first by first date finished after 5+ interview grades of 60+ using a created view
SELECT s.Job_id, p.First_Name, p.Last_Name, p.Email, ph.Phone1, s.Selection_Date, s.Avg_Grade, s.Total_Interviews
FROM Select_Candidate_Date s
JOIN People p ON s.Interviewee_id = p.Id
LEFT JOIN Phone ph ON p.Id = ph.People_id
ORDER BY s.Job_id;
##################################################################

######### 14. Employee with highest average monthly salary
SELECT s.Emp_id, p.First_Name, p.Last_Name, ROUND(AVG(s.Amount), 2) AS Avg_Salary
FROM Salary s
JOIN People p ON s.Emp_id = p.Id
GROUP BY s.Emp_id, p.First_Name, p.Last_Name
ORDER BY Avg_Salary DESC
LIMIT 1;
##################################################################

######### 15. Vendor offering “Cup” part under 4 lb at lowest price ------> ...offering "Casing 7"
SELECT v.Id, v.Vendor_name
FROM Vendor v
JOIN Vendor_Price vp ON v.Id = vp.Vendor_id
JOIN Part p ON vp.Part_id = p.Id
WHERE p.Part_type = 'Casing 7'
  AND p.Weight < 4
  AND vp.Price = (
      SELECT MIN(vp2.Price)
      FROM Vendor_Price vp2
      JOIN Part p2 ON vp2.Part_id = p2.Id
      WHERE p2.Part_type = 'Casing 7'
        AND p2.Weight < 4
  );
