#!/usr/bin/env bash
#
# step_5_batch_template_creation.sh
#############################################################################
# Purpose : OPTIONAL - Construct population-specific atlases from brain
#           extracted volumes using ANTs multivariate template construction.
#           Separate atlases are built for DCE and TurboRARE modalities.
#           These atlases can be stratified by any biological variable
#           of interest (e.g. age, genotype, disease state).
# Usage   : bash step_5_batch_template_creation.sh
# Input   : Subject directories containing dce/SWAN_brain.nii.gz
#           and rare/SWAN_brain.nii.gz
# Output  : Population-specific atlases saved to population_atlases/dce/
#           and population_atlases/rare/
# Note    : This step is optional. If a suitable atlas already exists,
#           proceed directly to step_6_batch_linear2template.sh
# Next    : Run step_6_batch_linear2template.sh
#############################################################################

#############################################################################
# USER-DEFINED PATHS — edit these before running
#############################################################################
SUBJECT_DIR= "/path/to/subject/scans_directory" # directory of subject scan directories
ATLAS_DIR="/path/to/population_atlases"
#############################################################################

#############################################################################
# Step: Create output directories
#############################################################################
mkdir -p ${ATLAS_DIR}/dce
mkdir -p ${ATLAS_DIR}/rare

#############################################################################
# Step: Collect brain extracted images for template construction
#############################################################################
echo "######## Collecting brain extracted images ########"

input_images_dce=$(ls ${SUBJECT_DIR}/*/dce/SWAN_brain.nii.gz)
input_images_rare=$(ls ${SUBJECT_DIR}/*/rare/SWAN_brain.nii.gz)

echo "  DCE images found:"
echo "${input_images_dce}" | while IFS= read -r f; do echo "    $f"; done

echo "  TurboRARE images found:"
echo "${input_images_rare}" | while IFS= read -r f; do echo "    $f"; done

echo ""

#############################################################################
# Step: Build DCE population atlas
#############################################################################
echo "######## Building DCE population atlas ########"

cd ${ATLAS_DIR}/dce

antsMultivariateTemplateConstruction2.sh \
    -d 3 \
    -o "SWAN_" \
    -i 4 \
    -k 1 \
    -g 0.25 \
    -c 0 \
    ${input_images_dce}

echo "  DCE atlas saved to: ${ATLAS_DIR}/dce"
echo ""

#############################################################################
# Step: Build TurboRARE population atlas
#############################################################################
echo "######## Building TurboRARE population atlas ########"

cd ${ATLAS_DIR}/rare

antsMultivariateTemplateConstruction2.sh \
    -d 3 \
    -o "SWAN_" \
    -i 4 \
    -k 1 \
    -g 0.25 \
    -c 0 \
    ${input_images_rare}

echo "  TurboRARE atlas saved to: ${ATLAS_DIR}/rare"
echo ""

echo "######## step_5_batch_template_creation: Done ########"
echo "    Next: run step_6_batch_linear2template.sh"