#!/bin/bash
cd /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/sigma
# first creat the appropriate masks
fslmaths SIGMA_Anatomical_Brain_Atlas.nii -thr 731 -uthr 731 -bin R_str_mask   -odt char
fslmaths SIGMA_Anatomical_Brain_Atlas.nii -thr 732 -uthr 732 -bin L_str_mask   -odt char

fslmaths SIGMA_Anatomical_Brain_Atlas.nii -thr 751 -uthr 751 -bin R_sn_mask   -odt char
fslmaths SIGMA_Anatomical_Brain_Atlas.nii -thr 752 -uthr 752 -bin L_sn_mask   -odt char

#Draw an outline around each ROI by eroding one voxel and then subtract from the original one_slice ROI giving you an outline
for f in ?_*_mask.nii.gz;do
    X=`${FSLDIR}/bin/fslval $f dim1`; X=`echo "$X 2 - p" | dc -`
    Y=`${FSLDIR}/bin/fslval $f dim2`; Y=`echo "$Y 2 - p" | dc -`
    Z=`${FSLDIR}/bin/fslval $f dim3`; Z=`echo "$Z 2 - p" | dc -`
    $FSLDIR/bin/fslmaths $f -min 1 -ero -roi 1 $X 1 $Y 1 $Z 0 1 eroded_${f}
    fslmaths $f -sub eroded_${f} -bin outline_${f}
done

#split the masks into left and right,
#Left -> FA
#Right -> MD


mkdir /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/sigma/PD
mv /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/sigma/*_mask.nii.gz /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/sigma/PD


cd /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/sigma/PD
fslmaths L_str_mask -mul 1 L_str_mask
fslmaths R_str_mask -mul 0 R_str_mask

fslmaths L_sn_mask -mul -0.272727273 L_sn_mask
fslmaths R_sn_mask -mul 1 R_sn_mask

# create left and right slice to mask left and right side by adjusting brightness to -1 0
cd ..
fslroi SIGMA_ExVivo_Brain_Template_Masked.nii  L_sigma  129 129    0 -1    0 -1
fslroi SIGMA_ExVivo_Brain_Template_Masked.nii  R_sigma  0 129    0 -1    0 -1
