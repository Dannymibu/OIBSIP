# Task 3: SQL Injection on DVWA (Low Security)

## Objective
To demonstrate a classic SQL Injection vulnerability by exploiting the login form of DVWA on its Low security setting, and to document the attack with an explanation of how it works and how to prevent it.

## Environment
- Kali Linux running in a VirtualBox virtual machine
- DVWA running on Apache and MariaDB (equivalent to a LAMP stack), already installed on my machine from an earlier task
- Target: DVWA SQL Injection module, Low security

## Authorization
This task was performed only on DVWA running locally on my own machine. I did not attempt SQL injection on any real website or service.

## Steps Performed

1. I started Apache2 and MariaDB:
   ```
   sudo systemctl start apache2 mariadb
   ```
2. I opened DVWA through the browser.
3. I changed the DVWA security level to Low.
4. I went to the SQL Injection module and entered the payload `' OR '1'='1` to trick the query into retrieving all its users, with both their first names and surnames.
5. I inserted another payload, `' UNION SELECT user, password FROM users #`, which retrieved the usernames and passwords from the database.

## What is SQL Injection?
In simpler terms, SQL Injection is an attack on the database which involves attaching a command to a query, which tricks the database into retrieving data it is not intended to retrieve.

## Payload 1: `' OR '1'='1`

**Field:** User ID

**Result:** The query returned every user in the table instead of just one.

**Why it worked:** The leading `'` closed the quote the application placed
