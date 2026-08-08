# Lesson 01 — Oracle Database Overview

> Understand what Oracle Database is and how it is used throughout this course.

---

# Overview

Welcome to your first lesson in **SQL-Engineering-Lab**.

Before learning SQL, it is important to understand the environment where SQL is executed.

Throughout this repository, every SQL statement will run on **Oracle Database Free**.

In this lesson, you will learn the basic concepts of Oracle Database and become familiar with the terminology that will appear throughout the remaining courses.

This lesson does **not** require any SQL knowledge.

---

# Learning Objectives

After completing this lesson, you will be able to:

- Explain what a relational database is
- Describe the purpose of Oracle Database
- Understand the difference between a database and a database management system (DBMS)
- Understand the Oracle Database architecture at a high level
- Explain the role of FREEPDB1
- Recognize the basic Oracle terminology used throughout this repository

---

# What is a Database?

A database is a collection of organized data.

Instead of storing information in spreadsheets or text files, databases store data in structured tables that can be searched, updated, and managed efficiently.

Examples include:

- Customer information
- Product catalogs
- Sales records
- Employee data
- Library systems

Almost every modern application stores its data in a database.

---

# What is Oracle Database?

Oracle Database is a Relational Database Management System (RDBMS) developed by Oracle Corporation.

It is designed to securely store, manage, and retrieve large amounts of structured data.

Oracle Database is widely used in:

- Enterprise systems
- Financial institutions
- Government organizations
- Manufacturing
- Healthcare
- Cloud services

For this course, we use **Oracle Database Free**, which provides the core Oracle Database features in a free edition suitable for learning and development.

---

# Oracle Database Architecture

For this repository, you only need to understand the following high-level structure.

```
Oracle Database Free

        │

        ▼

Container Database (CDB)

        │

        ▼

Pluggable Database (FREEPDB1)

        │

        ▼

Users

        │

        ▼

Schemas

        │

        ▼

Tables
```

Do not worry if some of these terms are unfamiliar.

Each concept will be explained in later lessons.

---

# Key Terms

| Term | Description |
|------|-------------|
| Database | Stores structured data |
| DBMS | Software that manages databases |
| Oracle Database | Oracle's relational database system |
| CDB | Container Database |
| PDB | Pluggable Database |
| FREEPDB1 | The pluggable database used in this course |
| User | Oracle login account |
| Schema | Collection of objects owned by a user |
| Table | Stores rows and columns of data |

---

# Why Oracle Database?

There are many relational databases available today, including:

- Oracle Database
- PostgreSQL
- SQL Server
- MySQL

Although SQL is largely standardized, each database system provides its own features and administration tools.

This repository focuses on Oracle Database Free because it offers a powerful environment for learning both SQL and database engineering concepts.

---

# What You Need to Remember

At this stage, remember only these points:

- Oracle Database stores data.
- SQL is the language used to communicate with the database.
- FREEPDB1 is the database used throughout this repository.
- Users own schemas.
- Schemas contain database objects such as tables.

Everything else will be learned gradually.

---

# Summary

In this lesson, you learned:

- What a database is
- What Oracle Database is
- What Oracle Database Free is
- The basic Oracle architecture
- The meaning of CDB and PDB
- The role of FREEPDB1

You are now ready to connect to Oracle Database.

---

# Exercises

Answer the following questions.

1. What is the purpose of a relational database?

2. What does DBMS stand for?

3. What is Oracle Database Free?

4. What is the difference between a Container Database and a Pluggable Database?

5. Which pluggable database will be used throughout this repository?

---

# Next Lesson

**Lesson 02 — Connect to FREEPDB1**

In the next lesson, you will connect to Oracle Database Free and verify your working environment.