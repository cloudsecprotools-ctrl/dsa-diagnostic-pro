#!/usr/bin/env bash
# dsa_diagnostic_lite.sh
# Usage: sudo ./dsa_diagnostic_lite.sh [--output /tmp/out] [--max-zip-mb 90] [--help]
#
# |============================================================|
# | Lightweight Trend Micro DSA diagnostic (Lite)  - Linux     |
# | Author: CloudSecProTools                                   |
# | Email: cloudsecprotools@gmail.com                          |
# | Version: 1.0.0                                             |
# |============================================================|
#
####################################################################################################
#                                     Render-String (Open-Source Components Only)                  #
#                                         Copyright (C) 2025 CloudSecProTools                      #
####################################################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software    #
# and associated documentation files (the “Software”), to deal in the Software without restriction,#
# including without limitation the rights to use, copy, modify, merge, publish, distribute,        #
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is    #
# furnished to do so, subject to the following conditions:                                         #
#                                                                                                  #
# The above copyright notice and this permission notice shall be included in all copies or         #
# substantial portions of the Software.                                                            #
#                                                                                                  #
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING    #
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND       #
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,     #
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.          #
####################################################################################################

####################################################################################################
#                                       Commercial / Full Version Notice                           #
# The complete version of Render-String, including advanced features and full functionality, is    #
# proprietary and not included in this MIT-licensed release.                                       #
#                                                                                                  #
# - The full version is not publicly shared or redistributable.                                    #
# - Access to the full version requires a paid commercial license.                                 #
# - No warranty, guarantee, or support is provided for either the commercial or open-source        #
#   portions unless explicitly stated in a written contract.                                       #
#                                                                                                  #
# Use of the full version without a valid commercial license is strictly prohibited.               #
####################################################################################################
#
set -u
SCRIPT_NAME="$(basename "$0")"
DEFAULT_OUT="/tmp/dsa-diagnostic-lite-$(date +%Y%m%d-%H%M%S)"
OUTPUT_DIR="$DEFAULT_OUT"
MAX_ZIP_MB=200    # default: large enough for lite
QUIET=0

usage() {
  cat <<EOF
${SCRIPT_NAME} - Lite Trend Micro DSA diagnostic (read-only)

Usage:
  sudo ${SCRIPT_NAME} [--output <dir>] [--max-zip-mb <MB>] [--quiet] [--help]

Options:
  --output <dir>      Directory where diagnostic output is saved (default: ${DEFAULT_OUT})
  --max-zip-mb <MB>   Maximum zip size in MB (lite default: ${MAX_ZIP_MB})
  --quiet             Suppress non-error output
  --help, -h          Show this help
EOF
}

log() {
  if [ "$QUIET" -ne 1 ]; then
    echo -e "$@"
  fi
}

err() {
  echo "ERROR: $@" >&2
}

# simple arg parsing
while [ $# -gt 0 ]; do
  case "$1" in
    --output) shift; OUTPUT_DIR="$1"; shift;;
    --max-zip-mb) shift; MAX_ZIP_MB="$1"; shift;;
    --quiet) QUIET=1; shift;;
    -h|--help) usage; exit 0;;
    *) err "Unknown arg: $1"; usage; exit 2;;
  esac
done

# require root for some commands
if [ "$(id -u)" -ne 0 ]; then
  err "It is recommended to run as root (sudo) to collect all info. Continuing, but some checks may be limited."
fi

mkdir -p "$OUTPUT_DIR" || { err "Cannot create output dir $OUTPUT_DIR"; exit 3; }
log "Diagnostic output will be saved to: $OUTPUT_DIR"

# Basic system info
log "Collecting system information..."
uname -a > "${OUTPUT_DIR}/uname.txt" 2>&1
if command -v lsb_release >/dev/null 2>&1; then
  lsb_release -a > "${OUTPUT_DIR}/lsb_release.txt" 2>&1
fi
cat /etc/os-release > "${OUTPUT_DIR}/os-release.txt" 2>/dev/null || true
hostnamectl > "${OUTPUT_DIR}/hostnamectl.txt" 2>/dev/null || true

# Check for common Trend Micro binaries and control utilities
log "Checking for Trend Micro binaries..."
which dsa_control >/dev/null 2>&1 && echo "dsa_control: $(which dsa_control)" > "${OUTPUT_DIR}/dsa_control_path.txt" || echo "dsa_control: not found" > "${OUTPUT_DIR}/dsa_control_path.txt"
which ds_agent >/dev/null 2>&1 && echo "ds_agent: $(which ds_agent)" >> "${OUTPUT_DIR}/dsa_control_path.txt" || true

