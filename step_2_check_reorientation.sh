#!/usr/bin/env bash
#
# step_2_check_orientation.sh
#############################################################################
# Purpose : Check orientation of all subject scans against the template
#           Output TRUE if all scans match template orientation, FALSE if not
#           If FALSE, two reorientation options are provided below (commented out)
# Usage   : bash step_2_check_orientation.sh
# Input   : Subject directories containing dce/ and rare/ subfolders
# Output  : Printed orientation report for each subject and final TRUE/FALSE
# Next    : Run step_3_batch_segmentation.sh
#############################################################################

#############################################################################
# USER-DEFINED PATHS — edit these before running
#############################################################################
SUBJECT_DIR= "/path/to/subject/scans_directory" #directory of subject scan directories
TEMPLATE_DIR="path/to/template_scans" # the directory that contains the .nii and/or .nii.gz template scans
#############################################################################

#############################################################################
# Step: Get template orientation (reference)
#############################################################################
echo "######## Getting template orientations ########"

TEMPLATE_ORIENT_DCE=$(python3 -c "import nibabel as nib; import sys; print(nib.aff2axcodes(nib.load(sys.argv[1]).affine))" ${TEMPLATE_DIR}/template_dce.nii)
TEMPLATE_ORIENT_T2=$(python3 -c "import nibabel as nib; import sys; print(nib.aff2axcodes(nib.load(sys.argv[1]).affine))" ${TEMPLATE_DIR}/template_t2.nii)

echo "  DCE template orientation     : ${TEMPLATE_ORIENT_DCE}"
echo "  TurboRARE template orientation: ${TEMPLATE_ORIENT_T2}"
echo ""

#############################################################################
# Step: Check orientation of all subject scans against template
#############################################################################
echo "######## Checking subject orientations ########"

all_match=true

find "${SUBJECT_DIR}" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r d; do
    echo "  Processing: $(basename $d)"

    # DCE
    SUBJECT_ORIENT_DCE=$(python3 -c "import nibabel as nib; import sys; print(nib.aff2axcodes(nib.load(sys.argv[1]).affine))" $d/dce/dce_scan.nii)
    echo "    DCE orientation     : ${SUBJECT_ORIENT_DCE}"
    if [ "${SUBJECT_ORIENT_DCE}" != "${TEMPLATE_ORIENT_DCE}" ]; then
        echo "    DCE orientation MISMATCH for $(basename $d)"
        all_match=false
    fi

    # TurboRARE
    SUBJECT_ORIENT_T2=$(python3 -c "import nibabel as nib; import sys; print(nib.aff2axcodes(nib.load(sys.argv[1]).affine))" $d/rare/rare.nii)
    echo "    TurboRARE orientation: ${SUBJECT_ORIENT_T2}"
    if [ "${SUBJECT_ORIENT_T2}" != "${TEMPLATE_ORIENT_T2}" ]; then
        echo "    TurboRARE orientation MISMATCH for $(basename $d)"
        all_match=false
    fi

done

echo ""
if [ "$all_match" = true ]; then
    echo "######## Orientation check: TRUE — all subjects match template ########"
    echo "    Next: run step_3_batch_segmentation.sh"
else
    echo "######## Orientation check: FALSE — mismatches detected ########"
    echo "    Review mismatches above and choose a reorientation option below"
fi

#############################################################################
# REORIENTATION OPTIONS - uncomment and run manually if orientation check
# returns FALSE. Choose Option 1 OR Option 2, not both.
#############################################################################

#############################################################################
# Option 1: Reorient template to subject space (preserves native subject data)
#############################################################################
# Recommended when you want to keep all subject scans untouched
#
# Sub-option A: fslreorient2std (automatic — reorients to standard space)
#
# fslreorient2std ${TEMPLATE_DIR}/template_dce.nii ${TEMPLATE_DIR}/reoriented_template_dce.nii.gz
# fslreorient2std ${TEMPLATE_DIR}/template_t2.nii ${TEMPLATE_DIR}/reoriented_template_t2.nii.gz
#
# Sub-option B: fslswapdim (manual — specify axes explicitly)
# Replace x y z with your desired axis directions e.g. x y -z
#
# fslswapdim ${TEMPLATE_DIR}/template_dce.nii x y z ${TEMPLATE_DIR}/reoriented_template_dce.nii.gz
# fslswapdim ${TEMPLATE_DIR}/template_t2.nii x y z ${TEMPLATE_DIR}/reoriented_template_t2.nii.gz

#############################################################################
# Option 2: Reorient all subject scans to template space (common space)
#############################################################################
# Recommended when you want all subjects in a common orientation
#
# Sub-option A: fslreorient2std (automatic — reorients to standard space)
#
# find "${SUBJECT_DIR}" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r d; do
#     fslreorient2std $d/dce/dce_scan.nii $d/dce/reoriented_dce_scan.nii.gz
#     fslreorient2std $d/rare/rare.nii $d/rare/reoriented_rare.nii.gz
# done
#
# Sub-option B: fslswapdim (manual — specify axes explicitly)
# Replace x y z with your desired axis directions e.g. x y -z
#
# find "${SUBJECT_DIR}" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r d; do
#     fslswapdim $d/dce/dce_scan.nii x y z $d/dce/reoriented_dce_scan.nii.gz
#     fslswapdim $d/rare/rare.nii x y z $d/rare/reoriented_rare.nii.gz
# done