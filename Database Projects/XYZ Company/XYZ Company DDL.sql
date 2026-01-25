DROP DATABASE IF EXISTS xyz_company;
CREATE DATABASE xyz_company;

USE xyz_company;

### Add demo user 
DROP USER IF EXISTS 'xyz_user_demo'@'localhost';
CREATE USER 'xyz_user_demo'@'localhost' IDENTIFIED BY 'UTDtest';
GRANT ALL PRIVILEGES ON xyz_company.* TO 'xyz_user_demo'@'localhost';
FLUSH PRIVILEGES;

CREATE TABLE Log (
    Log_id INT AUTO_INCREMENT PRIMARY KEY,
    Action VARCHAR(20) NOT NULL,
    Table_Name VARCHAR(50) NOT NULL,
    Record_Id INT,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    Notes TEXT
);

########## Define Base Tables ##########

CREATE TABLE People (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Last_Name VARCHAR(50) NOT NULL CHECK (Last_Name <> ''),
    First_Name VARCHAR(50) NOT NULL CHECK (First_Name <> ''),
    Age INT CHECK (Age >= 0),
    Email VARCHAR(100) NOT NULL UNIQUE,
    Gender ENUM('M', 'F') NOT NULL
);

CREATE TABLE Address (
    People_id INT PRIMARY KEY,
    Address1 VARCHAR(100) NOT NULL CHECK (Address1 <> ''),
    Address2 VARCHAR(100),
    City VARCHAR(50) NOT NULL CHECK (City <> ''),
    State VARCHAR(50) NOT NULL CHECK (State <> ''),
    Zip VARCHAR(10) NOT NULL CHECK (Zip REGEXP '^[0-9]{5}$')
);

CREATE TABLE Phone (
    People_id INT PRIMARY KEY,
    Phone1 VARCHAR(20) NOT NULL CHECK (Phone1 <> ''),
    Phone2 VARCHAR(20)
);

CREATE TABLE Department (
    Id INT PRIMARY KEY,
    Dept_name VARCHAR(100) NOT NULL CHECK (Dept_name <> '')
);

CREATE TABLE Employee (
    People_id INT PRIMARY KEY,
    Emp_Rank ENUM('Junior', 'Mid', 'Senior', 'Lead'),
    Title ENUM('Engineer', 'Technician', 'DBA', 'Manager', 'Sales Associate', 'Dept. Manager') NOT NULL,
    Supervisor_id INT,
    Current_Dept INT,
    Previous_Dept INT,
    CHECK (Current_Dept IS NULL OR Previous_Dept IS NULL OR Current_Dept <> Previous_Dept)
);

CREATE TABLE Salary (
    Emp_id INT,
    Date_Paid DATETIME,
    Amount DECIMAL(10, 2) CHECK (Amount >= 0),
    PRIMARY KEY (Emp_id, Date_Paid)
);

CREATE TABLE Customer (
    People_Id INT PRIMARY KEY,
    Sales_Rep_id INT
);

CREATE TABLE Sales (
    Emp_id INT,
    Cust_Id INT,
    Date_Sold DATETIME,
    Product_id INT,
    Site_id INT,
    Quantity INT CHECK (Quantity > 0),
    PRIMARY KEY (Emp_id, Cust_id, Date_Sold, Product_id, Site_id, Quantity)
);

CREATE TABLE Job (
	Id INT AUTO_INCREMENT PRIMARY KEY,
    Dept_Id INT,
    Job_Description TEXT,
    Posted DATE,
    CHECK (Job_Description IS NOT NULL AND Job_Description <> '')
);

CREATE TABLE Potential_Employee (
    People_id INT,
    Job_id INT,
    PRIMARY KEY (People_id, Job_id)
);

CREATE TABLE Application (
    Job_id INT,
    People_id INT,
    Form TEXT,
    PRIMARY KEY (Job_id, People_id),
    CHECK (Form IS NOT NULL AND Form <> '')
);

