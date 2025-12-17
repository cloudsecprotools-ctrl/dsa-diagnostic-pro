# dsa-diagnostic-pro

Advanced Trend Micro Deep Security Agent (DSA) diagnostic & troubleshooting toolkit for Linux and Windows.

This project provides automated health checks, log collection, connectivity tests, performance monitoring, policy analysis, and agent-level diagnostics — designed for SOC teams, security analysts, MSPs, cloud engineers, and IT administrators.

## ⭐ Full Pro Version Available
- The scripts in this repository represent the Lite Edition.
- If you want the full Pro version, which includes all advanced features, faster updates, and enterprise-level automation:

## 👉 Contact me directly:
- cloudsecprotools@gmail.com
- I also offer custom automation, Deep Security tooling, and log-analysis scripting upon request.

## Features
### 🔧 Core Diagnostics
- Collect agent logs (Linux & Windows)
- Check DSA service status
- Verify heartbeat connectivity
- Validate Trend Micro DSM manager integration
- Auto-generate compressed diagnostic packages
- Verify installation details and agent version
- Check malware pattern / DAT updates
- Review custom exclusion lists

### 🚀 Advanced Tests (Pro Only)
- Full On-Demand Scan (ODS) test (manual + scheduled)
- CPU & RAM performance monitoring during scans
- Volume encryption awareness (large volume scan test)
- Deep Security policy evaluation / config review
- Container compatibility test (Docker / Kubernetes)
- Port 4118 localhost communication test
- Agent activation / deactivation validation
- Install-only mode
- Skip GPG validation option
- Max ZIP size control

### 🧩 Optional Functions (Pro)
- Agent uninstall
- Full colorized logging
- Multiple repeatable tags
- Diagnostic wait timers
- Export results to JSON, CSV, or YAML

---

## Installation

### Linux
```bash
sudo chmod +x dsa_diagnostic_pro.sh
sudo ./dsa_diagnostic_pro.sh --help
```

### Windows (Powershell)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\dsa_diagnostic_pro.ps1 -Help
```

## Usage Examples

### Run full diagnostic
```bash
sudo ./dsa_diagnostic_pro.sh --full
```

### Run install only
```bash
sudo ./dsa_diagnostic_pro.sh --install-only
```

### Set max ZIP size (MB)
```bash
sudo ./dsa_diagnostic_pro.sh --max-zip-mb 90
```

### Windows (Powershell)
```powershell
.\dsa_diagnostic_pro.ps1 -Full
```

## Output Directory
### All diagnostic files are saved inside:
```bash
/tmp/dsa-diagnostic-pro/
or
C:\ProgramData\Trend Micro\Deep Security Agent\diag\
```

## Lite vs Pro Feature Comparison
- See the comparison table below for what is included in each edition.

```
| Feature                                      | Lite Version  | Pro Version |
|----------------------------------------------|---------------|-------------|
| Basic agent status check                     | ✅ Yes        | ✅ Yes      |
| Log collection                               | ⚠️ Limited    | ✅ Full     |
| ZIP compression                              | Basic         | Advanced + size limit |
| On-Demand Scan test                          | ❌ No         | ✅ Yes      |
| Scheduled ODS prep                           | ❌ No         | ✅ Yes      |
| CPU & RAM performance monitoring             | ❌ No         | ✅ Yes      |
| Policy configuration review                  | ❌ No         | ✅ Yes      |
| Port 4118 connectivity test                  | ❌ No         | ✅ Yes      |
| Deep Security Manager integration test       | ❌ No         | ✅ Yes      |
| Container security compatibility test        | ❌ No         | ✅ Yes      |
| Volume encryption scan                       | ❌ No         | ✅ Yes      |
| Agent uninstall feature                      | ❌ No         | ✅ Yes      |
| Agent activation/deactivation logic          | ❌ No         | ✅ Yes      |
| Multiple tag support                         | ❌ No         | ✅ Yes      |
| Install-only mode                            | ❌ No         | ✅ Yes      |
| Skip GPG checks                              | ❌ No         | ✅ Yes      |
| Export format (JSON/CSV/YAML)                | ❌ No         | ✅ Yes      |
| Colorized logging                            | ❌ No         | ✅ Yes      |
```
## 📬 Want the Full Pro Version?

- If you want the full scripts (Linux + PowerShell), plus updates and support:
- 📧 Contact me at: <b>cloudsecprotools@gmail.com</b>

### You’ll get:
* Full feature set
* All diagnostic modules
* Priority updates
* Personalized support
* Option for custom automation scripts

## License
- MIT License — see LICENSE file for details.

## Disclaimer
- This software is provided "as-is," and the authors are not responsible for any damage, without warranty of any kind, loss of data, or any other issues that may arise from its use.

## Contributing
### Pull requests and feature suggestions are welcome!
1. Open an issue
2. Fork the repo
3. Create a feature branch
4. Commit with clear messages
5. Submit a PR

## Changelog
- See CHANGELOG.md for version history.

## Repository Structure
```
cloudsecprotools/
│
├── dsa-diagnostic-pro/
│   ├── dsa_diagnostic_lite.sh
│   ├── dsa_diagnostic_lite.ps1
│   ├── README.md
│   ├── LICENSE
│   ├── CHANGELOG.md
│   ├── CONTRIBUTING.md
│   └── examples/
│       └── sample-output.md
│
└── (More tools coming soon...)
```