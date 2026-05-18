-- ============================================
-- PROJECT: Hospital Data Analytics (SQL)
-- ============================================

-- Objective:
-- Analyze hospital operations data to uncover insights on patient behavior,
-- doctor utilization, appointment trends, and revenue performance.
-- Identify inefficiencies and opportunities for business improvement.

USE healthcare_analysis;

-- ============================================
-- KPI SUMMARY
-- ============================================

-- Total Patients
SELECT COUNT(*) AS total_patients FROM patients;

-- Total Revenue (Paid Only)
SELECT SUM(amount) AS total_revenue
FROM billing
WHERE payment_status = 'Paid';

-- Total Appointments
SELECT COUNT(*) AS total_appointments FROM appointments;

-- No-show Rate (%)
SELECT 
ROUND(
    SUM(CASE WHEN status = 'No-show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2
) AS no_show_rate
FROM appointments;


-- ============================================
-- PATIENT ANALYSIS
-- ============================================

-- Recent Patient Acquisition (Last 30 Days)
SELECT *
FROM patients
WHERE registration_date >= (
    SELECT MAX(registration_date) - INTERVAL 30 DAY FROM patients
)
ORDER BY registration_date DESC;

-- Insight:
-- Very low recent registrations > potential decline in patient acquisition.

-- Patient Distribution by Address
SELECT address, COUNT(*) AS patient_count
FROM patients
GROUP BY address
ORDER BY patient_count DESC;

-- Age Segmentation
SELECT 
CASE
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 18 THEN 'Under 18'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 18 AND 35 THEN 'Adults'
    WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 36 AND 55 THEN 'Mature'
    ELSE 'Seniors'
END AS age_group,
COUNT(*) AS patient_count
FROM patients
GROUP BY age_group
ORDER BY patient_count DESC;

-- Email Domain Analysis
SELECT SUBSTRING_INDEX(email, '@', -1) AS email_domain,
COUNT(*) AS patient_count
FROM patients
GROUP BY email_domain;

-- ============================================
-- DOCTOR ANALYSIS
-- ============================================

-- Total Doctors
SELECT COUNT(*) AS total_doctors FROM doctors;

-- Specializations Available
SELECT DISTINCT specialization FROM doctors;

-- Doctor Experience Distribution
SELECT specialization,
COUNT(*) AS total_doctors,
SUM(CASE WHEN years_experience >= 15 THEN 1 ELSE 0 END) AS senior_doctors,
SUM(CASE WHEN years_experience < 15 THEN 1 ELSE 0 END) AS junior_doctors
FROM doctors
GROUP BY specialization;

-- Doctor Workload (Utilization)
SELECT
CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
d.specialization,
COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a
ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, doctor_name, d.specialization
ORDER BY total_appointments DESC;


-- Identify overloaded doctors (above average appointments)
WITH doctor_load AS (
    SELECT 
        d.doctor_id,
        CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
        COUNT(a.appointment_id) AS total_appointments
    FROM doctors d
    LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id
    GROUP BY d.doctor_id, doctor_name
)
SELECT *
FROM doctor_load
WHERE total_appointments > (
    SELECT AVG(total_appointments) FROM doctor_load
);


-- ============================================
-- APPOINTMENT ANALYSIS
-- ============================================

-- Appointment Status Distribution
SELECT status, COUNT(*) AS count
FROM appointments
GROUP BY status;

-- Insight:
-- High "No-show" or "Cancelled" > indicates patient disengagement risk.

-- Appointments in Last 7 Days
SELECT *
FROM appointments
WHERE appointment_date >= (
    SELECT MAX(appointment_date) - INTERVAL 7 DAY FROM appointments
)
ORDER BY appointment_date DESC;

-- Monthly Appointment Trend
SELECT 
YEAR(appointment_date) AS year,
MONTH(appointment_date) AS month,
COUNT(*) AS appointment_count
FROM appointments
GROUP BY year, month
ORDER BY year, month;

-- Appointments by Day of Week
SELECT DAYNAME(appointment_date) AS day_of_week,
COUNT(*) AS appointment_count
FROM appointments
GROUP BY day_of_week;

-- ============================================
-- TREATMENT ANALYSIS
-- ============================================

-- Most Common Treatments
SELECT treatment_type,
COUNT(*) AS treatment_count
FROM treatments
GROUP BY treatment_type
ORDER BY treatment_count DESC;

-- Cost Analysis
SELECT 
MIN(cost) AS min_cost,
MAX(cost) AS max_cost,
ROUND(AVG(cost), 2) AS avg_cost
FROM treatments;

-- Outlier Detection (High Cost Treatments)
SELECT treatment_id, treatment_type, cost
FROM treatments
WHERE cost > (
    SELECT AVG(cost) + 2 * STDDEV(cost) FROM treatments
);

-- ============================================
-- REVENUE ANALYSIS
-- ============================================

-- Payment Status Distribution
SELECT payment_status, COUNT(*) AS bill_count
FROM billing
GROUP BY payment_status;

-- Monthly Revenue Trend
SELECT 
YEAR(bill_date) AS year,
MONTH(bill_date) AS month,
SUM(amount) AS total_revenue
FROM billing
WHERE payment_status = 'Paid'
GROUP BY year, month
ORDER BY year, month;

-- Top Revenue Generating Patients
SELECT
p.patient_id,
CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
SUM(b.amount) AS total_spent
FROM patients p
JOIN billing b
ON p.patient_id = b.patient_id
WHERE b.payment_status = 'Paid'
GROUP BY p.patient_id, patient_name
ORDER BY total_spent DESC;

-- ============================================
-- ADVANCED ANALYTICS
-- ============================================

-- Patient Journey (Appointments > Treatments > Billing)
SELECT
p.patient_id,
CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
a.appointment_id,
a.appointment_date,
a.status,
t.treatment_type,
t.cost,
b.amount,
b.payment_status
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
LEFT JOIN treatments t ON a.appointment_id = t.appointment_id
LEFT JOIN billing b ON t.treatment_id = b.treatment_id;

-- RFM Segmentation
WITH rfm AS (
    SELECT
        p.patient_id,
        MAX(a.appointment_date) AS last_visit,
        COUNT(DISTINCT a.appointment_id) AS frequency,
        COALESCE(SUM(CASE WHEN b.payment_status='Paid' THEN b.amount END),0) AS monetary
    FROM patients p
    LEFT JOIN appointments a ON p.patient_id = a.patient_id
    LEFT JOIN billing b ON p.patient_id = b.patient_id
    GROUP BY p.patient_id
),
scored AS (
    SELECT *,
    DATEDIFF(CURDATE(), last_visit) AS recency_days,
    NTILE(4) OVER (ORDER BY DATEDIFF(CURDATE(), last_visit) ASC) AS r_score,
    NTILE(4) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(4) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm
)
SELECT *,
CASE
    WHEN r_score >=3 AND f_score >=3 AND m_score >=3 THEN 'Champions'
    WHEN f_score >=3 AND m_score >=3 THEN 'Loyal High Value'
    WHEN r_score <=2 AND f_score <=2 THEN 'At Risk'
    ELSE 'Regular'
END AS segment
FROM scored;

-- Visit Sequence per Patient
SELECT
patient_id,
appointment_id,
appointment_date,
ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY appointment_date) AS visit_number
FROM appointments;

-- Gap Between Visits
SELECT
patient_id,
appointment_id,
DATEDIFF(
    appointment_date,
    LAG(appointment_date) OVER (PARTITION BY patient_id ORDER BY appointment_date)
) AS days_between_visits
FROM appointments;

-- ============================================
-- INSIGHTS
-- ============================================

-- Patient acquisition has significantly declined, with only minimal registrations in the last 30 days, indicating potential issues in marketing or referral channels
-- High no-show and cancellation rates suggest patient disengagement and possible scheduling inefficiencies
-- Uneven doctor workload indicates suboptimal resource allocation across specializations
-- Revenue is concentrated among a small group of patients, highlighting dependency on high-value individuals
-- Certain treatments dominate demand, suggesting opportunities for specialization and resource optimization

-- ============================================
-- Business Recommendations
-- ============================================

-- Improve patient acquisition through targeted marketing campaigns
-- Implement reminder systems to reduce no-shows
-- Rebalance doctor workload across departments
-- Focus on high-demand treatments to increase revenue