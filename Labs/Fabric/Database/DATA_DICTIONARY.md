# K12 Education Database Schema Documentation
## Student Success & Attendance Lab for Fabric

**Date Created:** April 6, 2026  
**Purpose:** Sample database for Fabric end-to-end lab demonstrating student success and attendance analysis

---

## Overview

This database schema is designed for K12 schools and districts to track:
- Student enrollment and demographics
- Daily attendance and attendance patterns
- Academic performance and grades
- Behavioral and success metrics
- Targeted interventions for at-risk students

The schema supports analysis of key education metrics like attendance impact on performance, intervention effectiveness, and student success patterns.

---

## Table Structure & Relationships

### 1. **Schools** (Primary Entity)
Represents individual schools within a district.

| Column | Type | Description |
|--------|------|-------------|
| SchoolID | INT (PK) | Unique identifier |
| SchoolName | NVARCHAR(255) | Name of the school |
| SchoolDistrict | NVARCHAR(255) | District name |
| PrincipalName | NVARCHAR(100) | Principal's name |
| Address | NVARCHAR(500) | Physical address |
| City, State, ZipCode | NVARCHAR | Location information |
| Phone, Email | NVARCHAR | Contact information |
| SchoolType | NVARCHAR(50) | Elementary, Middle, High School, K-8, K-12 |
| GradesServed | NVARCHAR(100) | Grade ranges (e.g., '6-8', 'K-5') |

**Sample Data**
```
SchoolID | SchoolName | SchoolType | GradesServed | District
1        | Lincoln Elementary | Elementary | K-5 | Central USD
2        | Washington Middle | Middle | 6-8 | Central USD
3        | Roosevelt High School | High School | 9-12 | Central USD
```

---

### 2. **GradeLevels** (Reference Table)
Defines grade levels from Kindergarten through 12th grade.

| Column | Type | Description |
|--------|------|-------------|
| GradeLevelID | INT (PK) | Unique identifier |
| GradeName | NVARCHAR(50) | Display name (e.g., '1st Grade') |
| GradeNumber | INT | Numeric representation (0=K, 1-12) |
| AgeRangeMin, AgeRangeMax | INT | Expected student age range |

**Sample Data**
```
GradeLevelID | GradeName | GradeNumber | AgeRangeMin | AgeRangeMax
1            | Kindergarten | 0 | 4 | 6
2            | 1st Grade | 1 | 5 | 7
3            | 2nd Grade | 2 | 6 | 8
...
12           | 12th Grade | 12 | 17 | 19
```

---

### 3. **Teachers**
Staff member information with certification and specialization details.

| Column | Type | Description |
|--------|------|-------------|
| TeacherID | INT (PK) | Unique identifier |
| SchoolID | INT (FK) | School assignment |
| FirstName, LastName | NVARCHAR(100) | Name |
| Email, Phone | NVARCHAR | Contact information |
| HireDate | DATE | Employment date |
| YearsExperience | INT | Years teaching |
| CertificationLevel | NVARCHAR(50) | Provisional, Standard, Advanced |
| SubjectSpecialty | NVARCHAR(100) | Math, English, Science, Social Studies, etc. |
| IsActive | BIT | Active/inactive status |

---

### 4. **Classes**
Individual class sections with teacher, subject, and schedule information.

| Column | Type | Description |
|--------|------|-------------|
| ClassID | INT (PK) | Unique identifier |
| SchoolID | INT (FK) | School |
| GradeLevelID | INT (FK) | Grade level |
| TeacherID | INT (FK) | Assigned teacher |
| ClassName | NVARCHAR(100) | Class name (e.g., 'Period 2 Algebra') |
| RoomNumber | NVARCHAR(50) | Room location |
| Subject | NVARCHAR(100) | Subject area |
| Period | INT | Class period (for secondary) |
| MaxCapacity | INT | Maximum enrolled students |
| AcademicYear | INT | Year (e.g., 2025) |
| SchoolYear | NVARCHAR(9) | Format: '2024-2025' |

**Sample Data**
```
ClassID | ClassName | Subject | TeacherID | GradeLevelID | AcademicYear
1       | Math 101 (Period 2) | Math | 5 | 6 | 2025
2       | English Honors | English | 3 | 7 | 2025
3       | Biology Lab | Science | 7 | 8 | 2025
```

