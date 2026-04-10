"""
K12 Education Database Sample Data Generator
Generates realistic student success and attendance data for Fabric lab
with per-student consistency in performance and attendance patterns
"""

import random
import pandas as pd
from datetime import datetime, timedelta
import csv
from pathlib import Path

class K12DataGenerator:
    def __init__(self, seed=42):
        random.seed(seed)
        self.base_date = datetime(2024, 9, 1)  # Start of school year
        self.student_profiles = {}  # Store per-student attributes for consistency
        
    # ==================== HELPER FUNCTIONS ====================
    def random_date_range(self, start_days_offset=0, end_days_offset=200):
        """Generate random date within school year"""
        start = self.base_date + timedelta(days=start_days_offset)
        end = self.base_date + timedelta(days=end_days_offset)
        random_days = random.randint(0, (end - start).days)
        return start + timedelta(days=random_days)
    
    def is_school_day(self, date):
        """Check if date is a school day (Mon-Fri)"""
        return date.weekday() < 5
    
    def get_school_days(self, start, end):
        """Get all school days between two dates"""
        school_days = []
        current = start
        while current <= end:
            if self.is_school_day(current):
                school_days.append(current)
            current += timedelta(days=1)
        return school_days
    
    # ==================== GENERATE TABLES ====================
    
    def generate_schools(self, num_schools=100):
        """Generate schools data"""
        school_types = [
            ('Elementary', 'K-5'),
            ('Middle', '6-8'),
            ('High School', '9-12')
        ]
        
        school_names = ['Lincoln', 'Washington', 'Jefferson', 'Madison', 'Monroe', 'Jackson',
                       'Adams', 'Franklin', 'Hamilton', 'Kennedy', 'Roosevelt', 'Wilson',
                       'Cleveland', 'Grant', 'Hayes', 'Garfield', 'Arthur', 'Sherman',
                       'Grant', 'Lee', 'Jackson', 'Davis', 'Hill', 'Oak', 'Pine', 'Maple']
        
        principal_first = ['Dr.', 'Ms.', 'Mr.', 'Mrs.', 'Prof.']
        principal_last = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 
                         'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez']
        
        schools = []
        for i in range(num_schools):
            school_type, grades = school_types[i % 3]
            district_num = (i // 10) + 1  # Group schools into districts
            schools.append({
                'SchoolID': i + 1,
                'SchoolName': f'{random.choice(school_names)} {school_type} {i+1}',
                'SchoolDistrict': f'District {district_num} Unified School District',
                'PrincipalName': f'{random.choice(principal_first)} {random.choice(principal_last)}',
                'Address': f'{random.randint(100, 9999)} {random.choice(["Main", "Oak", "Elm", "Pine"])} Street',
                'City': random.choice(['Springfield', 'Shelbyville', 'Capital City', 'Metropolis', 'Smallville']),
                'State': 'IL',
                'ZipCode': f'{random.randint(60000, 69999)}',
                'Phone': f'{random.randint(200, 999)}-{random.randint(200, 999)}-{random.randint(1000, 9999)}',
                'Email': f'school{i+1}@centralusd.edu',
                'SchoolType': school_type,
                'GradesServed': grades
            })
        return pd.DataFrame(schools)
    
    def generate_grade_levels(self):
        """Generate grade levels K-12"""
        grade_names = ['Kindergarten', '1st Grade', '2nd Grade', '3rd Grade', '4th Grade', '5th Grade',
                       '6th Grade', '7th Grade', '8th Grade', '9th Grade', '10th Grade', '11th Grade', '12th Grade']
        
        grades = []
        for i, name in enumerate(grade_names):
            age_min = max(4, i + 4)  # K=4, 1st=5, etc.
            age_max = age_min + 2
            grades.append({
                'GradeLevelID': i + 1,
                'GradeName': name,
                'GradeNumber': i if i > 0 else 0,
                'AgeRangeMin': age_min,
                'AgeRangeMax': age_max
            })
        return pd.DataFrame(grades)
    
    def generate_teachers(self, num_schools=3, teachers_per_school=15):
        """Generate teachers data"""
        subjects = ['Math', 'English', 'Science', 'Social Studies', 'PE', 'Art', 'Music', 'Special Ed']
        cert_levels = ['Provisional', 'Standard', 'Advanced']
        first_names = ['John', 'Sarah', 'Michael', 'Jennifer', 'David', 'Emily', 'James', 'Lisa']
        last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis']
        
        teachers = []
        teacher_id = 1
        for school_id in range(1, num_schools + 1):
            for _ in range(teachers_per_school):
                hire_year = random.randint(2010, 2023)
                teachers.append({
                    'TeacherID': teacher_id,
                    'SchoolID': school_id,
                    'FirstName': random.choice(first_names),
                    'LastName': random.choice(last_names),
                    'Email': f'teacher{teacher_id}@centralusd.edu',
                    'Phone': f'555-{random.randint(1000, 9999)}',
                    'HireDate': f'{hire_year}-{random.randint(1,12):02d}-{random.randint(1,28):02d}',
                    'YearsExperience': 2024 - hire_year,
                    'CertificationLevel': random.choice(cert_levels),
                    'SubjectSpecialty': random.choice(subjects),
                    'IsActive': 1
                })
                teacher_id += 1
        return pd.DataFrame(teachers)
    
    def generate_teachers_variable(self, num_schools=20, school_config=None):
        """Generate teachers data with variable count per school"""
        subjects = ['Math', 'English', 'Science', 'Social Studies', 'PE', 'Art', 'Music', 'Special Ed']
        cert_levels = ['Provisional', 'Standard', 'Advanced']
        first_names = ['John', 'Sarah', 'Michael', 'Jennifer', 'David', 'Emily', 'James', 'Lisa']
        last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis']
        
        teachers = []
        teacher_id = 1
        for school_id in range(1, num_schools + 1):
            teachers_per_school = school_config[school_id]['teachers'] if school_config else 15
            for _ in range(teachers_per_school):
                hire_year = random.randint(2010, 2023)
                teachers.append({
                    'TeacherID': teacher_id,
                    'SchoolID': school_id,
                    'FirstName': random.choice(first_names),
                    'LastName': random.choice(last_names),
                    'Email': f'teacher{teacher_id}@centralusd.edu',
                    'Phone': f'555-{random.randint(1000, 9999)}',
                    'HireDate': f'{hire_year}-{random.randint(1,12):02d}-{random.randint(1,28):02d}',
                    'YearsExperience': 2024 - hire_year,
                    'CertificationLevel': random.choice(cert_levels),
                    'SubjectSpecialty': random.choice(subjects),
                    'IsActive': 1
                })
                teacher_id += 1
        return pd.DataFrame(teachers)
    
    
    def generate_classes(self, num_schools=100, teachers_df=None):
        """Generate classes data"""
        subjects = ['Math', 'English', 'Science', 'Social Studies', 'PE', 'Art', 'Music', 'Language Arts', 'Technology']
        
        classes = []
        class_id = 1
        
        # For each school, generate classes based on school type
        for school_id in range(1, num_schools + 1):
            # Get teachers for this school
            if teachers_df is not None:
                school_teachers = teachers_df[teachers_df['SchoolID'] == school_id]['TeacherID'].tolist()
            else:
                school_teachers = []
            
            # Determine school type from school_id
            school_type_idx = (school_id - 1) % 3
            
            if school_type_idx == 0:  # Elementary: K-5
                for grade in range(1, 6):
                    for section in range(1, 4):  # 3 sections per grade
                        if not school_teachers:
                            teacher_id = (grade * school_id * section) % 2000 + 1
                        else:
                            teacher_id = random.choice(school_teachers) if school_teachers else teacher_id
                        
                        classes.append({
                            'ClassID': class_id,
                            'SchoolID': school_id,
                            'GradeLevelID': grade,
                            'TeacherID': teacher_id,
                            'ClassName': f'Grade {grade} - Section {section} - {random.choice(subjects)}',
                            'RoomNumber': f'{grade}{section:02d}',
                            'Subject': random.choice(subjects),
                            'Period': section,
                            'MaxCapacity': 25,
                            'AcademicYear': 2025,
                            'SchoolYear': '2024-2025',
                            'IsActive': 1
                        })
                        class_id += 1
            
            elif school_type_idx == 1:  # Middle: 6-8
                for grade in range(6, 9):
                    for period in range(1, 7):  # 6 periods
                        if not school_teachers:
                            teacher_id = (grade * school_id * period) % 2000 + 1
                        else:
                            teacher_id = random.choice(school_teachers) if school_teachers else teacher_id
                        
                        classes.append({
                            'ClassID': class_id,
                            'SchoolID': school_id,
                            'GradeLevelID': grade,
                            'TeacherID': teacher_id,
                            'ClassName': f'Period {period} - Grade {grade} - {random.choice(subjects)}',
                            'RoomNumber': f'{grade}{period:02d}',
                            'Subject': random.choice(subjects),
                            'Period': period,
                            'MaxCapacity': 30,
                            'AcademicYear': 2025,
                            'SchoolYear': '2024-2025',
                            'IsActive': 1
                        })
                        class_id += 1
            
            else:  # High School: 9-12
                for grade in range(9, 13):
                    for period in range(1, 9):  # 8 periods
                        if not school_teachers:
                            teacher_id = (grade * school_id * period) % 2000 + 1
                        else:
                            teacher_id = random.choice(school_teachers) if school_teachers else teacher_id
                        
                        classes.append({
                            'ClassID': class_id,
                            'SchoolID': school_id,
                            'GradeLevelID': grade,
                            'TeacherID': teacher_id,
                            'ClassName': f'Period {period} - Grade {grade} - {random.choice(subjects)}',
                            'RoomNumber': f'{grade}{period:02d}',
                            'Subject': random.choice(subjects),
                            'Period': period,
                            'MaxCapacity': 32,
                            'AcademicYear': 2025,
                            'SchoolYear': '2024-2025',
                            'IsActive': 1
                        })
                        class_id += 1
        
        return pd.DataFrame(classes)
    
    def generate_students(self, num_schools=3, students_per_school=300):
        """Generate students data"""
        first_names = ['Alex', 'Bailey', 'Casey', 'Dakota', 'Eden', 'Finley', 'Gabriel', 'Harper',
                      'Isaiah', 'Jordan', 'Kendrick', 'Logan', 'Morgan', 'Noah', 'Oliver', 'Parker']
        last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
                     'Martinez', 'Rodriguez', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'White']
        
        students = []
        student_id = 1
        
        for school_id in range(1, num_schools + 1):
            for _ in range(students_per_school):
                birth_year = random.randint(2006, 2020)
                enrollment_date = self.base_date - timedelta(days=random.randint(100, 800))
                
                students.append({
                    'StudentID': student_id,
                    'SchoolID': school_id,
                    'FirstName': random.choice(first_names),
                    'LastName': random.choice(last_names),
                    'DateOfBirth': f'{birth_year}-{random.randint(1,12):02d}-{random.randint(1,28):02d}',
                    'Gender': random.choice(['Male', 'Female', 'Other']),
                    'EnrollmentDate': enrollment_date.strftime('%Y-%m-%d'),
                    'IsActive': 1 if random.random() > 0.05 else 0,
                    'EconomicStatus': random.choices(['Free', 'Reduced', 'Full Price'], weights=[0.4, 0.35, 0.25], k=1)[0],
                    'ELL': 1 if random.random() < 0.15 else 0,
                    'SpecialEducation': 1 if random.random() < 0.12 else 0,
                    'IEPStatus': random.choices(['No IEP', 'Current IEP', 'Evaluation Pending'], 
                                              weights=[0.88, 0.10, 0.02], k=1)[0]
                })
                student_id += 1
        
        return pd.DataFrame(students)
    
    def generate_students_variable(self, num_schools=20, school_config=None):
        """Generate students data with variable count per school and per-student consistency attributes"""
        first_names = ['Alex', 'Bailey', 'Casey', 'Dakota', 'Eden', 'Finley', 'Gabriel', 'Harper',
                      'Isaiah', 'Jordan', 'Kendrick', 'Logan', 'Morgan', 'Noah', 'Oliver', 'Parker']
        last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
                     'Martinez', 'Rodriguez', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'White']
        
        students = []
        student_id = 1
        
        for school_id in range(1, num_schools + 1):
            students_per_school = school_config[school_id]['students'] if school_config else 300
            for _ in range(students_per_school):
                birth_year = random.randint(2006, 2020)
                enrollment_date = self.base_date - timedelta(days=random.randint(100, 800))
                
                # Generate per-student profile for consistency
                # Performance level (0-100): influences all grades across all classes
                # Distribution: more students in middle range (40-70), fewer at extremes
                performance_bucket = random.choices(
                    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],  # 11 buckets of 0-100
                    weights=[1, 2, 3, 5, 8, 12, 15, 15, 12, 8, 4]  # Normal-ish distribution
                )[0]
                performance_level = performance_bucket * 10 + random.randint(0, 9)
                
                # Attendance propensity (0-1): higher = more present
                # CORRELATED with performance: higher performers attend better, lower performers miss more
                # But with variance: some good students have attendance issues, some struggling students attend well
                
                if performance_level >= 75:
                    # High performers: 75% good attendance, 20% moderate, 5% low
                    propensity_type = random.choices(['high', 'moderate', 'low'], weights=[0.75, 0.20, 0.05])[0]
                elif performance_level >= 50:
                    # Average performers: 50% good, 40% moderate, 10% low
                    propensity_type = random.choices(['high', 'moderate', 'low'], weights=[0.50, 0.40, 0.10])[0]
                else:
                    # Struggling performers: 20% good attendance, 40% moderate, 40% low (more absences)
                    propensity_type = random.choices(['high', 'moderate', 'low'], weights=[0.20, 0.40, 0.40])[0]
                
                if propensity_type == 'high':
                    attendance_propensity = random.uniform(0.88, 0.98)
                elif propensity_type == 'moderate':
                    attendance_propensity = random.uniform(0.70, 0.85)
                else:
                    attendance_propensity = random.uniform(0.50, 0.70)
                
                # Day-of-week absence pattern (some kids miss more on Fridays/Mondays)
                day_absence_pattern = {
                    0: random.uniform(-0.05, 0.10),  # Monday
                    1: random.uniform(-0.05, 0.05),  # Tuesday
                    2: random.uniform(-0.05, 0.05),  # Wednesday
                    3: random.uniform(-0.05, 0.05),  # Thursday
                    4: random.uniform(0.00, 0.15),   # Friday (higher absence tendency)
                }
                
                # Store per-student profile
                self.student_profiles[student_id] = {
                    'performance_level': performance_level,
                    'attendance_propensity': attendance_propensity,
                    'day_absence_pattern': day_absence_pattern
                }
                
                students.append({
                    'StudentID': student_id,
                    'SchoolID': school_id,
                    'FirstName': random.choice(first_names),
                    'LastName': random.choice(last_names),
                    'DateOfBirth': f'{birth_year}-{random.randint(1,12):02d}-{random.randint(1,28):02d}',
                    'Gender': random.choice(['Male', 'Female', 'Other']),
                    'EnrollmentDate': enrollment_date.strftime('%Y-%m-%d'),
                    'IsActive': 1 if random.random() > 0.05 else 0,
                    'EconomicStatus': random.choices(['Free', 'Reduced', 'Full Price'], weights=[0.4, 0.35, 0.25], k=1)[0],
                    'ELL': 1 if random.random() < 0.15 else 0,
                    'SpecialEducation': 1 if random.random() < 0.12 else 0,
                    'IEPStatus': random.choices(['No IEP', 'Current IEP', 'Evaluation Pending'], 
                                              weights=[0.88, 0.10, 0.02], k=1)[0],
                    'PerformanceLevel': round(performance_level, 2),
                    'AttendancePropensity': round(attendance_propensity, 2)
                })
                student_id += 1
        
        return pd.DataFrame(students)
    
    
    def generate_enrollment(self, students_df, classes_df):
        """Generate enrollment data"""
        enrollments = []
        enrollment_id = 1
        
        for _, student in students_df.iterrows():
            if not student['IsActive']:
                continue
            
            # Each student enrolled in 5-8 classes
            num_classes = random.randint(5, 8)
            student_classes = random.sample(
                classes_df[classes_df['SchoolID'] == student['SchoolID']]['ClassID'].tolist(),
                min(num_classes, len(classes_df[classes_df['SchoolID'] == student['SchoolID']]))
            )
            
            for class_id in student_classes:
                enrollments.append({
                    'EnrollmentID': enrollment_id,
                    'StudentID': student['StudentID'],
                    'ClassID': class_id,
                    'EnrollmentDate': student['EnrollmentDate'],
                    'WithdrawalDate': None,
                    'IsActive': 1,
                    'EnrollmentStatus': 'Active'
                })
                enrollment_id += 1
        
        return pd.DataFrame(enrollments)
    
    def generate_attendance(self, students_df, enrollment_df):
        """Generate attendance data with per-student consistency patterns"""
        attendance = []
        attendance_id = 1
        
        school_days = self.get_school_days(self.base_date, self.base_date + timedelta(days=180))
        
        for _, enrollment in enrollment_df.iterrows():
            student_id = enrollment['StudentID']
            class_id = enrollment['ClassID']
            
            # Get student's attendance profile
            profile = self.student_profiles.get(student_id, {
                'attendance_propensity': 0.90,
                'day_absence_pattern': {0: 0.05, 1: 0.02, 2: 0.02, 3: 0.02, 4: 0.08}
            })
            
            # Generate attendance for ~90% of school days
            for school_day in school_days[::random.randint(1, 2)]:
                day_of_week = school_day.weekday()
                
                # Base propensity adjusted by day-of-week pattern
                day_modifier = profile['day_absence_pattern'].get(day_of_week, 0)
                adjusted_propensity = profile['attendance_propensity'] + day_modifier
                adjusted_propensity = max(0.1, min(0.95, adjusted_propensity))  # Clamp between 0.1 and 0.95
                
                # Determine status based on adjusted propensity
                if random.random() < adjusted_propensity:
                    status = 'Present'
                    reason = None
                elif random.random() < 0.4:  # Of absences, 40% are tardies
                    status = 'Tardy'
                    reason = random.choice(['Late Bus', 'Family Issue', 'Oversleep'])
                else:
                    # 60% actual absences, with reasons
                    status = 'Absent'
                    reason = random.choice(['Sick', 'Doctor Appointment', 'Family Leave', 'Unknown'])
                    
                    # 5% of absences are excused
                    if random.random() < 0.05:
                        status = 'Excused'
                
                attendance.append({
                    'AttendanceID': attendance_id,
                    'StudentID': student_id,
                    'ClassID': class_id,
                    'AttendanceDate': school_day.strftime('%Y-%m-%d'),
                    'AttendanceStatus': status,
                    'Reason': reason
                })
                attendance_id += 1
        
        return pd.DataFrame(attendance)
    
    def generate_grade_assessments(self, students_df, enrollment_df):
        """Generate grade assessments influenced by student performance level"""
        assessments = []
        assessment_id = 1
        
        assessment_types = ['Quiz', 'Test', 'Homework', 'Project', 'Classwork']
        
        for _, enrollment in enrollment_df.iterrows():
            student_id = enrollment['StudentID']
            class_id = enrollment['ClassID']
            
            # Get student's performance level
            student_data = students_df[students_df['StudentID'] == student_id]
            if len(student_data) > 0:
                performance_level = student_data.iloc[0]['PerformanceLevel']
            else:
                performance_level = random.randint(0, 100)
            
            # 15-25 assessments per student per class
            num_assessments = random.randint(15, 25)
            
            for _ in range(num_assessments):
                points_possible = random.choice([10, 20, 25, 50, 100])
                
                # Points earned influenced by performance level + some randomness
                # Performance level 80 means they score around 80% on average
                base_percentage = performance_level
                variance = random.uniform(-15, 15)  # Random variance within 15 points
                percentage = max(0, min(100, base_percentage + variance))
                
                points_earned = int((percentage / 100) * points_possible)
                
                # Convert percentage to letter grade
                if percentage >= 90:
                    letter = 'A'
                elif percentage >= 80:
                    letter = 'B'
                elif percentage >= 70:
                    letter = 'C'
                elif percentage >= 60:
                    letter = 'D'
                else:
                    letter = 'F'
                
                assessments.append({
                    'AssessmentID': assessment_id,
                    'StudentID': student_id,
                    'ClassID': class_id,
                    'AssignmentName': f'Assignment {random.randint(1, 20)}',
                    'AssessmentDate': self.random_date_range().strftime('%Y-%m-%d'),
                    'AssessmentType': random.choice(assessment_types),
                    'PointsEarned': points_earned,
                    'PointsPossible': points_possible,
                    'GradeLetter': letter,
                    'GradePercentage': round(percentage, 2),
                    'Comments': random.choice(['Good work!', 'Needs review', 'Excellent!', 'See me for help'])
                })
                assessment_id += 1
        
        return pd.DataFrame(assessments)
    
    def generate_student_success_metrics(self, students_df, enrollment_df, assessments_df):
        """Generate student success metrics per reporting period with correlated data"""
        metrics = []
        metric_id = 1
        
        # Pre-calculate average grades by student and class
        if len(assessments_df) > 0:
            avg_grades = assessments_df.groupby(['StudentID', 'ClassID'])['GradePercentage'].mean().reset_index()
            avg_grades.columns = ['StudentID', 'ClassID', 'AvgGradePercentage']
        else:
            avg_grades = pd.DataFrame(columns=['StudentID', 'ClassID', 'AvgGradePercentage'])
        
        # Pre-calculate attendance percentage by student (across all classes)
        attendance_stats = {}
        if len(assessments_df) > 0:  # We'll use assessments as proxy enrollment
            for student_id in students_df['StudentID'].unique():
                profile = self.student_profiles.get(student_id, {'attendance_propensity': 0.90})
                # Attendance percentage ~ attendance_propensity * 100, with some variance
                attendance_percentage = max(50, min(100, profile['attendance_propensity'] * 100 + random.uniform(-5, 5)))
                attendance_stats[student_id] = attendance_percentage
        
        for _, enrollment in enrollment_df.iterrows():
            student_id = enrollment['StudentID']
            class_id = enrollment['ClassID']
            
            # Look up pre-calculated average grade
            avg_row = avg_grades[(avg_grades['StudentID'] == student_id) & 
                                 (avg_grades['ClassID'] == class_id)]
            
            if len(avg_row) > 0:
                avg_percentage = avg_row['AvgGradePercentage'].values[0]
            else:
                avg_percentage = random.uniform(60, 95)
            
            # Get attendance percentage for this student
            attendance_percentage = attendance_stats.get(student_id, random.uniform(75, 100))
            
            # Convert grade percentage to letter
            if avg_percentage >= 90:
                letter = 'A'
            elif avg_percentage >= 80:
                letter = 'B'
            elif avg_percentage >= 70:
                letter = 'C'
            elif avg_percentage >= 60:
                letter = 'D'
            else:
                letter = 'F'
            
            # Intervention needed if grades are low OR attendance is low
            intervention_needed = (avg_percentage < 70) or (attendance_percentage < 80)
            
            # Generate Q1 and Q2 metrics
            for period_num, period_name in [(1, 'Q1'), (2, 'Q2')]:
                metrics.append({
                    'MetricID': metric_id,
                    'StudentID': student_id,
                    'ClassID': class_id,
                    'ReportingPeriod': period_name,
                    'AcademicYear': 2025,
                    'OverallGrade': letter,
                    'OverallPercentage': round(avg_percentage, 2),
                    'AttendancePercentage': round(attendance_percentage, 2),
                    'AssignmentCompletionRate': round(min(100, attendance_percentage + random.uniform(-10, 10)), 2),
                    'BehaviorRating': random.randint(1, 5),
                    'TeacherComments': random.choice(['Good progress', 'Needs support', 'Excellent work', 'Average performance']),
                    'ParentContact': 1 if intervention_needed else random.choice([0, 0, 1]),  # 33% contact if not needed
                    'InterventionNeeded': 1 if intervention_needed else 0,
                    'InterventionType': random.choice(['Tutoring', 'Counseling', 'Study Group', None]) if intervention_needed else None,
                })
                metric_id += 1
        
        return pd.DataFrame(metrics)
    
    def generate_student_interventions(self, students_df, metrics_df):
        """Generate student interventions based on actual performance metrics and student difficulty"""
        interventions = []
        intervention_id = 1
        
        intervention_types = ['Academic Tutoring', 'Behavioral Support', 'Counseling', 'Special Education', 'ELL Support']
        providers = ['Ms. Johnson', 'Mr. Smith', 'Dr. Williams', 'Mrs. Brown', 'Mr. Garcia']
        frequencies = ['Daily', '3x per week', '2x per week', 'Weekly']
        effectiveness_levels = ['Highly Effective', 'Moderately Effective', 'Minimal Effect', 'Not Yet Evaluated']
        
        # Find students who need interventions based on actual metrics and performance difficulty
        students_needing_intervention = metrics_df[
            (metrics_df['InterventionNeeded'] == 1) & 
            (metrics_df['ReportingPeriod'] == 'Q1')  # Use Q1 to avoid duplicates
        ]['StudentID'].unique()
        
        for student_id in students_needing_intervention:
            # Get student data to check characteristics
            student_data = students_df[students_df['StudentID'] == student_id]
            if len(student_data) == 0:
                continue
                
            is_ell = student_data.iloc[0]['ELL']
            is_sped = student_data.iloc[0]['SpecialEducation']
            performance_level = student_data.iloc[0]['PerformanceLevel']
            attendance_propensity = student_data.iloc[0]['AttendancePropensity']
            
            # Difficulty score: lower performance + lower attendance = more difficult
            # This influences number and frequency of interventions
            difficulty_score = (100 - performance_level) + (1 - attendance_propensity) * 100
            
            # Struggling students (difficulty_score > 100) get MORE interventions
            if difficulty_score > 120:
                # Severest cases: 2-4 interventions
                num_interventions = random.randint(2, 4)
                intervention_frequency_bias = ['Daily', '3x per week']  # More intensive
            elif difficulty_score > 80:
                # Moderate difficulty: 1-3 interventions
                num_interventions = random.randint(1, 3)
                intervention_frequency_bias = ['2x per week', 'Weekly']
            else:
                # Milder cases: 1-2 interventions
                num_interventions = random.randint(1, 2)
                intervention_frequency_bias = ['Weekly']
            
            for _ in range(num_interventions):
                start_date = self.base_date + timedelta(days=random.randint(0, 150))
                end_date = None
                status = random.choices(['Active', 'Completed', 'Paused'], weights=[0.5, 0.35, 0.15])[0]
                
                if status == 'Completed':
                    end_date = start_date + timedelta(days=random.randint(30, 120))
                
                # Choose intervention type based on student characteristics and difficulty
                if is_sped and random.random() < 0.6:
                    intervention_type = 'Special Education'
                elif is_ell and random.random() < 0.6:
                    intervention_type = 'ELL Support'
                elif performance_level < 50:
                    # Struggling academically: prioritize tutoring
                    intervention_type = random.choices(['Academic Tutoring', 'Counseling'], weights=[0.7, 0.3])[0]
                elif attendance_propensity < 0.7:
                    # Attendance issues: add behavioral support/counseling
                    intervention_type = random.choices(['Behavioral Support', 'Counseling'], weights=[0.6, 0.4])[0]
                else:
                    intervention_type = random.choice(['Academic Tutoring', 'Behavioral Support', 'Counseling'])
                
                interventions.append({
                    'InterventionID': intervention_id,
                    'StudentID': student_id,
                    'StartDate': start_date.strftime('%Y-%m-%d'),
                    'EndDate': end_date.strftime('%Y-%m-%d') if end_date else None,
                    'InterventionType': intervention_type,
                    'Provider': random.choice(providers),
                    'Frequency': random.choice(intervention_frequency_bias),
                    'Goals': f'Improve academic performance and engagement; Achieve grade improvement of at least 10%',
                    'Status': status,
                    'Effectiveness': random.choices(
                        effectiveness_levels,
                        weights=[0.2, 0.4, 0.2, 0.2] if status == 'Active' else [0.3, 0.4, 0.15, 0.15]
                    )[0]
                })
                intervention_id += 1
        
        return pd.DataFrame(interventions)
    
    def generate_all(self, output_dir='./', num_schools=20):
        """Generate all tables and save to CSV files.
        Large tables (Attendance, GradeAssessments) are split by school to keep files under 50MB."""
        # Build per-school configuration with random student counts
        school_config = {}
        for school_id in range(1, num_schools + 1):
            students_per_school = random.randint(300, 600)
            teachers_per_school = max(1, students_per_school // 20)  # 1 teacher per 20 students
            school_config[school_id] = {
                'students': students_per_school,
                'teachers': teachers_per_school
            }
        
        print(f"Generating sample K12 data ({num_schools} schools, random students per school 300-600, 1 teacher per 20 students)...")
        
        output_path = Path(output_dir)
        output_path.mkdir(exist_ok=True)
        
        # Generate in order of dependencies
        print("  - Schools...")
        schools = self.generate_schools(num_schools=num_schools)
        schools.to_csv(output_path / 'Schools.csv', index=False)
        
        print("  - Grade Levels...")
        grades = self.generate_grade_levels()
        grades.to_csv(output_path / 'GradeLevels.csv', index=False)
        
        print("  - Teachers...")
        teachers = self.generate_teachers_variable(num_schools=num_schools, school_config=school_config)
        teachers.to_csv(output_path / 'Teachers.csv', index=False)
        
        print("  - Classes...")
        classes = self.generate_classes(num_schools=num_schools, teachers_df=teachers)
        classes.to_csv(output_path / 'Classes.csv', index=False)
        
        print("  - Students...")
        students = self.generate_students_variable(num_schools=num_schools, school_config=school_config)
        students.to_csv(output_path / 'Students.csv', index=False)
        
        print("  - Enrollment...")
        enrollment = self.generate_enrollment(students, classes)
        enrollment.to_csv(output_path / 'Enrollment.csv', index=False)
        
        print("  - Attendance (split by school)...")
        attendance = self.generate_attendance(students, enrollment)
        self._save_split_by_school(attendance, 'Attendance', output_path, students)
        total_attendance = len(attendance)
        
        print("  - Grade Assessments (split by school)...")
        assessments = self.generate_grade_assessments(students, enrollment)
        self._save_split_by_school(assessments, 'GradeAssessments', output_path, students)
        total_assessments = len(assessments)
        
        print("  - Student Success Metrics...")
        metrics = self.generate_student_success_metrics(students, enrollment, assessments)
        metrics.to_csv(output_path / 'StudentSuccessMetrics.csv', index=False)
        
        print("  - Student Interventions...")
        interventions = self.generate_student_interventions(students, metrics)
        interventions.to_csv(output_path / 'StudentInterventions.csv', index=False)
        
        print(f"\n✓ All data generated successfully in {output_path}/")
        print(f"\nData Summary:")
        print(f"  - Schools: {len(schools)}")
        print(f"  - Teachers: {len(teachers)}")
        print(f"  - Classes: {len(classes)}")
        print(f"  - Students: {len(students)}")
        print(f"  - Enrollments: {len(enrollment)}")
        print(f"  - Attendance Records (total): {total_attendance}")
        print(f"  - Assessments (total): {total_assessments}")
        print(f"  - Success Metrics: {len(metrics)}")
        print(f"  - Interventions: {len(interventions)}")
        
        # Print per-school breakdown
        print(f"\nPer-School Breakdown:")
        for school_id in sorted(school_config.keys()):
            config = school_config[school_id]
            print(f"  - School {school_id}: {config['students']} students, {config['teachers']} teachers")
    
    def _save_split_by_school(self, dataframe, table_name, output_path, students_df=None):
        """Split a dataframe by school and save to multiple CSV files to keep files under 50MB"""
        # If SchoolID is not in dataframe, get it from students via StudentID
        if 'SchoolID' not in dataframe.columns and students_df is not None:
            school_map = students_df[['StudentID', 'SchoolID']].drop_duplicates()
            dataframe = dataframe.merge(school_map, on='StudentID', how='left')
        
        if 'SchoolID' not in dataframe.columns:
            # Fallback: save as single file if we can't determine school
            filename = output_path / f'{table_name}.csv'
            dataframe.to_csv(filename, index=False)
            file_size_mb = filename.stat().st_size / (1024 * 1024)
            print(f"    - {filename.name}: {file_size_mb:.2f} MB ({len(dataframe)} rows)")
            return
        
        for school_id in sorted(dataframe['SchoolID'].unique()):
            school_data = dataframe[dataframe['SchoolID'] == school_id]
            # Remove the SchoolID column from output if it wasn't originally there
            if table_name in ['Attendance', 'GradeAssessments']:
                school_data = school_data.drop('SchoolID', axis=1)
            
            filename = output_path / f'{table_name}_School_{school_id}.csv'
            school_data.to_csv(filename, index=False)
            file_size_mb = filename.stat().st_size / (1024 * 1024)
            print(f"    - {filename.name}: {file_size_mb:.2f} MB ({len(school_data)} rows)")


if __name__ == '__main__':
    import os
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(script_dir, '..')  # Parent directory (SampleData)
    
    generator = K12DataGenerator(seed=42)
    generator.generate_all(output_dir=output_dir)
