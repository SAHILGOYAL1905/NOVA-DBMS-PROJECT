
-- CSF212 Mini Project - NOVA Pharmacy Chain Database
-- RDBMS: MySQL

-- STEP 1: DATABASE AND TABLE CREATION
CREATE DATABASE IF NOT EXISTS NOVA;
USE NOVA;

CREATE TABLE Doctor (
    AadharID VARCHAR(12) PRIMARY KEY,
    Name VARCHAR(100),
    Specialty VARCHAR(100),
    YearsExperience INT
);

CREATE TABLE Patient (
    AadharID VARCHAR(12) PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(255),
    Age INT,
    PrimaryPhysician VARCHAR(12),
    FOREIGN KEY (PrimaryPhysician) REFERENCES Doctor(AadharID)
);

CREATE TABLE PharmaceuticalCompany (
    Name VARCHAR(100) PRIMARY KEY,
    Phone VARCHAR(15)
);

CREATE TABLE Drug (
    TradeName VARCHAR(100),
    Formula VARCHAR(100),
    CompanyName VARCHAR(100),
    PRIMARY KEY (TradeName, CompanyName),
    FOREIGN KEY (CompanyName) REFERENCES PharmaceuticalCompany(Name) ON DELETE CASCADE
);

CREATE TABLE Pharmacy (
    Name VARCHAR(100) PRIMARY KEY,
    Address VARCHAR(255),
    Phone VARCHAR(15)
);

CREATE TABLE Sells (
    PharmacyName VARCHAR(100),
    DrugName VARCHAR(100),
    CompanyName VARCHAR(100),
    Price DECIMAL(10,2),
    PRIMARY KEY (PharmacyName, DrugName, CompanyName),
    FOREIGN KEY (PharmacyName) REFERENCES Pharmacy(Name),
    FOREIGN KEY (DrugName, CompanyName) REFERENCES Drug(TradeName, CompanyName)
);

