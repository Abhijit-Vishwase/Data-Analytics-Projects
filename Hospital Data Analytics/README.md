# Hospital Data Analytics (SQL Project)

## Objective
Analyze hospital management data using SQL to uncover insights on patient behavior, doctor utilization, appointment trends, and revenue performance. The goal is to identify operational inefficiencies and support data-driven decision-making.

---

## Dataset Overview

The dataset consists of multiple relational tables:

- `patients` – demographic and registration details  
- `doctors` – specialization and experience  
- `appointments` – scheduling and status  
- `treatments` – procedures and costs  
- `billing` – payment and revenue data  

---

## Tools & Skills Used

- SQL (MySQL)  
- Joins (INNER JOIN, LEFT JOIN)  
- Aggregations (SUM, COUNT, AVG)  
- Window Functions (RANK, NTILE, LAG, ROW_NUMBER)  
- CTEs (Common Table Expressions)  
- Data Cleaning & Transformation  
- Analytical Thinking  

---

## Key Analysis Performed

### 1. Patient Analysis
- Patient growth and recent acquisition trends  
- Age group segmentation  
- Geographic distribution of patients  
- Email domain analysis  

---

### 2. Doctor Analysis
- Total workforce and specialization distribution  
- Senior vs junior doctor segmentation  
- Doctor workload (appointment volume)  

---

### 3. Appointment Analysis
- Appointment status distribution (Completed, Cancelled, No-show)  
- Daily and monthly trends  
- Patient engagement risk identification  

---

### 4. Treatment Analysis
- Most common treatment types  
- Cost distribution (min, max, avg)  
- Outlier detection using standard deviation  

---

### 5. Revenue Analysis
- Total revenue (paid transactions)  
- Monthly revenue trends  
- High-value patients (top spenders)  

---

### 6. Advanced Analytics
- RFM Segmentation (Recency, Frequency, Monetary)  
- Patient journey mapping (appointments → treatment → billing)  
- Visit frequency and gap analysis (LAG function)  
- Ranking:
  - Top doctors by appointments  
  - Top patients by spending  

---

## Key Insights

- Patient acquisition has declined in recent months  
- Some doctors are overloaded while others are underutilized  
- High number of no-shows indicates patient disengagement risk  
- Revenue is concentrated among a small group of high-value patients  
- Certain treatments dominate demand, indicating specialization opportunities  

---

## Sample Query (RFM Segmentation)

```sql
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
)
