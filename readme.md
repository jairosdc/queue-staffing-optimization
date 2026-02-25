# Call Center Staff Optimization via Queueing Simulation

## Project Overview

This project models and simulates a call center system to identify the optimal staff configuration that minimizes operational cost while maintaining high service quality.

Using real salary data and empirically estimated arrival rates ($λ ≈ 19.81$ customers/hour), the system is modeled as an M/M/c queue and evaluated through Monte Carlo simulation.

The objective is to determine the most cost-efficient and stable team composition under realistic demand variability.

---

## Dataset

The analysis uses real operational and salary data, including:

- Salary distributions for Junior, Semi-Senior, and Senior advisors  
- The arrival rate 𝜆 was adjusted according to the time of day, using hourly weights derived from the observed demand distribution.
- Service rate: $μ = 3$ customers/hour per advisor  

These parameters are used to simulate system performance under multiple staffing configurations.

---

## Methodology

The workflow consists of:

1. Salary analysis by experience level  
2. Estimation of arrival rates from real operational data  
3. Queue stability analysis using M/M/c queueing models  
4. Monte Carlo simulation of alternative staff configurations  
5. Performance evaluation using service quality and risk metrics  

Key evaluation metrics:

- Average waiting time  
- Probability of critical delays (>20 min)  
- Annual dissatisfaction rate  
- System utilization and stability  

---

## Key Results

The optimal configuration identified is:

**4 Senior advisors + 4 Junior advisors**

Performance:

- Average waiting time: **1.11 minutes**
- Probability of waiting >20 minutes: **0.87%**
- Annual dissatisfaction rate: **0.72%**
- Stable operation at λ ≈ 20 customers/hour

This configuration achieves the best cost–performance trade-off and significantly reduces service risk compared to alternative staffing strategies.

---

## Tools & Technologies

- Python  
- pandas, numpy  
- matplotlib  
- Jupyter Notebook  
- Queueing theory (M/M/c model)  
- Monte Carlo simulation  

---

## Author

**Jairo Sánchez Díaz Concha**  
Mathematical Engineering student

Developed a stochastic queue simulation to optimize call center staffing using real operational and salary data. The project applies queueing theory and Monte Carlo methods to evaluate system performance and identify cost-efficient staffing configurations under uncertainty.

Core areas: 
- stochastic modeling 
- quantitative analysis 
- operational optimization using Python.
