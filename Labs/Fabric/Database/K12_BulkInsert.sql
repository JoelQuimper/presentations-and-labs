-- K12 Education Lab - Bulk Insert Sample Data
-- Usage: Replace C:\Data\sample_data\ with your actual CSV file location on the VM
-- Then execute this script in SSMS

-- Bulk insert all K12 sample data tables
-- NOTE: Ensure all 48 CSV files (8 base tables + 20 Attendance_School_*.csv + 20 GradeAssessments_School_*.csv) are in the same directory on the VM

BULK INSERT Schools
FROM 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\Schools.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

BULK INSERT GradeLevels
FROM 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\GradeLevels.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

BULK INSERT Teachers
FROM 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\Teachers.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

BULK INSERT Classes
FROM 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\Classes.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

BULK INSERT Students
FROM 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\Students.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

BULK INSERT Enrollment
FROM 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\Enrollment.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

-- Attendance: Split into 20 files (one per school)
-- Load all Attendance_School_*.csv files using dynamic SQL
DECLARE @SchoolID INT = 1;
DECLARE @FilePath NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);

WHILE @SchoolID <= 20
BEGIN
    SET @FilePath = 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\Attendance_School_' + CAST(@SchoolID AS VARCHAR(2)) + '.csv';
    SET @SQL = 'BULK INSERT Attendance FROM ''' + @FilePath + ''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';
    EXEC sp_executesql @SQL;
    SET @SchoolID = @SchoolID + 1;
END;

-- GradeAssessments: Split into 20 files (one per school)
-- Load all GradeAssessments_School_*.csv files using dynamic SQL
SET @SchoolID = 1;

WHILE @SchoolID <= 20
BEGIN
    SET @FilePath = 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\GradeAssessments_School_' + CAST(@SchoolID AS VARCHAR(2)) + '.csv';
    SET @SQL = 'BULK INSERT GradeAssessments FROM ''' + @FilePath + ''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'')';
    EXEC sp_executesql @SQL;
    SET @SchoolID = @SchoolID + 1;
END;

BULK INSERT StudentSuccessMetrics
FROM 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\StudentSuccessMetrics.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

BULK INSERT StudentInterventions
FROM 'C:\Repos\presentations-and-labs\Labs\Fabric\Database\SampleData\StudentInterventions.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

-- Verify data load
SELECT 'Schools' AS TableName, COUNT(*) AS RecordCount FROM Schools
UNION ALL
SELECT 'Teachers', COUNT(*) FROM Teachers
UNION ALL
SELECT 'Students', COUNT(*) FROM Students
UNION ALL
SELECT 'Classes', COUNT(*) FROM Classes
UNION ALL
SELECT 'Enrollment', COUNT(*) FROM Enrollment
UNION ALL
SELECT 'Attendance', COUNT(*) FROM Attendance
UNION ALL
SELECT 'GradeAssessments', COUNT(*) FROM GradeAssessments
UNION ALL
SELECT 'StudentSuccessMetrics', COUNT(*) FROM StudentSuccessMetrics
UNION ALL
SELECT 'StudentInterventions', COUNT(*) FROM StudentInterventions
ORDER BY TableName;
