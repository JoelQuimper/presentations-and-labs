import pandas as pd
import glob
import os

# Load data
students = pd.read_csv('../Students.csv')

# Load all split GradeAssessments files
assessment_files = sorted(glob.glob('../GradeAssessments_School_*.csv'))
assessments = pd.concat([pd.read_csv(f) for f in assessment_files], ignore_index=True)

# Load all split Attendance files
attendance_files = sorted(glob.glob('../Attendance_School_*.csv'))
attendance = pd.concat([pd.read_csv(f) for f in attendance_files], ignore_index=True)

metrics = pd.read_csv('../StudentSuccessMetrics.csv')
interventions = pd.read_csv('../StudentInterventions.csv')

print('=== Per-Student Consistency Analysis ===\n')

# Show a high performer
print('HIGH PERFORMER (Performance Level ~90):')
high_perf = students[students['PerformanceLevel'] > 85].iloc[0]
sid = high_perf['StudentID']
print(f'Student {sid}: Performance Level = {high_perf["PerformanceLevel"]}')
student_assessments = assessments[assessments['StudentID'] == sid]['GradePercentage'].describe()
print(f'  Grade Range: {student_assessments["min"]:.2f}% - {student_assessments["max"]:.2f}%')
print(f'  Average Grade: {student_assessments["mean"]:.2f}%')
student_metrics = metrics[metrics['StudentID'] == sid]['OverallPercentage'].values
print(f'  Overall Metrics: {[f"{m:.1f}%" for m in student_metrics]}')
print()

# Show a chronic absentee
print('CHRONIC ABSENTEE (Attendance Propensity ~0.55):')
chronic = students[students['AttendancePropensity'] < 0.6].iloc[0]
sid = chronic['StudentID']
print(f'Student {sid}: Attendance Propensity = {chronic["AttendancePropensity"]}')
student_attendance = attendance[attendance['StudentID'] == sid]['AttendanceStatus'].value_counts()
print(f'  Attendance Summary: {dict(student_attendance)}')
student_metrics = metrics[metrics['StudentID'] == sid]['AttendancePercentage'].values
print(f'  Reported Attendance: {[f"{m:.1f}%" for m in student_metrics]}')
print()

# Show intervention targeting
print('INTERVENTION TARGETING (Data-Driven):')
print(f'Total Students: {len(students)}')
print(f'Total Students with Interventions: {interventions["StudentID"].nunique()}')
print(f'Percentage: {interventions["StudentID"].nunique() / len(students) * 100:.1f}%')

# Check if at-risk students have interventions
at_risk = metrics[metrics['InterventionNeeded'] == 1]['StudentID'].nunique()
print(f'Students Flagged as Needing Intervention: {at_risk}')

# Verify interventions matched to at-risk students
intervention_students = set(interventions['StudentID'].unique())
at_risk_students = set(metrics[metrics['InterventionNeeded'] == 1]['StudentID'].unique())
overlap = len(intervention_students & at_risk_students)
print(f'Interventions correctly targeted to at-risk students: {overlap}/{at_risk} ({100*overlap/at_risk:.1f}%)')