# Service checks - try a few common service names
log "Checking DSA-related services (common names)..."
SERVICE_CANDIDATES=("ds_agent" "dsa" "dsa_agent" "deep-security-agent" "TrendMicro" "trendmicro")
for s in "${SERVICE_CANDIDATES[@]}"; do
  if systemctl list-units --type=service --all --no-pager | grep -i "$s" >/dev/null 2>&1; then
    systemctl status "$s" --no-pager > "${OUTPUT_DIR}/service_${s}_status.txt" 2>&1 || true
  else
    # also try "service" command
    service "$s" status > "${OUTPUT_DIR}/service_${s}_status.txt" 2>&1 || true
  fi
done

# Generic service search summary
systemctl list-units --type=service --no-pager | grep -i "deep\|trend\|dsa\|ds_agent" > "${OUTPUT_DIR}/service_search.txt" 2>&1 || true

# Process check (ps)
log "Collecting process list and ps aux | grep for trend/dsa..."
ps aux > "${OUTPUT_DIR}/ps_aux.txt"
ps aux | egrep -i "trend|deep|dsa|ds_agent" > "${OUTPUT_DIR}/ps_trend_matches.txt" 2>/dev/null || true

# Network checks (listening ports and port 4118)
log "Collecting network/socket information..."
if command -v ss >/dev/null 2>&1; then
  ss -tulpen > "${OUTPUT_DIR}/ss_listening.txt" 2>&1 || true
else
  netstat -tulpen > "${OUTPUT_DIR}/netstat_listening.txt" 2>&1 || true
fi
# test local connection to port 4118 (Trend Micro default agent port)
if command -v nc >/dev/null 2>&1; then
  nc -vz 127.0.0.1 4118 > "${OUTPUT_DIR}/port4118_check.txt" 2>&1 || true
elif command -v curl >/dev/null 2>&1; then
  (echo > /dev/tcp/127.0.0.1/4118) >/dev/null 2>&1 && echo "port 4118 open" > "${OUTPUT_DIR}/port4118_check.txt" || echo "port 4118 closed" > "${OUTPUT_DIR}/port4118_check.txt"
else
  echo "no nc/curl to test port 4118" > "${OUTPUT_DIR}/port4118_check.txt"
fi

# Basic log collection - search for Trend-related logs under common log dirs
log "Collecting Trend-related log files (basic patterns) - please review for PII before uploading."
LOG_PATTERNS=("trend" "deep" "dsa" "ds_agent" "deep-security")
for p in "${LOG_PATTERNS[@]}"; do
  find /var/log -type f -iname "*${p}*" -maxdepth 3 -exec cp --parents '{}' "${OUTPUT_DIR}/logs/" \; 2>/dev/null || true
done

# If diag utility exists, ask user to optionally run it (we will not run by default)
if command -v dsa_control >/dev/null 2>&1; then
  echo "NOTE: 'dsa_control' found. You may want to run 'dsa_control -d' manually to generate agent diag files if necessary." > "${OUTPUT_DIR}/dsa_control_note.txt"
fi

# Collect journalctl (last 500 lines) for services that match
log "Collecting journalctl logs (last 500 lines) for matching units..."
journalctl -n 500 | egrep -i "trend|deep|dsa|ds_agent" > "${OUTPUT_DIR}/journal_trend_matches.txt" 2>/dev/null || true

# Save disk usage summary
log "Saving disk and filesystem usage..."
df -h > "${OUTPUT_DIR}/df_h.txt"
du -sh /var/log 2>/dev/null > "${OUTPUT_DIR}/du_var_log.txt" || true

# Package the output
log "Creating compressed archive..."
ARCHIVE="${OUTPUT_DIR}.tar.gz"
tar -czf "${ARCHIVE}" -C "$(dirname "$OUTPUT_DIR")" "$(basename "$OUTPUT_DIR")" || { err "Failed to create archive"; exit 5; }

# Ensure size limit (basic)
ZIP_SIZE_MB=$(du -m "${ARCHIVE}" | cut -f1)
if [ "${ZIP_SIZE_MB}" -gt "${MAX_ZIP_MB}" ]; then
  log "Archive size ${ZIP_SIZE_MB}MB exceeds limit ${MAX_ZIP_MB}MB. Archive still created at ${ARCHIVE}."
else
  log "Archive created: ${ARCHIVE} (${ZIP_SIZE_MB} MB)"
fi

log "Lite diagnostic completed. Review files in ${OUTPUT_DIR} and the archive ${ARCHIVE}."
log "If you need full diagnostics (ODS tests, manager integration, extended logs), consider upgrading to the Pro version."

exit 0
