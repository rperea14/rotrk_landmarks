function [ roi_mean_xyz ] = rotrk_ROImean(roi_input, header)
%   function [ roixyz ] = drigo_trk_removebyROI(header, tracts, roi
%
%   IN ->
%           roi_input     : roi niftii file with the needed information
%           (either in rotrk format or just the filename)
%           header        : header info for (tmp_xyz*mat2) transformation
%   OUTPUT:
%               roixyz  : output with a 3xn matrix of xyz coordinates in
%               trk space


%If roi_input is in structure form (e.g. roi_input.id and
%roi_input.filename)
if isstruct(roi_input)
    H_vol=spm_vol(cell2char(roi_input.filename));
    mat2=H_vol.mat;
    roi_mean_xyz.id=roi_input.id;
elseif iscell(roi_input)
    H_vol=spm_vol(cell2char(roi_input));
    mat2=H_vol.mat;
    roi_mean_xyz.id='No ID, since roi_input.filename was not input (no in struct form)!';
else
    H_vol=spm_vol(roi_input);
    mat2=H_vol.mat;
    roi_mean_xyz.id='No ID, since roi_input.filename was not input (no in struct form)!';
end

V_vol=spm_read_vols(H_vol);

try    
ind=find(V_vol>0);
[ x y z ]  = ind2sub(size(V_vol),ind);
tmp_xyz = [ x-1 y-1 z-1 ones(numel(x),1) ] ;

roi_mean_xyz= mean(abs(tmp_xyz*mat2));
%roi_mean_xyz=round(mean(tmp_xyz));
roi_mean_xyz=roi_mean_xyz(1:3);
catch 
    error(['rotrk: the error must be when you invoked' roi_input 'to mean it. ' ] )
end