-- K12 Education Database Schema
-- Purpose: Support student success and attendance analysis for Fabric E2E Lab
-- Created: 2026-04-06

-- ============================================================================
-- 1. SCHOOLS TABLE
-- ============================================================================
CREATE TABLE Schools (
    SchoolID INT PRIMARY KEY IDENTITY(1,1),
    SchoolName NVARCHAR(255) NOT NULL,
    SchoolDistrict NVARCHAR(255) NOT NULL,
    PrincipalName NVARCHAR(100),
    Address NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(2),
    ZipCode NVARCHAR(10),
    Phone NVARCHAR(20),
    Email NVARCHAR(255),
    SchoolType NVARCHAR(50), -- 'Elementary', 'Middle', 'High School', 'K-8', 'K-12'
    GradesServed NVARCHAR(100), -- '6-8', 'K-5', '9-12', etc.
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedDate DATETIME DEFAULT GETDATE()
);

-- ============================================================================
-- 2. TEACHERS TABLE
-- ============================================================================
CREATE TABLE Teachers (
    TeacherID INT PRIMARY KEY IDENTITY(1,1),
    SchoolID INT NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255),
    Phone NVARCHAR(20),
    HireDate DATE,
    YearsExperience INT,
    CertificationLevel NVARCHAR(50), -- 'Provisional', 'Standard', 'Advanced'
    SubjectSpecialty NVARCHAR(100), -- 'Math', 'English', 'Science', 'Social Studies', etc.
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SchoolID) REFERENCES Schools(SchoolID)
);

-- ============================================================================
-- 3. GRADE LEVELS TABLE
-- ============================================================================
CREATE TABLE GradeLevels (
    GradeLevelID INT PRIMARY KEY IDENTITY(1,1),
    GradeName NVARCHAR(50) NOT NULL, -- 'Kindergarten', '1st Grade', '2nd Grade', etc.
    GradeNumber INT, -- 0 for K, 1-12 for grades 1-12
    AgeRangeMin INT,
    AgeRangeMax INT,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- ============================================================================
-- 4. CLASSES TABLE
-- ============================================================================
CREATE TABLE Classes (
    ClassID INT PRIMARY KEY IDENTITY(1,1),
    SchoolID INT NOT NULL,
    GradeLevelID INT NOT NULL,
    TeacherID INT NOT NULL,
    ClassName NVARCHAR(100) NOT NULL,
    RoomNumber NVARCHAR(50),
    Subject NVARCHAR(100), -- 'Math', 'English', 'Science', 'Social Studies', 'PE', etc.
    Period INT, -- For secondary: 1, 2, 3, etc.
    MaxCapacity INT,
    AcademicYear INT, -- 2024, 2025, 2026, etc.
    SchoolYear NVARCHAR(9), -- '2024-2025', '2025-2026', etc.
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SchoolID) REFERENCES Schools(SchoolID),
    FOREIGN KEY (GradeLevelID) REFERENCES GradeLevels(GradeLevelID),
    FOREIGN KEY (TeacherID) REFERENCES Teachers(TeacherID)
);

-- ============================================================================
-- 5. STUDENTS TABLE
-- ============================================================================
CREATE TABLE Students (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    SchoolID INT NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    DateOfBirth DATE,
    Gender NVARCHAR(20), -- 'Male', 'Female', 'Other', 'Prefer Not to Say'
    EnrollmentDate DATE NOT NULL,
    IsActive BIT DEFAULT 1,
    EconomicStatus NVARCHAR(50), -- 'Free', 'Reduced', 'Full Price'
    ELL BIT DEFAULT 0, -- English Language Learner
    SpecialEducation BIT DEFAULT 0,
    IEPStatus NVARCHAR(50), -- 'No IEP', 'Current IEP', 'Evaluation Pending'
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SchoolID) REFERENCES Schools(SchoolID)
);

-- ============================================================================
-- 6. ENROLLMENT TABLE
-- ============================================================================
CREATE TABLE Enrollment (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    ClassID INT NOT NULL,
    EnrollmentDate DATE NOT NULL,
    WithdrawalDate DATE,
    IsActive BIT DEFAULT 1,
    EnrollmentStatus NVARCHAR(50) DEFAULT 'Active', -- 'Active', 'Withdrawn', 'Transferred'
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (ClassID) REFERENCES Classes(ClassID),
    UNIQUE (StudentID, ClassID) -- Prevent duplicate enrollments
);

