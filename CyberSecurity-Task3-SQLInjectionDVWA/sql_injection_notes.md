# SQL Injection Notes — DVWA (Low Security)

This file logs every payload I tried against the DVWA SQL Injection module, including the failed attempts, with my analysis of why each one worked or failed.

## Environment
- Target: DVWA SQL Injection module, Low security
- Field tested: User ID

## Payload Log

### Payload 1: `' OR '1'='1`
**Result:** Success. Returned every row in the users table instead of one.

**Why it worked:** The leading `'` closed the quote the application placed around my input, ending the intended value early. Everything after that point was read as SQL code rather than data. `OR '1'='1'` is a condition that is always true, and since the database checks it against every row independently, the whole WHERE clause evaluates to true for every row, so all of them are returned.

**Data exposed:** first_name and last_name of every user in the table.

---

### Payload 2: `' OR '1'==1`
**Result:** Failed. SQL syntax error.

**Why it failed:** SQL uses a single `=` for comparisons, not `==`. The double equals sign is not valid SQL syntax, so the database could not parse the query and returned a syntax error rather than evaluating anything.

---

### Payload 3: `1' OR '1'=1`
**Result:** Failed. SQL syntax error.

**Why it failed:** The leading `1` shifted the position of every quote that followed it, so the quotes no longer paired up cleanly with the database's own opening and closing quotes. This left one quote unmatched, making the query invalid, even though the underlying logic (an OR with an always-true condition) was correct.

---

### Payload 4: `' UNION SELECT user, password FROM users --`
**Result:** Failed. HTTP 500 Internal Server Error.

**Why it failed:** MySQL requires its comment marker (`--`) to be followed by a space or another character to be read as a valid comment. The trailing space I typed was likely stripped when the input travelled through the browser/URL, leaving MySQL with an incomplete comment marker and an invalid query.

---

### Payload 5: `' UNION SELECT user, password FROM users ---`
**Result:** Failed.

**Why it failed:** Even though three dashes contain a valid two-dash comment marker plus an extra character, this did not behave the same as `-- ` followed by a visible character. This suggests trailing punctuation with no space before it is handled differently than a space followed by a character when the input passes through the form.

---

### Payload 6: `' UNION SELECT user, password FROM users #`
**Result:** Success. Returned usernames and password hashes for every user.

**Why it worked:** The leading `'` closed the original input early, same as Payload 1. `UNION SELECT` ran a second, independent query against the same `users` table, this time selecting the `user` and `password` columns instead of `first_name` and `last_name`. Both queries returned 2 columns, satisfying MySQL's requirement that every part of a UNION return the same column count. The `#` comment marker, unlike `--`, needs nothing after it to be valid, so it reliably commented out the application's trailing quote and semicolon without being affected by trailing-space trimming.

**Data exposed:**

| Displayed as "First name" (actually: username) | Displayed as "Surname" (actually: password hash) |
|---|---|
| admin | 5f4dcc3b5aa765d61d8327deb882cf99 |
| gordonb | e99a18c428cb38d5f260853678922e03 |
| 1337 | 8d3533d75ae2c3966d7e0d4fcc69216b |
| pablo | 0d107d09f5bbe40cade3de5c71e9e9b7 |
| smithy | 5f4dcc3b5aa765d61d8327deb882cf99 |

**Observation:** The page's column labels ("First name", "Surname") are fixed text from the application's design and do not change based on what the query actually returns. The application displays whatever data comes back in each column position without checking that it matches what the label claims. This let usernames and password hashes appear under name labels.

**Observation:** `admin` and `smithy` have the identical hash, which reveals they use the same password, without needing to decode the hash itself.

**Note on the hashes:** These are MD5 hashes, not plain-text passwords. DVWA stores passwords hashed even on Low security. A hash on its own does not reveal the password, but it can be checked against known hash lists or cracked separately, so exposing it is still a serious finding.

## Analysis Summary

| Payload | Technique | Result |
|---|---|---|
| `' OR '1'='1` | Always-true condition | Bypassed filtering, dumped all rows |
| `' OR '1'==1` | (typo test) | Syntax error, not a working injection |
| `1' OR '1'=1` | Misplaced quote | Syntax error, quotes did not pair |
| `' UNION SELECT user, password FROM users --` | Comment attempt | Server error, incomplete comment marker |
| `' UNION SELECT user, password FROM users ---` | Comment attempt | Failed, likely same root cause |
| `' UNION SELECT user, password FROM users #` | UNION-based extraction | Success, exposed usernames and password hashes |

Two working payloads were confirmed:
1. `' OR '1'='1` — bypasses the WHERE clause filter entirely
2. `' UNION SELECT user, password FROM users #` — pulls different, more sensitive data from the same table

The failed attempts are kept here because they show genuine testing and demonstrate why SQL injection depends on exact syntax, not just the right idea.
