# GitHub Commits ETL Pipeline

## 📚 Project Overview

This project builds a **simple ETL (Extract, Transform, Load) pipeline** that fetches commit data from a GitHub repository and stores it into a **MySQL** database.  
The ETL is automated using **Bash scripts**, with a focus on **incremental data loading**, **error handling**, and **basic logging**.

---

## 🏗️ Project Structure

| File/Folder | Purpose |
|:---|:---|
| `fetch_commits.sh` | Main Bash script to fetch and insert commits |
| `.env` | Stores database credentials securely |
| `commits.json` | Temporary storage for fetched commit data |
| `pipeline.log` | Logs ETL job status and errors |

---

## 🚀 Features

- Fetch commits from GitHub repository using GitHub API
- Only fetch new commits (incremental load using `since` parameter)
- Insert data into MySQL database
- Basic error handling for API and database
- Environment variables for security
- Basic logging to monitor script execution

---

## ⚙️ Technologies Used

- **Bash** (scripting)
- **cURL** (API requests)
- **jq** (JSON parsing)
- **MySQL** (database)
- **cron** (optional for automation)

---

## 📦 How to Run

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/github-commits-etl.git
   cd github-commits-etl
