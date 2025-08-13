#!/bin/bash
#
# FILE: generate-spacewalk-reports-4.3.bash
#
# USAGE:
#   1. On the SUSE Manager 4.3 host:
#        - Create this script using your preferred editor:
#            vim /opt/generate-spacewalk-reports-4.3.bash
#          or download it from GitHub:
#            https://github.com/mariosergiosl/smlm5/blob/main/generate-spacewalk-reports-4.3.bash
#        - Make it executable:
#            chmod +x /opt/generate-spacewalk-reports-4.3.bash
#
#   2. Run the script:
#        /opt/generate-spacewalk-reports-4.3.bash
#      → Generates all available Spacewalk reports
#      → Stores them as CSV files in a timestamped folder under /opt
#      → Compresses the folder into a .tar.gz archive
#      → Deletes the original folder to save space
#      → Prints the location of the archive
#
# DESCRIPTION:
#   This script automates the generation and packaging of Spacewalk reports
#   on SUSE Manager 4.3. It creates a timestamped directory,
#   saves each report as a CSV file, compresses the directory into a .tar.gz archive,
#   and removes the original folder to conserve disk space.
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
  spacewalk-report "$report_name" >> "${report_dir}/${report_name}.csv" 2>/dev/null
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
echo "Reports generated and archived at: $archive_path"