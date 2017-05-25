function [ roi_xyz ] = rotrk_ROIxyz(roi_input)
%   function [ roixyz ] = rotrk_ROIxyz(header, tracts, roi
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
    roi_filename=cell2char(roi_input.filename);
    roi_mean_xyz.id=roi_input.id;
elseif iscell(roi_input)
    roi_filenamecell2char(roi_input);
    roi_mean_xyz.id='No ID!';
else
    roi_filename= roi_input;
    roi_mean_xyz.id='No ID, since roi_input.filename was not input (no in struct form)!';
end
%Is it gzip?
[ roi_dir , roi_name , roi_ext ] = fileparts(roi_filename);
if strcmp(roi_ext,'.gz')
    system(['gunzip -f ' roi_filename])
    if isempty(roi_dir)
        roi_filename = [ '.' filesep filesep roi_name ]; 
    else
        roi_filename = [ roi_dir filesep roi_name ];
    end
end
%Read the volume:
H_vol = spm_vol(roi_filename);
mat2=H_vol.mat;
%Check if the matfile is 
AA=1;



V_vol=spm_read_vols(H_vol);

%was it gzipped?
 if strcmp(roi_ext,'.gz');  system(['gzip -f ' roi_filename ]) ; end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ind=find(V_vol>0);
[ x y z ]  = ind2sub(size(V_vol),ind);
%Verified and Oked on 4/18/17 by RDP20:
%All in Voxel coordinate space:
tmp_xyz = [ x y z ];
roi_xyz.vox_coord = tmp_xyz-1; %Dealing with the 0 vs. 1 index for vox_coord 


%for plotting purposes the 'minus one (-1)' indexing shoulnd be
%applied?(edited 04-25-2017 rdp20)
%tmp2_xyz = [x y z ones(numel(x),1) ] ;
tmp2_xyz = [ x-1 y-1 z-1 ones(numel(x),1) ] ;
additional_step = abs(tmp2_xyz*mat2);
roi_xyz.trk_coord = additional_step(:,1:3);
