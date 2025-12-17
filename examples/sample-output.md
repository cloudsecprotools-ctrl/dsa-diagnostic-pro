```text
==============================================================
   Trend Micro DSA Diagnostic Lite v1.0
   CloudSecProTools (https://github.com/CloudSecProTools)
==============================================================

[INFO] Starting Lite diagnostic…
[INFO] Output directory: /tmp/dsa-diagnostic-lite-20251212-153422

[INFO] Collecting system information…
    - uname, os-release, lsb_release, hostnamectl

[INFO] Checking Trend Micro binaries…
    - dsa_control found at /opt/ds_agent/dsa_control
    - ds_agent located at /opt/ds_agent/ds_agent

[INFO] Checking DSA-related services…
    - ds_agent.service: active (running)
    - deep-security-agent: active (running)

[INFO] Collecting process information…
    - Found ds_agent (PID 1043)
    - Found dsa_monitor (PID 1087)

[INFO] Checking network ports…
    - Scanning for Trend Micro agent port (4118)
    - Port 4118 is OPEN

[INFO] Collecting Trend-related logs…
    - Found 14 log files in /var/log matching trend/deep/dsa
    - Logs copied to /tmp/dsa-diagnostic-lite-20251212-153422/logs/

[INFO] Saving general system diagnostics…
    - ps aux
    - df -h
    - journalctl (last 500 lines)

[INFO] Creating compressed archive…
    - dsa-diagnostic-lite-20251212-153422.tar.gz (8.3 MB)

[SUCCESS] Diagnostic Lite completed successfully!
Review folder and archive before sharing.

Upgrade to DSA Diagnostic PRO for:
  - Full ODS tests
  - DSM connectivity tests
  - Policy/config analysis
  - Advanced logs
  - Color logging & performance metrics
==============================================================
```
