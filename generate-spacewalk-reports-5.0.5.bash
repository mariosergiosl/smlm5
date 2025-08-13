#!/bin/bash
#
# FILE: generate-spacewalk-reports-5.0.5.sh
#
# USAGE: generate-spacewalk-reports-5.0.5.sh
#
# DESCRIPTION:
#   Generates all available Spacewalk reports, stores them as CSV files
#   in a timestamped directory, compresses the directory, and removes the original.
#
# OPTIONS: None
# REQUIREMENTS: spacewalk-report command must be available
# AUTHOR: Mario Luz, mario.luz[at]suse.com
# VERSION: 1.0
# CREATED: 2025-08-13
# REVISION: --

# === Constants ===
readonly REPORT_BASE_DIR="/opt"  # Base directory for storing reports

# === Generate timestamp for folder and archive name ===
timestamp=$(date -u +%Y-%m-%dT%H-%M-%SZ)  # UTC timestamp in ISO format
report_dir="${REPORT_BASE_DIR}/reports_${timestamp}"  # Full path to report folder
archive_path="${REPORT_BASE_DIR}/reports_${timestamp}.tar.gz"  # Archive file path

# === Create report directory ===
mkdir -p "$report_dir" || {
  echo "Error: Failed to create directory $report_dir"
  exit 1
}

# === Generate reports ===
#
# Each report is saved as a CSV file named after the report
#
for report_name in $(spacewalk-report); do
  spacewalk-report "$report_name" >> "${report_dir}/${report_name}.csv"
done

# === Compress the report directory ===
tar -czf "$archive_path" -C "$REPORT_BASE_DIR" "reports_${timestamp}" || {
  echo "Error: Failed to create archive $archive_path"
  exit 1
}

# === Remove the original report directory ===
rm -rf "$report_dir" || {
  echo "Warning: Failed to remove directory $report_dir"
}

# === Final status message ===
echo "✅ Reports generated and archived at: $archive_path"