---

### 5. **Students**
Student demographics and enrollment status.

| Column | Type | Description |
|--------|------|-------------|
| StudentID | INT (PK) | Unique identifier |
| SchoolID | INT (FK) | Assigned school |
| FirstName, LastName | NVARCHAR(100) | Name |
| DateOfBirth | DATE | For age calculations |
| Gender | NVARCHAR(20) | Male, Female, Other, Prefer Not to Say |
| EnrollmentDate | DATE | Date of initial enrollment |
| IsActive | BIT | Currently enrolled? |
| EconomicStatus | NVARCHAR(50) | Free, Reduced, Full Price lunch |
| ELL | BIT | English Language Learner flag |
| SpecialEducation | BIT | Special education enrollment |
| IEPStatus | NVARCHAR(50) | IEP status tracking |

---

### 6. **Enrollment**
Student enrollment in specific classes (many-to-many relationship).

| Column | Type | Description |
|--------|------|-------------|
| EnrollmentID | INT (PK) | Unique identifier |
| StudentID | INT (FK) | Student |
| ClassID | INT (FK) | Class |
| EnrollmentDate | DATE | When student joined class |
| WithdrawalDate | DATE | If student left the class |
| IsActive | BIT | Currently enrolled? |
| EnrollmentStatus | NVARCHAR(50) | Active, Withdrawn, Transferred |

---

### 7. **Attendance**
Daily attendance records for tracking presence, absences, and tardies.

| Column | Type | Description |
|--------|------|-------------|
| AttendanceID | INT (PK) | Unique identifier |
| StudentID | INT (FK) | Student |
| ClassID | INT (FK) | Class |
| AttendanceDate | DATE | Date of attendance record |
| AttendanceStatus | NVARCHAR(20) | Present, Absent, Tardy, Excused, Unexcused |
| Reason | NVARCHAR(255) | Optional reason for absence/tardy |

**Key Insight:** This table enables analysis like:
- Chronic absenteeism (>10% absent days)
- Attendance vs. GPA correlation
- Tardy patterns by time of day or day of week

---

### 8. **GradeAssessments**
Individual assignments, quizzes, tests, and projects with scores.

| Column | Type | Description |
|--------|------|-------------|
| AssessmentID | INT (PK) | Unique identifier |
| StudentID | INT (FK) | Student |
| ClassID | INT (FK) | Class |
| AssignmentName | NVARCHAR(255) | Name of assignment/test |
| AssessmentDate | DATE | Date submitted/taken |
| AssessmentType | NVARCHAR(50) | Quiz, Test, Homework, Project, Exam, Classwork |
| PointsEarned | DECIMAL(5,2) | Score received |
| PointsPossible | DECIMAL(5,2) | Total points possible |
| GradeLetter | NVARCHAR(5) | Letter grade (A, B, C, D, F) |
| GradePercentage | DECIMAL(5,2) | Percentage (0-100) |
| Comments | NVARCHAR(500) | Teacher feedback |

**Granularity Example:**
```
StudentID | AssignmentName | AssessmentType | GradePercentage | Comments
101       | Chapter 3 Quiz | Quiz | 85 | Good effort, review fractions
101       | Midterm Exam | Exam | 78 | Struggled with word problems
101       | Project: Build Bridge | Project | 92 | Excellent teamwork!
```

---

### 9. **StudentSuccessMetrics**
Summary metrics per reporting period (quarter/semester) for quick analysis.

| Column | Type | Description |
|--------|------|-------------|
| MetricID | INT (PK) | Unique identifier |
| StudentID | INT (FK) | Student |
| ClassID | INT (FK) | Class |
| ReportingPeriod | NVARCHAR(50) | Q1, Q2, Q3, Q4, Semester 1, Semester 2 |
| AcademicYear | INT | Year |
| OverallGrade | NVARCHAR(5) | Current class grade (A-F) |
| OverallPercentage | DECIMAL(5,2) | Current class percentage (0-100) |
| AttendancePercentage | DECIMAL(5,2) | Days present / total days |
| AssignmentCompletionRate | DECIMAL(5,2) | % of assignments completed |
| BehaviorRating | INT | 1-5 scale (1=Problem, 5=Excellent) |
| TeacherComments | NVARCHAR(1000) | Qualitative feedback |
| ParentContact | BIT | Parent contacted this period? |
| InterventionNeeded | BIT | Student flagged for intervention? |
| InterventionType | NVARCHAR(100) | Tutoring, Counseling, IEP Review, etc. |

