# rotrk_landmarks
A set of tools to read, write and modify *.trk *.trk.gz or *.nii  *.nii.gz files from diffusion imaging tractography. 




The *trk file format is explained in detailed here: 
http://trackvis.org/docs/?subsect=fileformat

The dependencies:
1. Matlab: https://www.mathworks.com/products/matlab.html (tested in v.2015a/b, 2016a) __
   *freeware alternative: Octave https://www.gnu.org/software/octave/ (not tested) __ 
2. <s>SPM8 (may give you issues with Matlab v.2017 or higher </s> SPM12 matlab toolbox (http://www.fil.ion.ucl.ac.uk/spm/software/)   __


<s> *There is a bug in spm_vol() and SPM8 making it loop forever when reading a filename when using Matlab 2017a </s>


Ideal naming format for the *.trk files:

trk_\<METHOD>\_\<PROJECTID>\_\<SUBJID>\_\<TRK_NAME>.trk

Example: 
    trk_rmlen_193231_SJIT03437_Fmi.trk




