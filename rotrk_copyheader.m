function rotrk_copyheader(TRKS_fname,NII_fname,TRKS_OUT_fname)
%function rotrk_copyheader(TRKS_fname,NII_fname,TRKS_OUT_fname)
%Created by Rodrigo Perea
%This function will read TRKS_fname and NII_fname and copy the header
%information of NII_fname to TRKS_fname and save it into TRKS_fname_out
% IT ASSUMES TRKS_fname and NII_fname have been coregistered but ont having
% the same VOX to real world coordinates (a known issue with tracking
% dsi_studio trks.

%Reading th e
if ischar(TRKS_fname)
    TRKS_IN = rotrk_read(TRKS_fname,'simple_read',NII_fname);
else
    error('Filetypes should be char ending in *.trk or *.trk.gz. Please implement other uses' );
end


if nargin < 3
    [trk_outdir, trk_fname , trk_ext ] = fileparts(TRKS_fname);
    [nii_outdir, nii_fname , nii_ext ] = fileparts(NII_fname);
    if isempty(trk_outdir) ; trk_outdir= '.'; end
    TRKS_OUT_fname = [trk_outdir filesep trk_fname '_to_' nii_fname trk_ext];
    TRKS_OUT_fname = regexprep(TRKS_OUT_fname,'.gz','');
    warning(['No 3rd argument passed so writing to: ' TRKS_OUT_fname])
end


[nii_vols , nii_header ] = openIMG(NII_fname);
TRKS_IN.header.vox_to_ras = nii_header.mat ;


%Since we are copying the header, lets not modify the tracks when opening:
TRKS_IN.header.invert_x = 0;
TRKS_IN.header.invert_y = 0;
TRKS_IN.header.invert_z = 0;
rotrk_write(TRKS_IN.header, TRKS_IN.sstr,TRKS_OUT_fname);