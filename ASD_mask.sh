#!/bin/bash

# first creat the appropriate masks
cd /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/ambmc

fslmaths AMBMC-c57bl6-basalganglia-labels-15um.nii.gz -thr 7 -uthr 7 -bin cc_mask   -odt char

fslmaths AMBMC-c57bl6-hippocampus-labels-15um.nii.gz -bin  hpc_mask   -odt char



#split the masks into left and right,
#Left -> FA
#Right -> MD

# x = 680
for mask in *_mask.nii.gz;do
    fslorient -setsformcode 2 $mask
    fslroi ${mask} R_${mask} 339 339    0 -1    0 -1
    fslroi ${mask} L_${mask} 0   339    0 -1    0 -1
done

mkdir /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/ambmc/ASD
mv /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/ambmc/*_mask.nii.gz /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/ambmc/ASD


# fslorient -setsformcode 2 /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/ambmc/AMBMC_model.nii


cd /media/amr/Amr_4TB/Dropbox/DTI_Review_Revisions/ambmc/ASD
fslmaths L_cc_mask -mul -0.5 L_cc_mask
fslmaths R_cc_mask -mul 1 R_cc_mask


fslmaths L_hpc_mask -mul 0.2 L_hpc_mask
fslmaths R_hpc_mask -mul  1  R_hpc_mask

#Now to facilitate overlaying all these high-resolution masks, it seems appropriate to just keep the slice I am interested in
# 0 544 498

for mask in *_mask.nii.gz;do
    fslroi $mask  one_slice_${mask} 0 -1 544 1 0 -1
done


#Draw an outline around each ROI by eroding one voxel and then subtract from the original one_slice ROI giving you an outline
for f in one_slice_*_mask.nii.gz;do
    X=`${FSLDIR}/bin/fslval $f dim1`; X=`echo "$X 2 - p" | dc -`
    Y=`${FSLDIR}/bin/fslval $f dim2`; Y=`echo "$Y 2 - p" | dc -`
    Z=`${FSLDIR}/bin/fslval $f dim3`; Z=`echo "$Z 2 - p" | dc -`
    $FSLDIR/bin/fslmaths $f -min 1 -ero -roi 1 $X 1 $Y 1 $Z 0 1 eroded_${f}
    fslmaths $f -sub eroded_${f} -bin outline_${f}
done
