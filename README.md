# Fraud Payment Platform

## Overview
This project is an end-to-end fraud detection and fraud prevention platform built using **Azure SQL**.

It simulates realistic payment behavior and supports:
- Real-time fraud prevention dashboards
- Post-event fraud detection analytics

## Architecture
- Azure SQL Database
- Synthetic transaction data
- Fraud rules and alerting logic
- Power BI dashboards (planned)

## Database Schema
The core schema includes:
- Accounts
- Transactions
- Sessions (device & IP context)
- Fraud rules and alerts
- Aggregated behavioral features

Schema definition is available in: sql/schema.sql


## Future Work
- Synthetic data generation
- Risk scoring logic
- Real-time dashboards
- Model-based fraud detection
