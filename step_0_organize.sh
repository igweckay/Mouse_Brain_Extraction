#!/usr/bin/env bash
#
# step0_organize.sh
#############################################################################
# Purpose : Organize the data into specific folders
# Usage   : Each file is copied into a different folder for computations
# Input   : Directory of subjects scans in .nii.gz format
# Output  : Output directory with subject folder for output files
#############################################################################
# USER-DEFINED PATHS - edit these before running
#############################################################################
INPUT_DIR="/path/to/subject_niftis"       # flat directory of .nii.gz files
OUTPUT_DIR="/path/to/output_directory"  # output directory for subject folders | /output/subj_1, /output/subj_2
#############################################################################

set -euo pipefail
 
echo " step0_organize: Starting subject directory organization "
echo " Input  : ${INPUT_DIR}"
echo " Output : ${OUTPUT_DIR}"
echo ""
 
find "${INPUT_DIR}" -type f -mindepth 1 -maxdepth 1 \( -name "*.nii" -o -name "*.nii.gz" \) | \
while IFS= read -r filepath; do
 
    full_filename="${filepath##*/}" # e.g. subject_001.nii.gz
 
    # Strip extensions cleanly — handles both .nii and .nii.gz
    subject_id="${full_filename%.nii.gz}"
    subject_id="${subject_id%.nii}" # e.g. subject_1
 
    subject_dir="${OUTPUT_DIR}/${subject_id}" # e.g. /output/subject_1 or /output/subject_2
 
    # Create subject directory if it does not already exist
    if [ ! -d "${subject_dir}" ]; then
        mkdir -p "${subject_dir}"
        echo "  Created : ${subject_dir}"
    fi
 
    # Copy scan into subject directory
    cp "${filepath}" "${subject_dir}/${full_filename}"
    echo "  Copied  : ${full_filename} → ${subject_dir}/"
 
done
 
echo ""
echo " step0_organize: Done "