-- ============================================================================
-- 7. ATTENDANCE TABLE
-- ============================================================================
CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    ClassID INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    AttendanceStatus NVARCHAR(20) NOT NULL, -- 'Present', 'Absent', 'Tardy', 'Excused', 'Unexcused'
    Reason NVARCHAR(255), -- Optional reason for absence/tardy
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (ClassID) REFERENCES Classes(ClassID)
);

-- ============================================================================
-- 8. GRADES/ASSESSMENTS TABLE
-- ============================================================================
CREATE TABLE GradeAssessments (
    AssessmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    ClassID INT NOT NULL,
    AssignmentName NVARCHAR(255) NOT NULL,
    AssessmentDate DATE NOT NULL,
    AssessmentType NVARCHAR(50), -- 'Quiz', 'Test', 'Homework', 'Project', 'Exam', 'Classwork'
    PointsEarned DECIMAL(5,2),
    PointsPossible DECIMAL(5,2),
    GradeLetter NVARCHAR(5), -- 'A', 'B', 'C', 'D', 'F'
    GradePercentage DECIMAL(5,2),
    Comments NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (ClassID) REFERENCES Classes(ClassID)
);

-- ============================================================================
-- 9. STUDENT SUCCESS METRICS TABLE
-- ============================================================================
CREATE TABLE StudentSuccessMetrics (
    MetricID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    ClassID INT NOT NULL,
    ReportingPeriod NVARCHAR(50), -- 'Q1', 'Q2', 'Q3', 'Q4', 'Semester 1', 'Semester 2'
    AcademicYear INT,
    OverallGrade NVARCHAR(5), -- Current letter grade in the class
    OverallPercentage DECIMAL(5,2),
    AttendancePercentage DECIMAL(5,2),
    AssignmentCompletionRate DECIMAL(5,2),
    BehaviorRating INT, -- 1-5 scale
    TeacherComments NVARCHAR(1000),
    ParentContact BIT DEFAULT 0, -- Whether parent was contacted
    InterventionNeeded BIT DEFAULT 0,
    InterventionType NVARCHAR(100), -- 'Tutoring', 'Counseling', 'IEP Review', 'Behavior Support'
    ProgressMonitoring NVARCHAR(255), -- Notes on student progress
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastReviewDate DATETIME,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (ClassID) REFERENCES Classes(ClassID)
);

-- ============================================================================
-- 10. STUDENT SUCCESS INTERVENTIONS TABLE
-- ============================================================================
CREATE TABLE StudentInterventions (
    InterventionID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    InterventionType NVARCHAR(100) NOT NULL, -- 'Academic Tutoring', 'Behavioral', 'Counseling', 'Special Education', 'ELL Support'
    Provider NVARCHAR(255), -- Name of teacher/counselor providing intervention
    Frequency NVARCHAR(100), -- '3x per week', 'Daily', 'Weekly', etc.
    Goals NVARCHAR(1000),
    Status NVARCHAR(50) DEFAULT 'Active', -- 'Active', 'Completed', 'Paused'
    Effectiveness NVARCHAR(50), -- 'Highly Effective', 'Moderately Effective', 'Minimal Effect', 'Not Yet Eval'
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);

-- ============================================================================
-- INDEX CREATION FOR PERFORMANCE
-- ============================================================================
CREATE INDEX IX_Attendance_StudentDate ON Attendance(StudentID, AttendanceDate);
CREATE INDEX IX_GradeAssessments_StudentDate ON GradeAssessments(StudentID, AssessmentDate);
CREATE INDEX IX_Enrollment_Student ON Enrollment(StudentID);
CREATE INDEX IX_Enrollment_Class ON Enrollment(ClassID);
CREATE INDEX IX_StudentSuccessMetrics_Student ON StudentSuccessMetrics(StudentID);
CREATE INDEX IX_Classes_School ON Classes(SchoolID);
CREATE INDEX IX_Classes_Teacher ON Classes(TeacherID);
CREATE INDEX IX_Students_School ON Students(SchoolID);
CREATE INDEX IX_Teachers_School ON Teachers(SchoolID);
