#!/usr/bin/env bash
#
# step_4_smoothing_optional_rare.sh
#############################################################################
# Purpose : Optional smoothing of TurboRARE brain masks and brain extracted images
#           A Gaussian kernel is applied to the brain mask, which is then
#           rebinarized and multiplied by the original scan to produce a
#           smoothed brain extracted image
# Usage   : bash step_4_smoothing_optional_rare.sh
# Input   : Subject directories containing rare/SWAN__brain_mask.nii.gz
#           and rare/corrected_rare.nii.gz
# Output  : SWAN__brain_mask_smooth.nii.gz - smoothed brain mask
#           SWAN_brain_smooth.nii.gz - smoothed brain extracted image
# Note    : Gaussian kernel size of 0.15 was empirically determined on this
#           dataset. Adjust GAUSS_KERNEL as needed for your data (e.g. 0.2)
#############################################################################

#############################################################################
# USER-DEFINED PATHS - edit these before running
#############################################################################
SUBJECT_DIR= "/path/to/subject/scans_directory" #directory of subject scan directories
GAUSS_KERNEL=0.15   # Gaussian kernel size - try 0.2 if 0.15 is insufficient
#############################################################################

#############################################################################
# Step: Smooth brain mask and generate smoothed brain extracted image — TurboRARE
#############################################################################
echo "######## Starting TurboRARE mask smoothing ########"

find "${SUBJECT_DIR}" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r d; do
    echo "  Processing: $(basename $d)"

    brain_mask="$d"/rare/SWAN__brain_mask.nii.gz
    fixed_img="$d"/rare/corrected_rare.nii.gz
    smooth_mask="$d"/rare/SWAN__brain_mask_smooth.nii.gz
    smooth_brain="$d"/rare/SWAN_brain_smooth.nii.gz

    #############################################################################
    # Step: Apply Gaussian smoothing to brain mask and rebinarize
    # Smoothing introduces non-binary values, so -thr 0.5 -bin rebinarizes the mask
    #############################################################################
    fslmaths "${brain_mask}" -kernel gauss ${GAUSS_KERNEL} -fmean -thr 0.5 -bin "${smooth_mask}"
    echo "    Smoothed mask saved to: ${smooth_mask}"

    #############################################################################
    # Step: Multiply original scan by smoothed mask to get smoothed brain extraction
    #############################################################################
    fslmaths "${fixed_img}" -mul "${smooth_mask}" "${smooth_brain}"
    echo "    Smoothed brain saved to: ${smooth_brain}"

done

echo ""
echo "######## step_4_smoothing_optional_rare: Done ########"
echo "    Next: run step_5_batch_template_creation.sh"

