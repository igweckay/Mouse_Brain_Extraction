#!/usr/bin/env bash
#
# step_1_n4_bias_field_correction.sh
#############################################################################
# Purpose : Apply N4 bias field correction to all subject scans and templates
# Usage   : bash step_1_n4_bias_field_correction.sh
# Input   : Subject directories containing dce/ and rare/ subfolders
# Output  : Corrected scans (corrected_*.nii.gz) and bias fields (*_BiasField.nii.gz)
#           saved in the same modality subfolder as the input scan
# Next    : Run step_2_check_orientation.sh
#############################################################################

#############################################################################
# USER-DEFINED PATHS — edit these before running
#############################################################################
SUBJECT_DIR="/Users/kayigwe/Desktop/Kelley_Lund/Swanberg_BET_Data/scripts/ISMSM_SCRIPTS/github_files/output"
TEMPLATE_DIR="/Users/kayigwe/Desktop/Kelley_Lund/Swanberg_BET_Data/scripts/ISMSM_SCRIPTS/github_files/templates"
#############################################################################

#############################################################################
# Step: N4 bias field correction on templates (run once)
#############################################################################
echo "######## Correcting templates ########"

# DCE template
N4BiasFieldCorrection -d 3 \
    -i  ${TEMPLATE_DIR}/template_dce.nii \
    -o [ ${TEMPLATE_DIR}/corrected_template_dce.nii.gz, \
         ${TEMPLATE_DIR}/template_dce_BiasField.nii.gz ]
echo "  DCE template corrected"

# TurboRARE (T2) template
N4BiasFieldCorrection -d 3 \
    -i  ${TEMPLATE_DIR}/template_t2.nii \
    -o [ ${TEMPLATE_DIR}/corrected_template_t2.nii.gz, \
         ${TEMPLATE_DIR}/template_t2_BiasField.nii.gz ]
echo "  TurboRARE template corrected"

echo ""

#############################################################################
# Step: N4 bias field correction on subject scans
#############################################################################
echo "######## Correcting subject scans ########"

find "${SUBJECT_DIR}" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r d; do
    echo "  Processing: $(basename $d)"

    # DCE
    N4BiasFieldCorrection -d 3 \
        -i  $d/dce/dce_scan.nii \
        -o [ $d/dce/corrected_dce_scan.nii.gz, \
             $d/dce/dce_scan_BiasField.nii.gz ]
    echo "    DCE corrected"

    # TurboRARE
    N4BiasFieldCorrection -d 3 \
        -i  $d/rare/rare.nii \
        -o [ $d/rare/corrected_rare.nii.gz, \
             $d/rare/rare_BiasField.nii.gz ]
    echo "    TurboRARE corrected"

done

echo ""
echo "    step_1_bias_field_correction: Done"
echo "    Next: run step_2_check_orientation.sh"

