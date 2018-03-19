function [ roi_xyz ] = rotrk_ROIxyz(roi_input,file_name)
% function [ roi_xyz ] = rotrk_ROIxyz(roi_input,file_name)
%
%   IN ->
%           roi_input       : roi niftii file with the needed information
%           file_name       : (optional) selects the file name for the XYz

%                             warning if not specified
%   OUTPUT:
%               roixyz  : output with a 3xn matrix of xyz coordinates in
%               trk space



roi_xyz.filename=roi_input;

if nargin < 3
    roi_orientation_mod = '' ;
end

%If roi_input is in structure form (e.g. roi_input.id and
%roi_input.filename)
if isstruct(roi_input)
    roi_xyz.filename=roi_input.filename;
    roi_xyz.id=roi_input.id;
elseif iscell(roi_input)
    roi_xyz.filename=cell2char(roi_input);
    roi_xyz.id='No ID!';
else
    roi_xyz.filename= {roi_input};
    if nargin < 2
        roi_xyz.id='No ID, since roi_input.filename was not input (no in struct form)!';
    else
        roi_xyz.id={file_name};
        roi_xyz.id = {file_name};
    end
end

%Is it gzip?
[ roi_dir , roi_name , roi_ext ] = fileparts(roi_xyz.filename{end});

%check if roi_dir is ~ ...
if strcmp(roi_dir,'~')
    roi_dir=getenv('HOME');
end
if strcmp(roi_ext,'.gz')
    system(['gunzip -f ' roi_xyz.filename{end}]);
    if isempty(roi_dir)
        roi_xyz.filename = {[ '.' filesep filesep roi_name ]}; 
    else
        roi_xyz.filename = {[ roi_dir filesep roi_name ]};
    end
end
%Read the volume:
H_vol = spm_vol(roi_xyz.filename{end});
mat2=H_vol.mat;
%Read the vols:
V_vol=spm_read_vols(H_vol);

%was it gzipped?
if strcmp(roi_ext,'.gz');
    system(['gzip -f ' roi_xyz.filename{end} ]);
    if isempty(roi_dir)
        roi_xyz.filename = {[ '.' filesep filesep roi_name roi_ext ]};
    else
        roi_xyz.filename = {[ roi_dir filesep roi_name roi_ext ]};
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ind=find(V_vol~=0);
[ x, y, z ]  = ind2sub(size(V_vol),ind);
%Check signs now (SOMETIMES WORKS, SOMETIMES IT DOESNT. PLEASE DOUBLEC CHECk!!!):
AA=1;
% if mat2(1,1) < 0 
%     x = H_vol.dim(1) - x ;
% end
% 
% if mat2(2,2) < 0 
%     y = H_vol.dim(2) - y ;
% end
% 
% if mat2(3,3) < 0 
%     z = H_vol.dim(3) - z ;
% end


%Verified and Oked on 4/18/17 by RDP20:
%All in Voxel coordinate space:
tmp_xyz = [ x y z ];
roi_xyz.vox_coord = tmp_xyz-1; %Dealing with the 0 vs. 1 index for vox_coord
roi_xyz.vox_coord(:,4) = V_vol(ind); %adding actual values to vox_coord


%Creating unique voxels and numbers for each:
%Get the volume of non-overlapping XYZ vox_coord values
roi_xyz.unique_voxels=unique(roi_xyz.vox_coord,'rows');
roi_xyz.num_uvox=size(roi_xyz.unique_voxels,1);



%###BELOW CANT BE DONE CORRECTLY AS FOR TRKING SPLINE INTERPOLATION IS NEEDED
%   THE APPROXIMATION CAN BE MATHEMATICALLY DONE.
%IDEAL APPROXIMATION IS BEING WORKED AS A SOLUTION
tmp2_xyz = [ tmp_xyz-1 ones(numel(x),1) ] ; %NOT SURE ABOUT THIS STEP. rdp20 11_01_2017 (INDEXING ALWAYS AN ISSUE)
%additional_step = abs(tmp2_xyz*mat2);
%temp_roi_xyz.approx_trk_coord = additional_step(:,1:3);

roi_xyz.approx_trk_coord(:,1) = tmp2_xyz(:,1)*abs(mat2(1,1));
roi_xyz.approx_trk_coord(:,2) = tmp2_xyz(:,2)*abs(mat2(2,2));
roi_xyz.approx_trk_coord(:,3) = tmp2_xyz(:,3)*abs(mat2(3,3));

roi_xyz.header= H_vol ; 
