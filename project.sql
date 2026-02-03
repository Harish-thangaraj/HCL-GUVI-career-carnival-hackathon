CREATE DATABASE hospital_analytics;
USE hospital_analytics;

CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(50),
    age INT,
    gender VARCHAR(10),
    diagnosis VARCHAR(50),
    department VARCHAR(30),
    city VARCHAR(30)
);

INSERT INTO patients
SELECT
    n,
    CONCAT('Patient_', n),
    20 + (n % 50),
    CASE WHEN n % 2 = 0 THEN 'Female' ELSE 'Male' END,
    CASE 
        WHEN n % 5 = 0 THEN 'Diabetes'
        WHEN n % 4 = 0 THEN 'Heart Disease'
        WHEN n % 3 = 0 THEN 'Asthma'
        WHEN n % 2 = 0 THEN 'Fracture'
        ELSE 'Stroke'
    END,
    CASE 
        WHEN n % 5 = 0 THEN 'Cardiology'
        WHEN n % 4 = 0 THEN 'Orthopedics'
        WHEN n % 3 = 0 THEN 'Neurology'
        WHEN n % 2 = 0 THEN 'Pulmonology'
        ELSE 'General Medicine'
    END,
    CASE 
        WHEN n % 4 = 0 THEN 'Chennai'
        WHEN n % 3 = 0 THEN 'Madurai'
        WHEN n % 2 = 0 THEN 'Trichy'
        ELSE 'Coimbatore'
    END
FROM (
    SELECT @row := @row + 1 AS n
    FROM information_schema.tables, (SELECT @row := 0) r
    LIMIT 50
) t;

CREATE TABLE admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT,
    admission_date DATE,
    discharge_date DATE,
    admission_type VARCHAR(20),
    discharge_status VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

INSERT INTO admissions
SELECT
    1000 + n AS admission_id,
    n AS patient_id,
    DATE_ADD('2024-01-01', INTERVAL n DAY) AS admission_date,
    DATE_ADD('2024-01-01', INTERVAL n + (n % 7 + 1) DAY) AS discharge_date,
    CASE 
        WHEN n % 3 = 0 THEN 'Emergency'
        ELSE 'Scheduled'
    END AS admission_type,
    CASE 
        WHEN n % 4 = 0 THEN 'Transferred'
        WHEN n % 5 = 0 THEN 'Deceased'
        ELSE 'Recovered'
    END AS discharge_status
FROM (
    SELECT @row := @row + 1 AS n
    FROM information_schema.tables, (SELECT @row := 0) r
    LIMIT 50
) t;

CREATE TABLE beds (
    bed_id INT PRIMARY KEY,
    department VARCHAR(30),
    bed_type VARCHAR(20),
    total_beds INT,
    occupied_beds INT,
    date DATE
);

INSERT INTO beds VALUES
(1,'Cardiology','ICU',50,42,'2024-01-10'),
(2,'Orthopedics','General',40,30,'2024-01-10'),
(3,'Neurology','ICU',30,25,'2024-01-10'),
(4,'General Medicine','General',60,48,'2024-01-10'),
(5,'Pulmonology','ICU',25,21,'2024-01-10');

CREATE TABLE resources (
    resource_id INT PRIMARY KEY,
    resource_type VARCHAR(30),
    department VARCHAR(30),
    total_units INT,
    used_units INT,
    status VARCHAR(20)
);

INSERT INTO resources VALUES
(1,'Ventilator','Cardiology',20,16,'Active'),
(2,'Ventilator','Pulmonology',15,12,'Active'),
(3,'MRI','Neurology',5,4,'Active'),
(4,'CT Scanner','General Medicine',4,3,'Active'),
(5,'ECG','Cardiology',10,8,'Active');


CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    staff_name VARCHAR(50),
    role VARCHAR(20),
    department VARCHAR(30),
    shift VARCHAR(20),
    availability VARCHAR(20)
);

INSERT INTO staff VALUES
(1,'Dr Raj','Doctor','Cardiology','Day','Available'),
(2,'Nurse Priya','Nurse','Orthopedics','Night','Available'),
(3,'Dr Suresh','Doctor','Neurology','Day','Busy'),
(4,'Nurse Anu','Nurse','General Medicine','Day','Available'),
(5,'Dr Karthik','Doctor','Pulmonology','Night','Busy');


SELECT COUNT(*) FROM patients;
SELECT COUNT(*) FROM admissions;
SELECT p.department, COUNT(*) 
FROM patients p
GROUP BY p.department;

SELECT admission_type, COUNT(*) 
FROM admissions
GROUP BY admission_type;

SELECT 
    p.department,
    ROUND(AVG(DATEDIFF(a.discharge_date, a.admission_date)),2) AS avg_los
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY p.department;

SELECT 
    admission_type,
    COUNT(*) AS total_admissions
FROM admissions
GROUP BY admission_type;

SELECT 
    discharge_status,
    COUNT(*) AS total_cases
FROM admissions
GROUP BY discharge_status;

SELECT 
    department,
    ROUND((occupied_beds / total_beds) * 100,2) AS occupancy_rate
FROM beds;


SELECT 
    department,
    resource_type,
    ROUND((used_units / total_units) * 100,2) AS utilization_pct
FROM resources;