CREATE TABLE Prescription (
    PrescID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID VARCHAR(12),
    DoctorID VARCHAR(12),
    PrescDate DATE,
    UNIQUE (PatientID, DoctorID, PrescDate),
    FOREIGN KEY (PatientID) REFERENCES Patient(AadharID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(AadharID)
);

CREATE TABLE Prescription_Drug (
    PrescID INT,
    DrugName VARCHAR(100),
    CompanyName VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (PrescID, DrugName, CompanyName),
    FOREIGN KEY (PrescID) REFERENCES Prescription(PrescID),
    FOREIGN KEY (DrugName, CompanyName) REFERENCES Drug(TradeName, CompanyName)
);

CREATE TABLE Contract (
    ContractID INT PRIMARY KEY AUTO_INCREMENT,
    PharmaName VARCHAR(100),
    PharmacyName VARCHAR(100),
    SupervisorID VARCHAR(12),
    StartDate DATE,
    EndDate DATE,
    Content TEXT,
    FOREIGN KEY (PharmaName) REFERENCES PharmaceuticalCompany(Name),
    FOREIGN KEY (PharmacyName) REFERENCES Pharmacy(Name),
    FOREIGN KEY (SupervisorID) REFERENCES Doctor(AadharID)
);

-- STEP 2: SAMPLE DATA
INSERT INTO Doctor VALUES 
('D001', 'Dr. A. Sharma', 'Cardiology', 10),
('D002', 'Dr. B. Khan', 'Neurology', 12);

INSERT INTO Patient VALUES 
('P001', 'Ravi Kumar', 'Delhi', 45, 'D001'),
('P002', 'Sneha Patel', 'Mumbai', 30, 'D002');

INSERT INTO PharmaceuticalCompany VALUES 
('PharmaOne', '9999988888'),
('HealthPlus', '8888877777');

INSERT INTO Drug VALUES 
('Paracet', 'C8H9NO2', 'PharmaOne'),
('Neurocalm', 'C16H13ClN2', 'HealthPlus'),
('Cipladon', 'C8H9NO2', 'PharmaOne');

INSERT INTO Pharmacy VALUES 
('NOVA-Delhi', 'Connaught Place', '0112345678'),
('NOVA-Mumbai', 'Bandra West', '0228765432');

INSERT INTO Sells VALUES 
('NOVA-Delhi', 'Paracet', 'PharmaOne', 20.00),
('NOVA-Mumbai', 'Neurocalm', 'HealthPlus', 50.00),
('NOVA-Delhi', 'Cipladon', 'PharmaOne', 22.00);

INSERT INTO Prescription (PatientID, DoctorID, PrescDate) VALUES 
('P001', 'D001', '2025-03-01'),
('P002', 'D002', '2025-03-05');

INSERT INTO Prescription_Drug VALUES 
(1, 'Paracet', 'PharmaOne', 2),
(1, 'Cipladon', 'PharmaOne', 1),
(2, 'Neurocalm', 'HealthPlus', 1);

INSERT INTO Contract (PharmaName, PharmacyName, SupervisorID, StartDate, EndDate, Content) VALUES 
('PharmaOne', 'NOVA-Delhi', 'D001', '2024-01-01', '2026-01-01', 'Supply of painkillers'),
('HealthPlus', 'NOVA-Mumbai', 'D002', '2024-06-01', '2026-06-01', 'Neuro meds distribution');

-- STEP 3: PROCEDURES FOR REPORTS
DELIMITER //

CREATE PROCEDURE GetPatientPrescriptions(IN pid VARCHAR(12), IN d1 DATE, IN d2 DATE)
BEGIN
    SELECT p.PrescID, p.PrescDate, d.DrugName, d.CompanyName, d.Quantity
    FROM Prescription p
    JOIN Prescription_Drug d ON p.PrescID = d.PrescID
    WHERE p.PatientID = pid AND p.PrescDate BETWEEN d1 AND d2;
END;//

CREATE PROCEDURE GetPrescriptionDetails(IN pid VARCHAR(12), IN pdate DATE)
BEGIN
    SELECT p.PrescID, pr.DrugName, pr.CompanyName, pr.Quantity
    FROM Prescription p
    JOIN Prescription_Drug pr ON p.PrescID = pr.PrescID
    WHERE p.PatientID = pid AND p.PrescDate = pdate;
END;//

CREATE PROCEDURE GetCompanyDrugs(IN company VARCHAR(100))
BEGIN
    SELECT TradeName, Formula FROM Drug WHERE CompanyName = company;
END;//

CREATE PROCEDURE GetPharmacyStock(IN pname VARCHAR(100))
BEGIN
    SELECT DrugName, CompanyName, Price FROM Sells WHERE PharmacyName = pname;
END;//

CREATE PROCEDURE GetPharmacyCompanyContact(IN pharmaName VARCHAR(100), IN pharmacyName VARCHAR(100))
BEGIN
    SELECT c.PharmaName, c.PharmacyName, ph.Phone AS PharmacyPhone, pc.Phone AS CompanyPhone
    FROM Contract c
    JOIN Pharmacy ph ON c.PharmacyName = ph.Name
    JOIN PharmaceuticalCompany pc ON c.PharmaName = pc.Name
    WHERE c.PharmaName = pharmaName AND c.PharmacyName = pharmacyName;
END;//

CREATE PROCEDURE GetDoctorPatients(IN docid VARCHAR(12))
BEGIN
    SELECT AadharID, Name FROM Patient WHERE PrimaryPhysician = docid;
END;//

CREATE PROCEDURE GetContractsByPharmacyAndCompany(IN pharmaName VARCHAR(100), IN pharmacyName VARCHAR(100))
BEGIN
    SELECT c.ContractID, c.StartDate, c.EndDate, c.Content
    FROM Contract c
    WHERE c.PharmaName = pharmaName AND c.PharmacyName = pharmacyName;
END;//

DELIMITER ;
