function [TRKS_OUT] = rotrk_join_trks(varargin)
%function [TRKS_OUT] = rotrk_join_trks(varargin)
%ROTRK_JOIN_TRKS - Join all .trks given in an argument
% Inputs:
%    varargin - Enter as many *.trks *.trks.gz (or in structu form) that you want to join 
% Output:
%    TRKS_OUT - It will output a struct form of all the tracts joined in
%    struct form
%   Created by Rodrigo Perea Github: https://github.com/Drigomaniac

AA=1;

%CHECK THAT HEADER VALUES ARE THE SAME!
for ii=2:numel(varargin)
    if varargin{1}.header.dim ~= varargin{ii}.header.dim
        error([ 'Exiting...trk_1.header.dim is not equal to trk_' num2str(ii) ] )
    end
    if varargin{1}.header.voxel_size ~= varargin{ii}.header.voxel_size
        error([ 'Exiting...trk_1.header.voxel_size is not equal to trk_' num2str(ii) ] )
    end
    if varargin{1}.header.voxel_order ~= varargin{ii}.header.voxel_order
        error([ 'Exiting...trk_1.header.voxel_order (' varargin{1}.header.voxel_order ') is not equal to trk_' num2str(ii) '(' varargin{ii}.header.voxel_order ')' ] )
    end
    
     if varargin{1}.header.vox_to_ras ~= varargin{ii}.header.vox_to_ras
        error([ 'Exiting...trk_1.header.vox_to_ras is not equal to trk_' num2str(ii) ] )
    end
end

%WORKING ON TRKS_OUT.SSTR:
for ii=1:numel(varargin)
  TRKS_OUT.sstr(ii).matrix = varargin{ii}.sstr.matrix;
  TRKS_OUT.sstr(ii).vox_coord = varargin{ii}.sstr.vox_coord;
  TRKS_OUT.sstr(ii).nPoints = varargin{ii}.sstr.nPoints;
end
%Get the volume of non-overlapping XYZ vox_coord values
all_vox=TRKS_OUT.sstr(1).vox_coord ;        %initializing vox_coord
for ii=2:size(TRKS_OUT.sstr,2)
    all_vox=vertcat(all_vox,TRKS_OUT.sstr(ii).vox_coord);
end
%s_all_vox=sort(all_vox); %sort if bad! I believe it doesn't freeze the Y
%and Z columns so no good to do this! 
TRKS_OUT.unique_voxels=unique(all_vox,'rows');
TRKS_OUT.num_uvox=size(TRKS_OUT.unique_voxels,1);



%WORKING ON TRKS_OUT.HEADER:
%Filled up fields other than sstr related
TRKS_OUT.header=varargin{1}.header;
TRKS_OUT.header.n_count=size(TRKS_OUT.sstr,2);

%WORKING ON TRKS_OUTR.<OTHER FIELDS>:
TRKS_OUT.id='joined_trks';
TRKS_OUT.filename='not_assigned_due_to_joining';