**Business Value:** This table answers key questions:
- Which students need intervention?
- How does attendance correlate with grades?
- What's the effectiveness of current interventions?

---

### 10. **StudentInterventions**
Tracked interventions for at-risk or struggling students.

| Column | Type | Description |
|--------|------|-------------|
| InterventionID | INT (PK) | Unique identifier |
| StudentID | INT (FK) | Student |
| StartDate | DATE | When intervention began |
| EndDate | DATE | When intervention ended (NULL if ongoing) |
| InterventionType | NVARCHAR(100) | Academic Tutoring, Behavioral, Counseling, etc. |
| Provider | NVARCHAR(255) | Name of staff member providing intervention |
| Frequency | NVARCHAR(100) | 3x per week, Daily, Weekly, etc. |
| Goals | NVARCHAR(1000) | Intervention objectives |
| Status | NVARCHAR(50) | Active, Completed, Paused |
| Effectiveness | NVARCHAR(50) | Highly Effective, Moderately Effective, Minimal Effect |

---

## Key Analytics Scenarios

This schema supports analysis for:

### 📊 **Attendance Analytics**
- Chronic absenteeism identification
- Impact of attendance on academic performance
- Tardy patterns and trends
- Attendance by demographic group (ELL, Special Ed, Economic Status)

### 📈 **Academic Performance**
- Grade distribution by class, teacher, grade level
- Student progress tracking over time
- Assignment completion rates
- Assessment performance trends

### 🎯 **Student Success Interventions**
- Intervention effectiveness tracking
- Time to close performance gaps
- Intervention by demographic group
- Multi-intervention student tracking

### 👥 **Demographic Analysis**
- Performance by economic status
- ELL student progress
- Special education outcomes
- Gender-based performance comparison

### 👨‍🏫 **Teacher Analytics**
- Teacher effectiveness metrics
- Class performance comparison
- Student satisfaction with courses
- Professional development needs

---

## Sample Data Recommendations

For your Fabric lab, populate with:

- **2-3 schools** (elementary, middle, high)
- **50-100 teachers**
- **1,000-2,000 students**
- **9-12 months of attendance data** (realistic patterns)
- **Multiple semesters of grades** (varied performance)
- **50-100 active interventions**

This volume is realistic and provides enough data for meaningful Fabric analysis without being unwieldy.

---

## Creating Sample Data

### Realistic Data Patterns to Include:

1. **Attendance Patterns**
   - Some students with perfect attendance
   - Chronic absentees (missing >10% of days)
   - Seasonal patterns (flu, holidays)
   - Day-of-week effects (more absences on Fridays/Mondays)

2. **Academic Performance**
   - Correlation between attendance and grades
   - Variation by subject and teacher
   - Improvement from interventions
   - Economic status impact

3. **Demographics**
   - Varying percentages of ELL students
   - Mix of special education classifications
   - Mix of economic statuses
   - Gender balance (roughly 50/50)

---

## Next Steps for Fabric Lab

1. **Create database** in Azure SQL or SQL Server using K12_Schema.sql
2. **Populate with sample data** (can use Python/TSQL scripts)
3. **Import to Fabric** via:
   - Direct SQL connection (Fabric can query Azure SQL)
   - CSV/Parquet export and import to Lakehouse
   - OneLake shortcuts to data source
4. **Build Fabric semantic model** for analysis
5. **Create Power BI reports** for:
   - attendance dashboards
   - - Student success scorecards
   - Intervention effectiveness
   - Teacher performance metrics

---

## Notes

- **Privacy Consideration:** In real-world use, implement proper data masking for student names/birthdates
- **Scalability:** Index creation included for performance at scale
- **Extensibility:** Easy to add columns for assessment standards, learning goals, or district-specific metrics
- **Compliance:** Consider FERPA requirements when handling real student data

