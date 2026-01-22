---
name: mail-debug
description: Use when diagnosing mail delivery issues, tracing email paths, or analyzing mail server routing. Requires mailtrace MCP server.
---

# Mail Flow Debugging Skill

## When to Use

- User asks about mail delivery issues
- Need to trace an email's path through relay servers
- Verifying mail routing matches expected architecture
- Diagnosing why mail was delayed, rejected, or misrouted

## Prerequisites

- **mailtrace MCP server** must be configured and running
- Access to mail server logs (via SSH or OpenSearch)
- Knowledge of expected mail architecture

## Diagnosis Workflow

### Step 1: Identify the Email

Gather from user:
- **Sender address** (e.g., `user@domain.com`)
- **Recipient address**
- **Approximate time** sent
- **Direction**: inbound (external→internal), outbound (internal→external), or internal

### Step 2: Query Logs

```
mailtrace_query_logs(
  host="<cluster-name>",      # e.g., "smtp-cluster", "mx-cluster"
  keywords=["<keyword>"],
  time="YYYY-MM-DD HH:MM:SS",
  time_range="<duration>"     # e.g., "4h", "12h", "1d"
)
```

**Valid keywords** (searches mail log message content):

| Keyword Type | Example | Notes |
|--------------|---------|-------|
| Sender email | `csjhuang@google.com` | Full from address |
| Recipient email | `user@test.cc.cs.nctu.edu.tw` | Full to address |
| Sender domain | `google.com` | Matches all mail from domain |
| Recipient domain | `gmail.com` | Matches all mail to domain |
| Username | `csjhuang` | Partial match in addresses |
| Queue ID | `E217D11F770` | Specific mail queue ID |
| SASL username | `csjhuang` | Authenticated user |

**Keywords search the log message field**, which contains data like:
- `from=<sender@domain>`
- `to=<recipient@domain>`
- `sasl_username=<user>`
- `relay=<server>[ip]:port`
- `status=sent/deferred/bounced`

**Cluster selection:**
- **Outbound/Internal mail**: Start with `smtp-cluster` (csmail servers)
- **Inbound mail**: Start with `mx-cluster` (MX servers)

### Step 3: Trace Mail Flow

```
mailtrace_trace_mail(
  host="<cluster-name>",
  mail_id="<queue-id-from-step-2>",
  time="YYYY-MM-DD HH:MM:SS",
  time_range="<duration>"
)
```

**Output includes:**
- `nodes`: List of servers in path
- `edges`: Hops with `{from, to, mail_id}`
- `hop_count`: Number of relay hops
- `graph_dot`: Graphviz visualization

### Step 4: Analyze Path

**Check 1: Delivery Success**
- Final SMTP code must be 250
- Mail must reach terminal destination
- No bounce/deferral on final hop

**Check 2: Path Matches Architecture**

| Mail Type | Expected Path Pattern |
|-----------|----------------------|
| Inbound | MX servers → maildirect → mailbox |
| Outbound | csmail → mailer-cluster → external |
| Internal | csmail → mailer-cluster → maillist/mailbox |

**Red Flags:**
- Unexpected servers in path
- Excessive hops (>5-7)
- Loops (same server appears twice)
- Non-250 SMTP codes
- Missing expected hops

### Step 5: Cross-Reference Config (if needed)

Check Postfix configs for routing rules:
- `main.cf`: `relayhost`, `transport_maps`
- `transport`: Domain-specific routing
- `transport.pcre`: Regex-based routing

## Example Analysis Output

```
Path: smtp-cluster → mailer4 → 10.2.9.6

| Check | Result | Notes |
|-------|--------|-------|
| Entry point | ✅ | SASL authenticated via csmail |
| Relay | ✅ | mailer4 (part of mailer-cluster) |
| Final dest | ✅ | mxlog test sink (expected) |
| SMTP codes | ✅ | All 250 |
| Hop count | ✅ | 2 hops (reasonable) |

Verdict: Path is CORRECT
```

## Common Issues & Solutions

