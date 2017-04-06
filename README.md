# rotrk_landmarks
A set of tools to read, write and modify *.trk files from diffusion imaging tractography. 

The *trk file format is explained in detailed here: 
http://trackvis.org/docs/?subsect=fileformat

The dependencies:
1. Matlab: https://www.mathworks.com/products/matlab.html (tested in v.2015a/b, 2016a)
   *freeware alternative: Octave https://www.gnu.org/software/octave/ (not tested)
2. SPM8 matlab toolbox (http://www.fil.ion.ucl.ac.uk/spm/software/)


*In Matlab v.2017a
*There is a bug in spm_vol() making it loop forever when reading a filename when using Matlab 2017a
