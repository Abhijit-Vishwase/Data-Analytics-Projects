# Credit Card Fraud Detection

## Project Overview
This project focuses on detecting fraudulent credit card transactions using machine learning techniques. The dataset is highly imbalanced, so special techniques were used to improve fraud detection performance.

---

## Problem Statement
The goal is to build a model that can accurately identify fraudulent transactions while minimizing false positives.

---

## Dataset
- Source: Kaggle Credit Card Fraud Detection Dataset
- Contains anonymized transaction features
- Highly imbalanced dataset (very few fraud cases)

---

## Approach

### Data Preprocessing
- Checked for missing values
- Feature scaling using StandardScaler
- Extracted 'Hour' feature from 'Time'

### Handling Imbalanced Data
- Used SMOTE (Synthetic Minority Oversampling Technique)

### Models Used
- Logistic Regression
- Random Forest Classifier

---

## Model Evaluation
- Confusion Matrix
- Classification Report (Precision, Recall, F1-score)
- ROC-AUC Score

---

## Results
- Logistic Regression: Higher recall (better fraud detection)
- Random Forest: Better overall performance
- ROC-AUC Score: ~0.97

---

## Conclusion
Logistic Regression is better for detecting fraud cases (high recall), while Random Forest provides a balance between precision and recall. The final model choice depends on business requirements.

---

## Technologies Used
- Python
- Pandas, NumPy
- Scikit-learn
- Matplotlib, Seaborn
- Imbalanced-learn (SMOTE)

---

## Project Structure

Credit-Card-Fraud-Detection/
│
├── Credit Card Fraud Detection.ipynb
├── README.md
├── requirements.txt

---

## Future Improvements
- Hyperparameter tuning
- Cross-validation
- Model deployment (Flask/Streamlit)

---

## How to Run

1. Clone the repository
2. Install dependencies:
   pip install -
     numpy
     pandas
     matplotlib
     seaborn
     scikit-learn
     imbalanced-learn
     jupyter
4. Run the notebook in Jupyter