| Symptom | Likely Cause | Investigation |
|---------|--------------|---------------|
| No logs found | Wrong cluster or time range | Try wider time range, different cluster |
| No logs found | Wrong timezone | OpenSearch uses UTC - convert local time (e.g., +08:00 Taiwan → subtract 8 hours) |
| No logs found | Logs not shipped | Check if server's logs are being sent to OpenSearch |
| Path stops mid-way | Delivery failure | Check SMTP code on last hop |
| Unexpected server | Routing misconfiguration | Check transport maps |
| Loop detected | Forwarding cycle | Check .forward files, alias loops |
| Excessive hops | Complex routing | May be normal, verify each hop |
| 454 Relay access denied | Source IP not trusted | Add source IP to destination's `mynetworks` |

## Multi-Hop Tracing

When `mailtrace_trace_mail` only shows partial path:

1. Note the `queued_as` ID from the last successful hop
2. Query the downstream server directly:
   ```
   mailtrace_query_logs(
     host="<downstream-server>",  # Can use hostname directly, not just clusters
     keywords=["<queued_as_id>"],
     time="...", time_range="..."
   )
   ```
3. Repeat until you find the terminal state (delivered, bounced, or deferred)

**Available hosts:** Can query clusters (`mx-cluster`, `smtp-cluster`) OR individual hostnames (`maillist1`, `mailer4`, etc.)

## Error Code Reference

| SMTP Code | Status | Meaning |
|-----------|--------|---------|
| 250 | ✅ sent | Successfully delivered/relayed |
| 454 | ❌ deferred | Relay access denied - source not trusted |
| 550 | ❌ bounced | User unknown or rejected |
| 421 | ❌ deferred | Service unavailable, try again |

## Sending Test Emails

Use the send-mail skill to send test emails and trace them:

```bash
/home/efficacy38/.claude/skills/send-mail/scripts/send-mail \
    --config config.yaml \
    --ssl-mode starttls \
    --no-ssl-verify \
    --rate 1 \
    --duration 1 \
    --mail-subject "Test $(date +%Y-%m-%d_%H:%M:%S)" \
    --export-records /tmp/sent_emails.json
```

**Key flags:**
| Flag | Purpose |
|------|---------|
| `--ssl-mode starttls` | Use STARTTLS (port 25/587) |
| `--ssl-mode smtps` | Use SSL/TLS (port 465) |
| `--no-ssl-verify` | Skip certificate verification (for self-signed certs) |
| `--no-auth` | Disable SMTP authentication |
| `--export-records` | Save message-id and queue-id for tracing |

**Exported records format:**
```json
{
  "queue_id": "9BB2811F77F",
  "message_id": "<uuid@traffic-generator.local>",
  "success": true,
  "status_code": 250
}
```

Use `queue_id` directly with `mailtrace_trace_mail`.

## Test Environment Notes

