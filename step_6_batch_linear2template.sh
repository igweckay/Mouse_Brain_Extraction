#!/usr/bin/env bash
#
# step_6_batch_linear2template.sh
#############################################################################
# Purpose : OPTIONAL - Perform affine registration of each subject's brain
#           extracted volume to the population-specific atlas.
#           Separate registrations are performed for DCE and TurboRARE.
# Usage   : bash step_6_batch_linear2template.sh
# Input   : Subject directories containing dce/SWAN_brain.nii.gz
#           and rare/SWAN_brain.nii.gz
#           Population atlases from step_5_batch_template_creation.sh
# Output  : Affine registered brain volumes saved to each subject's
#           dce/ and rare/ subfolders
# Note    : This step is optional and requires step_5 to have been run first.
#           Affine registration accounts for global differences in position,
#           orientation, and scale between the subject and atlas space.
#############################################################################

#############################################################################
# USER-DEFINED PATHS - edit these before running
#############################################################################
SUBJECT_DIR= "/path/to/subject/scans_directory" # directory of subject scan directories
ATLAS_DIR="/path/to/population_atlases"

# Population atlas files from step_5
atlas_dce=${ATLAS_DIR}/dce/SWAN_template0.nii.gz
atlas_rare=${ATLAS_DIR}/rare/SWAN_template0.nii.gz
#############################################################################

#############################################################################
# Step: Affine registration to population atlas — DCE
#############################################################################
echo "######## Starting DCE affine registration to atlas ########"

find "${SUBJECT_DIR}" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r d; do
    echo "  Processing: $(basename $d)"

    input_image="$d"/dce/SWAN_brain.nii.gz
    output_prefix="$d"/dce/brain_to_template_
    output_image="${output_prefix}Warped.nii.gz"

    ######## Check if input file exists ########
    if [ ! -f "${input_image}" ]; then
        echo "    Warning: ${input_image} not found — skipping"
        continue
    fi

    antsRegistration \
        --dimensionality 3 \
        --output "[${output_prefix},${output_image}]" \
        --float 1 \
        --initial-moving-transform "[${atlas_dce},${input_image},1]" \
        --transform Affine[0.1] \
        --metric MI[${atlas_dce},${input_image},1,32,Regular,0.25] \
        --convergence "[1000x500x250x100,1e-6,10]" \
        --shrink-factors "12x8x4x2" \
        --smoothing-sigmas "4x3x2x1vox"

    echo "    DCE registered image saved to: ${output_image}"

done

echo ""

#############################################################################
# Step: Affine registration to population atlas — TurboRARE
#############################################################################
echo "######## Starting TurboRARE affine registration to atlas ########"

find "${SUBJECT_DIR}" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r d; do
    echo "  Processing: $(basename $d)"

    input_image="$d"/rare/SWAN_brain.nii.gz
    output_prefix="$d"/rare/brain_to_template_
    output_image="${output_prefix}Warped.nii.gz"

    ######## Check if input file exists ########
    if [ ! -f "${input_image}" ]; then
        echo "    Warning: ${input_image} not found — skipping"
        continue
    fi

    antsRegistration \
        --dimensionality 3 \
        --output "[${output_prefix},${output_image}]" \
        --float 1 \
        --initial-moving-transform "[${atlas_rare},${input_image},1]" \
        --transform Affine[0.1] \
        --metric MI[${atlas_rare},${input_image},1,32,Regular,0.25] \
        --convergence "[1000x500x250x100,1e-6,10]" \
        --shrink-factors "12x8x4x2" \
        --smoothing-sigmas "4x3x2x1vox"

    echo "    TurboRARE registered image saved to: ${output_image}"

done

echo ""
echo "######## step_6_batch_linear2template: Done ########"