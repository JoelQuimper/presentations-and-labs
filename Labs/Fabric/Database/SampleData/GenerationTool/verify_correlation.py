import pandas as pd
import numpy as np
import glob

# Load data
students = pd.read_csv('../Students.csv')
interventions = pd.read_csv('../StudentInterventions.csv')

print('=== Correlation Analysis ===\n')

# 1. Performance vs Attendance Correlation
print('1. ATTENDANCE BY PERFORMANCE LEVEL:')
perf_bins = [0, 50, 75, 100]
perf_labels = ['Low (0-50)', 'Average (50-75)', 'High (75-100)']
students['PerfLevel'] = pd.cut(students['PerformanceLevel'], bins=perf_bins, labels=perf_labels, include_lowest=True)

for label in perf_labels:
    group = students[students['PerfLevel'] == label]
    avg_attendance = group['AttendancePropensity'].mean()
    print(f'  {label:20} → Avg Attendance: {avg_attendance:.2%}')
print()

# 2. Difficulty-based interventions
print('2. INTERVENTION INTENSITY BY DIFFICULTY:')
students['DifficultyScore'] = (100 - students['PerformanceLevel']) + (1 - students['AttendancePropensity']) * 100

# Merge with intervention count
intervention_counts = interventions.groupby('StudentID').size().reset_index(name='InterventionCount')
students_with_interventions = students.merge(intervention_counts, left_on='StudentID', right_on='StudentID', how='left')
students_with_interventions['InterventionCount'] = students_with_interventions['InterventionCount'].fillna(0)

difficulty_bins = [0, 80, 120, 200]
difficulty_labels = ['Low Difficulty', 'Moderate Difficulty', 'High Difficulty']
students_with_interventions['DiffCategory'] = pd.cut(students_with_interventions['DifficultyScore'], 
                                                      bins=difficulty_bins, labels=difficulty_labels, include_lowest=True)

for label in difficulty_labels:
    group = students_with_interventions[students_with_interventions['DiffCategory'] == label]
    avg_interventions = group['InterventionCount'].mean()
    pct_with_interventions = (group['InterventionCount'] > 0).sum() / len(group) * 100
    print(f'  {label:20} → Avg Interventions: {avg_interventions:.2f}, % With Interventions: {pct_with_interventions:.1f}%')
print()

# 3. Example cases
print('3. EXAMPLE CASES:')
print('\n  High Performer + Good Attendance:')
case1 = students[(students['PerformanceLevel'] > 85) & (students['AttendancePropensity'] > 0.90)].iloc[0]
case1_interventions = interventions[interventions['StudentID'] == case1['StudentID']]
print(f'    Student {case1["StudentID"]}: Performance={case1["PerformanceLevel"]:.0f}, Attendance={case1["AttendancePropensity"]:.2%}')
print(f'    Interventions: {len(case1_interventions)}')

print('\n  Struggling + Poor Attendance:')
case2 = students[(students['PerformanceLevel'] < 40) & (students['AttendancePropensity'] < 0.65)].iloc[0]
case2_interventions = interventions[interventions['StudentID'] == case2['StudentID']]
print(f'    Student {case2["StudentID"]}: Performance={case2["PerformanceLevel"]:.0f}, Attendance={case2["AttendancePropensity"]:.2%}')
print(f'    Interventions: {len(case2_interventions)}')
if len(case2_interventions) > 0:
    print(f'    Types: {", ".join(case2_interventions["InterventionType"].unique())}')
