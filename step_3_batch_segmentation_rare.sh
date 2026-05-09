#!/usr/bin/env bash
#
# step_3_batch_segmentation_rare.sh
#############################################################################
# Purpose : Perform brain extraction on all TurboRARE subject scans
#           Registers the TurboRARE template to each subject's native space,
#           applies the resulting transformation to the brain mask,
#           and multiplies the mask by the subject scan to extract the brain
# Usage   : bash step_3_batch_segmentation_rare.sh
# Input   : Subject directories containing rare/corrected_rare.nii.gz
# Output  : Brain mask and brain extracted image in each subject's rare/ folder
# Next    : Run step_4_batch_template_creation.sh
#############################################################################

#############################################################################
# USER-DEFINED PATHS — edit these before running
#############################################################################
SUBJECT_DIR= "/path/to/subject/scans_directory" #directory of subject scan directories
TEMPLATE_DIR="path/to/template_scans" # the directory that contains the .nii and/or .nii.gz template scans
#############################################################################

# These are the template and atlas mask definitions
moving_img=${TEMPLATE_DIR}/corrected_template_t2.nii.gz
atlas_label_file=${TEMPLATE_DIR}/brain_mask_template_t2.nii.gz

#############################################################################
# Step: Registration and brain extraction — TurboRARE
#############################################################################
echo "######## Starting TurboRARE brain extraction ########"

find "${SUBJECT_DIR}" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r d; do
    echo "  Processing: $(basename $d)"

    fixed_img="$d"/rare/corrected_rare.nii.gz
    output_dir="$d"/rare
    output_prefix=${output_dir}/SWAN_

    #######################################################
    # Step: Registration — warp template to subject native space
    #######################################################
    antsRegistrationSyN.sh -d 3 -f ${fixed_img} -m ${moving_img} -o ${output_prefix}

    #######################################################
    # Step: Apply transformation to brain mask
    #######################################################
    antsApplyTransforms -d 3 \
                        -i  ${atlas_label_file} \
                        -r  ${fixed_img} \
                        -o  ${output_prefix}_brain_mask.nii.gz \
                        -n  NearestNeighbor \
                        -t  ${output_prefix}1Warp.nii.gz \
                        -t  ${output_prefix}0GenericAffine.mat

    #######################################################
    # Step: Multiply subject scan by brain mask to extract brain
    #######################################################
    echo "    Multiplying image by brain mask..."
    fslmaths "${fixed_img}" -mul "${output_prefix}_brain_mask.nii.gz" "${output_dir}/SWAN_brain.nii.gz"
    echo "    Brain extracted image saved to: ${output_dir}/SWAN_brain.nii.gz"

done

echo ""
echo "######## step_3_batch_segmentation_rare: Done ########"
echo "    Next: run step_4_batch_template_creation.sh"