- **mxlog (10.2.9.6)**: Test sink that captures all external mail
- **mailer-cluster**: Load-balanced mailer servers (mailer1-4, 10.2.9.17)
- **maillist-cluster**: Handles CS domain mail routing
- **maillist1 (10.2.9.74)**: Mailing list server, routes to mailer-cluster
- **csmwproxy1**: SMTP proxy - **NOT indexed in OpenSearch** (mail submitted here won't appear in mailtrace queries)

## Discovering Available Clusters

Query the mailtrace MCP resource to get current cluster configuration:

```
ReadMcpResourceTool(server="mailtrace", uri="mailtrace://clusters")
```

Returns JSON mapping cluster names to member hosts:
```json
{
  "mx-cluster": ["csmx1.test.cc.cs.nctu.edu.tw", "csmx2.test.cc.cs.nctu.edu.tw"],
  "smtp-cluster": ["csmail1.test.cc.cs.nctu.edu.tw", "csmail2.test.cc.cs.nctu.edu.tw"],
  "mailer-cluster": ["mailer4.test.cc.cs.nctu.edu.tw"],
  "maillist-cluster": ["maillist1.test.cc.cs.nctu.edu.tw", "maillist2.test.cc.cs.nctu.edu.tw"]
}
```

**Always query this first** to get the current list of available hosts and clusters before tracing.

## Servers Tracked in OpenSearch

Only these clusters are indexed and searchable via mailtrace:

| Cluster | Servers | Use Case |
|---------|---------|----------|
| `mx-cluster` | csmx1, csmx2 | Incoming mail |
| `smtp-cluster` | csmail1, csmail2 | Outgoing relay |
| `mailer-cluster` | mailer4 | Application mail |
| `maillist-cluster` | maillist1, maillist2 | Mailing lists |

**Note:** `csmwproxy1` is NOT tracked. Mail submitted directly to this server won't appear in log queries.

## Inbound Mail Path (Test Environment)

```
Internet → csmx1/2 (MX) → maillist1 → mailer4 → maildirect → mailbox
```

**Key routing:**
- MX servers route CS domains to `maillist1`
- maillist1 routes to `mailer-cluster` for delivery
- mailer4 must trust maillist1 (10.2.9.74) in `mynetworks`

## Common SSL/TLS Errors

| Error | Solution |
|-------|----------|
| `SSL: CERTIFICATE_VERIFY_FAILED` (self-signed) | Add `--no-ssl-verify` |
| `SSL: WRONG_VERSION_NUMBER` | Port/mode mismatch - use `starttls` for 25/587, `smtps` for 465 |
| `530 5.7.0 Must issue STARTTLS` | Use `--ssl-mode starttls` |

## Pitfalls & Gotchas

### Queue ID Changes Between Servers

The `queue_id` from your sending tool is only valid on the **first hop**. When mail is relayed, each server assigns a **new queue ID**. To trace the full path:

1. Start with original queue_id on entry server
2. Look for `queued_as=<new_id>` in relay logs
3. Use the new ID to query the next hop

### Log Availability Timing

Logs may take **15-30 seconds** to appear in OpenSearch after mail is sent. If queries return no results immediately after sending:
- Wait 15+ seconds before querying
- Use a wider `time_range` (e.g., `30m` instead of `10m`)

### Test Case 3 Pattern: External Sender Issues

When testing inbound mail with external sender addresses (e.g., `@google.com`):

**Issue:** Mail accepted by MX but deferred at downstream relays with `454 4.7.1 Relay access denied`

**Root cause:** Downstream servers (e.g., mailer4) have `smtpd_recipient_restrictions` that only permit relay for:
- Authenticated users (SASL)
- Trusted networks (`mynetworks`)

External sender mail from maillist1 fails because:
1. No SASL auth on internal relay
2. maillist1 may not be in mailer4's `mynetworks`

**Diagnosis:** Check the mail flow for `dsn=4.7.1` and "Relay access denied" in log messages.

## Quick Debugging Shortcuts

### 1. Choose Entry Point by Mail Type

| Mail Type | Entry Server | Why |
|-----------|--------------|-----|
| Outbound (internal→external) | `smtp-cluster` | Mail enters via csmail servers |
| Inbound (external→internal) | `mx-cluster` | Mail enters via MX servers |
| Internal (internal→internal) | `smtp-cluster` | Authenticated users submit via csmail |
| Via proxy (csmwproxy1) | `smtp-cluster` | Proxy forwards to smtp-cluster (proxy not indexed) |

### 2. Time Handling

The MCP server uses **local time (UTC+8)**. Use local time directly:
```
# If sent at 21:58 local time, query with:
time="2026-01-27 21:58:00"
```

### 3. Efficient Query Strategy

**DO:**
- Query by **keyword first** (sender/recipient domain) to find mail IDs
- Then use `mailtrace_trace_mail` with specific mail_id
- Use broader keywords (domain) before narrow ones (full email)

**DON'T:**
- Don't query with the original queue_id on downstream servers (it changes per hop)
- Don't make multiple speculative queries - check entry point first
- Don't query untracked servers (csmwproxy1)

### 4. Tracing Failed Mail

**Bounced mail (5xx):**
- Look for `status=bounced` in logs
- Check `dsn=5.x.x` code for reason
- Bounced mail won't have downstream hops - trace stops at rejection point

**Deferred mail (4xx):**
- Look for `status=deferred` in logs
- Mail stays in queue, retries periodically
- Query same server later to see retry attempts

**Rejected at RCPT TO (NOQUEUE):**
- No queue_id assigned - appears as `NOQUEUE` in logs
- Search by sender/recipient keyword, not queue_id
- Look for `reject:` in log messages

### 5. Common Log Patterns

```
# Successful delivery
status=sent (250 2.0.0 Ok: queued as ABC123)

# Relay denied
status=deferred (454 4.7.1 Relay access denied)

# Spam rejected
status=bounced (554 5.7.1 Spam message rejected)

# User unknown
status=bounced (550 5.1.1 User unknown)

# Connection failed
status=deferred (connect to host[ip]:25: Connection refused)
```

### 6. DSN Code Quick Reference

| DSN | Category | Common Causes |
|-----|----------|---------------|
| 2.0.0 | Success | Delivered |
| 4.4.1 | Temp failure | DNS/connection issue |
| 4.7.1 | Temp policy | Relay denied (mynetworks) |
| 5.1.1 | Perm address | User unknown |
| 5.1.2 | Perm address | Bad domain |
| 5.7.1 | Perm policy | Relay denied, spam rejected |

### 7. Debugging Checklist

```
□ Identify mail direction (inbound/outbound/internal)
□ Select correct entry cluster
□ Use local time (UTC+8) for queries
□ Wait 15+ seconds after sending before querying
□ Query by keyword first, then trace by mail_id
□ Check for NOQUEUE if mail never accepted
□ Look at dsn= and status= fields for diagnosis
□ Verify mynetworks if seeing relay denied
```

## Observed Mail Flow Patterns (Test Environment)

### Internal → Internal (via smtp-cluster)
```
csmail1/2 → mailer4 → [may be spam rejected]
```
**Issue observed:** Rspamd on mailer4 may reject test traffic as spam (`554 5.7.1 Spam message rejected`).

### Internal → External (via smtp-cluster)
```
csmail1/2 → mailer4 → 10.2.9.6 (mxlog test sink)
```
All external domains route to mxlog in test environment.

### External → Internal (via mx-cluster)
```
csmx1/2 → maillist1 → mailer4 → maillist1 → maildirect1 → LMTP (Dovecot)
```
**Issue observed:** LMTP may return `451 4.2.0 Internal error` due to Dovecot configuration.

## Additional Rejection Patterns

### Sender Domain Verification (450 4.1.8)
```
NOQUEUE: reject: RCPT from unknown[ip]: 450 4.1.8 <sender@invalid.domain>:
Sender address rejected: Domain not found
```
MX servers verify sender domain has valid DNS. Fake domains like `external.example.com` will be rejected before recipient check.

### Spam Rejection (554 5.7.1)
```
status=bounced (host mailer4... said: 554 5.7.1 Spam message rejected
(in reply to end of DATA command))
```
Rspamd rejected the message. Check Rspamd logs for specific rule that triggered.

### Sender Not Permitted (554 5.7.1)
```
NOQUEUE: reject: RCPT from unknown[ip]: 554 5.7.1 <spammer@evil.domain>:
Sender address rejected: Sender not permitted
```
Unauthenticated relay attempt with untrusted sender/destination combination.

## Manual Multi-Hop Tracing

When automatic tracing fails, manually follow `queued_as` chain:

```bash
# Step 1: Query initial queue ID
curl -sk -u 'user:pass' 'https://oslb.../logs-vector*-mail/_search?q=INITIAL_QUEUE_ID&size=10' | jq ...

# Step 2: Find queued_as in relay log
# Look for: status=sent (250 2.0.0 Ok: queued as NEW_QUEUE_ID)

# Step 3: Query next hop with new queue ID
curl -sk -u 'user:pass' 'https://oslb.../logs-vector*-mail/_search?q=NEW_QUEUE_ID&size=10' | jq ...

# Repeat until terminal state (delivered/bounced/deferred)
```

**Example trace chain:**
```
C80051E0059 (csmx1)
  → queued as 0E5C7360063 (maillist1)
    → queued as 3972FDF2BD (mailer4)
      → queued as 48C58360063 (maillist1)
        → queued as 5BA53DFA09 (maildirect1)
          → LMTP delivery (final)
```