CREATE TABLE Shift (
    Dept_id INT,
    Shift_type VARCHAR(50) NOT NULL CHECK (Shift_type <> ''),
    Shift_start DATETIME,
    Shift_end DATETIME,
    Supervisor_id INT,
    CHECK (Shift_end > Shift_start),
    PRIMARY KEY (Dept_id, Shift_type, Shift_start)
);

CREATE TABLE Employee_on_Shift (
    Emp_id INT,
    Dept_id INT,
    Shift_start DATETIME,
    Shift_type VARCHAR(50),
    Emp_Role VARCHAR(50) NOT NULL CHECK (Emp_Role <> ''),
    PRIMARY KEY (Emp_id, Dept_id, Shift_start, Shift_type)
);

CREATE TABLE Interviews (
    Interviewee_id INT,
    Job_id INT,
    Round INT CHECK (Round > 0),
    Interviewer_id INT,
    Date_Interviewed DATE,
    Grade INT CHECK (Grade BETWEEN 0 AND 100),
    PRIMARY KEY (Interviewee_id, Job_id, Round)
);

CREATE TABLE Product (
    Id INT PRIMARY KEY,
    Product_type VARCHAR(50) NOT NULL CHECK (Product_type <> ''),
    Size VARCHAR(50) NOT NULL CHECK (Size <> ''),
    List_Price DECIMAL(10, 2) CHECK (List_Price >= 0),
    Weight DECIMAL(10, 2) CHECK (Weight >= 0),
    Style VARCHAR(50) NOT NULL CHECK (Style <> '')
);

CREATE TABLE Part (
    Id INT PRIMARY KEY,
    Part_type VARCHAR(50) NOT NULL CHECK (Part_type <> ''),
    Weight DECIMAL(5,2) CHECK (Weight >= 0)
);

CREATE TABLE Product_Part (
    Product_id INT,
    Part_id INT,
    Quantity_Used INT CHECK (Quantity_Used > 0),
    PRIMARY KEY (Product_id, Part_id)
);

CREATE TABLE Site (
    Id INT PRIMARY KEY,
    Site_name VARCHAR(100) NOT NULL CHECK (Site_name <> ''),
    Location VARCHAR(100) NOT NULL CHECK (Location <> '')
);


CREATE TABLE Works_In (
    Emp_id INT,
    Site_id INT,
    PRIMARY KEY (Emp_id, Site_id)
);


CREATE TABLE Vendor (
    Id INT PRIMARY KEY,
    Vendor_name VARCHAR(100) NOT NULL CHECK (Vendor_name <> ''),
    Vendor_Account VARCHAR(100) NOT NULL CHECK (Vendor_Account <> ''),
    Credit_Rating VARCHAR(20) NOT NULL CHECK (Credit_Rating <> ''),
    Purchase_URL VARCHAR(255)
);


CREATE TABLE Vendor_Address (
    Vendor_Id INT,
    Address1 VARCHAR(100) NOT NULL CHECK (Address1 <> ''),
    Address2 VARCHAR(100),
    City VARCHAR(50) NOT NULL CHECK (City <> ''),
    State VARCHAR(50) NOT NULL CHECK (State <> ''),
    Zip VARCHAR(10) NOT NULL CHECK (Zip REGEXP '^[0-9]{5}$'),
    PRIMARY KEY (Vendor_Id, Address1, Zip)
);


CREATE TABLE Vendor_Price (
    Vendor_id INT,
    Part_id INT,
    Price DECIMAL(10, 2) CHECK (Price > 0),
    PRIMARY KEY (Vendor_id, Part_id)
);


########### Apply Foreign Key Constraints ###########

ALTER TABLE Address
ADD CONSTRAINT fk_address_people FOREIGN KEY (People_id) REFERENCES People(Id);

ALTER TABLE Phone
ADD CONSTRAINT fk_phone_people FOREIGN KEY (People_id) REFERENCES People(Id);

