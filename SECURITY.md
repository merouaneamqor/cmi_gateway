# Security policy

## Supported versions

| Version | Supported          |
| ------- | ------------------ |
| 0.x     | Latest release only |

As the gem matures, this table will be updated.

## Reporting a vulnerability

**Please do not open a public GitHub issue for security reports.**

Instead, email: **marouaneamqor@gmail.com**

Include:

- A short description of the issue and its impact
- Steps to reproduce (if possible)
- Affected versions or commits (if known)

You should receive an acknowledgment within a few business days. Maintainers will coordinate a fix and disclosure timeline with you.

## Scope

This policy covers the **cmi_gateway** Ruby gem (this repository). It does **not** cover applications that depend on the gem, CMI’s own infrastructure, or merchant server configuration — those are the responsibility of their respective operators.

## Safe usage reminders

- Never commit **store keys** or **client secrets** to version control.
- Treat CMI callback payloads according to your acquirer’s guidance; this gem parses fields and exposes helpers but does not replace PCI or operational security practices on your servers.