ALTER TABLE Employee
ADD CONSTRAINT fk_employee_people FOREIGN KEY (People_id) REFERENCES People(Id),
ADD CONSTRAINT fk_employee_supervisor FOREIGN KEY (Supervisor_id) REFERENCES Employee(People_id),
ADD CONSTRAINT fk_employee_current_dept FOREIGN KEY (Current_Dept) REFERENCES Department(Id),
ADD CONSTRAINT fk_employee_previous_dept FOREIGN KEY (Previous_Dept) REFERENCES Department(Id);

ALTER TABLE Salary
ADD CONSTRAINT fk_salary_employee FOREIGN KEY (Emp_id) REFERENCES Employee(People_id);

ALTER TABLE Customer
ADD CONSTRAINT fk_customer_people FOREIGN KEY (People_id) REFERENCES People(Id),
ADD CONSTRAINT fk_customer_sales_rep FOREIGN KEY (Sales_Rep_id) REFERENCES Employee(People_id);

ALTER TABLE Sales
ADD CONSTRAINT fk_sales_employee FOREIGN KEY (Emp_id) REFERENCES Employee(People_id),
ADD CONSTRAINT fk_sales_customer FOREIGN KEY (Cust_id) REFERENCES Customer(People_id),
ADD CONSTRAINT fk_sales_product FOREIGN KEY (Product_id) REFERENCES Product(Id),
ADD CONSTRAINT fk_sales_site FOREIGN KEY (Site_id) REFERENCES Site(Id);

ALTER TABLE Job
ADD CONSTRAINT fk_job_dept FOREIGN KEY (Dept_Id) REFERENCES Department(Id);

ALTER TABLE Potential_Employee
ADD CONSTRAINT fk_potential_employee_people FOREIGN KEY (People_id) REFERENCES People(Id),
ADD CONSTRAINT fk_potential_employee_job FOREIGN KEY (Job_id) REFERENCES Job(Id);


ALTER TABLE Application
ADD CONSTRAINT fk_application_job FOREIGN KEY (Job_Id) REFERENCES Job(Id),
ADD CONSTRAINT fk_application_people FOREIGN KEY (People_Id) REFERENCES People(Id);

ALTER TABLE Interviews
ADD CONSTRAINT fk_interviews_interviewee FOREIGN KEY (Interviewee_id) REFERENCES People(Id),
ADD CONSTRAINT fk_interviews_job FOREIGN KEY (Job_id) REFERENCES Job(Id),
ADD CONSTRAINT fk_interviews_interviewer FOREIGN KEY (Interviewer_id) REFERENCES Employee(People_id);

ALTER TABLE Shift
ADD CONSTRAINT fk_shift_dept FOREIGN KEY (Dept_Id) REFERENCES Department(Id),
ADD CONSTRAINT fk_shift_supervisor FOREIGN KEY (Supervisor_id) REFERENCES Employee(People_id);


ALTER TABLE Employee_on_Shift
ADD CONSTRAINT fk_emp_shift_employee FOREIGN KEY (Emp_id) REFERENCES Employee(People_id),
ADD CONSTRAINT fk_emp_shift_shift FOREIGN KEY (Dept_id, Shift_type, Shift_start) REFERENCES Shift(Dept_id, Shift_type, Shift_start);

ALTER TABLE Product_Part
ADD CONSTRAINT fk_product_part_product FOREIGN KEY (Product_Id) REFERENCES Product(Id),
ADD CONSTRAINT fk_product_part_part FOREIGN KEY (Part_Id) REFERENCES Part(Id);

ALTER TABLE Vendor_Address
ADD CONSTRAINT fk_vendor_address_vendor FOREIGN KEY (Vendor_Id) REFERENCES Vendor(Id);

ALTER TABLE Vendor_Price
ADD CONSTRAINT fk_vendor_price_vendor FOREIGN KEY (Vendor_id) REFERENCES Vendor(Id),
ADD CONSTRAINT fk_vendor_price_part FOREIGN KEY (Part_id) REFERENCES Part(Id);

ALTER TABLE Works_In
ADD CONSTRAINT fk_works_in_employee FOREIGN KEY (Emp_id) REFERENCES Employee(People_id),
ADD CONSTRAINT fk_works_in_site FOREIGN KEY (Site_id) REFERENCES Site(Id);





