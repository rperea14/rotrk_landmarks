function [ TRKS_OUT ] = rotrk_add_sc(TRKS_IN, vol_input_diffmetric_untyped,opt )
%function [ TRKS_OUT ] = rotrk_add_sc(TRKS_IN,vol_input_diffmetric,opt)
%
%**Modified from along-tracts. Many issues with coregistering FA to the exact
%location due to mismatch LR/ assigments or +-1 locations...
%
%
%TRK_ADD_SC - Attaches a scalar value to each vertex in a .trk track group
%For example, this function can look in an FA volume, and attach the
%corresponding voxel FA value to each streamline vertex.
%
% Inputs:
%    TRKS_IN.header - Header information from .trk file [struc]
%    TRKS_IN.tracts - Tract data struc array [1 x ntracts]
%    vol_input_diffmetric_untyprf - Scalar MRI volume to be added into the tract data struct
%    opt - designates the metric of the vol_input (e.g. FA)
% Outputs:
%    TRKS.OUT.header - Updated header
%    TRKS.OUT.sstr - Updated tracts structure



%%%%%%%%SPLITTING THTE TRACTS_STRUCT FORM INTO TRACTS AND HEADER
TRKS_OUT.header=TRKS_IN.header;
TRKS_OUT.id=TRKS_IN.id;
TRKS_OUT.filename=TRKS_IN.filename;
TRKS_OUT.sstr=TRKS_IN.sstr;

%Check if other fields exist...
if isfield(TRKS_IN,'trk_name')
    TRKS_OUT.trk_name=TRKS_IN.trk_name;
end

if isfield(TRKS_IN,'unique_voxels')
    TRKS_OUT.unique_voxels=TRKS_IN.unique_voxels;
end

if isfield(TRKS_IN,'num_uvox')
    TRKS_OUT.num_uvox=TRKS_IN.num_uvox;
end

if ischar(vol_input_diffmetric_untyped)
    vol_input_diffmetric.filename={vol_input_diffmetric_untyped};
    if nargin > 2
        vol_input_diffmetric.identifier=opt;
    else
        vol_input_diffmetric.identifier='null';
    end
else
    vol_input_diffmetric=vol_input_diffmetric_untyped;
end


%Adding scalar name to the streamlines (for reference)
if nargin < 2    
    error('Make sure you add a scalar volime as your 2nd argument!')
end

if isfield(TRKS_IN.header,'scalar_IDs')
    scalar_count=size(TRKS_IN.header.scalar_IDs,2);
%    warning('Adding scalars to already existing data!');
else
    scalar_count=1;
end



%WORKING WITH GZIP NII:
%IS IT GZIPPED??
%VOL_INPUT NII:
for ii=1:size(vol_input_diffmetric,1)
    [ ronii_dirpath{ii}, ronii_filename{ii}, ronii_ext{ii} ] = fileparts(vol_input_diffmetric{ii}.filename{end});
    if strcmp(ronii_ext,'.gz')
        disp(['Gunzipping...' vol_input_diffmetric{ii}.filename{end} ]);
        system([ 'gunzip -f ' vol_input_diffmetric{ii}.filename{end} ] );
        vol_input_diffmetric{ii}.filename = {[ ronii_dirpath filesep ronii_filename ]};
    end
end





for pp=1:size(vol_input_diffmetric,1)
    if size(vol_input_diffmetric,1) ==1 
        H_vol= spm_vol(cell2char(vol_input_diffmetric.filename));
    else
        H_vol= spm_vol(cell2char(vol_input_diffmetric{pp}.filename));
    end
    V_vol=spm_read_vols(H_vol);
    
    %Updating fields...
    %TRKS_OUT.header.n_scalars = scalar_count; ~~> Not updates as scalars
    %wont be in sstr.matrix but instead in sstr.vox_coord!!
    scalar_count=scalar_count+1;
    if size(vol_input_diffmetric,1) == 1
        if isfield(TRKS_IN.header,'scalar_IDs') == 0
            TRKS_OUT.header.scalar_IDs={vol_input_diffmetric.identifier};
        else
            TRKS_OUT.header.scalar_IDs=[ TRKS_IN.header.scalar_IDs {vol_input_diffmetric.identifier} ] ;
        end
    else
        if pp==1
            if isfield(TRKS_IN.header,'scalar_IDs') == 0
                TRKS_OUT.header.scalar_IDs={vol_input_diffmetric{1}.identifier};
            else
                TRKS_OUT.header.scalar_IDs=[ TRKS_IN.header.scalar_IDs {vol_input_diffmetric{pp}.identifier} ] ;
            end
        else
            TRKS_OUT.header.scalar_IDs=[ TRKS_OUT.header.scalar_IDs {vol_input_diffmetric{pp}.identifier} ] ;
        end
    end
    % Loop over # of tracts (slow...any faster way?)
    for ii=1:length(TRKS_IN.sstr)
        % Translate continuous vertex coordinates into discrete voxel coordinates
        
        %**
        % **For some reason, pos (X Y Z coordinates) are +1 indexed (eg. in
        %   FSLView the value at 88 80 30 will make pos to have coordinates 89 81 31
        %   (now in function rotrk_ROIxyz.m, where we get the exact coordinates (and others),
        %   we get rid of this indexing problem (by -1ing all coordinates) to get the
        %   correct coordinates. Here pos values don't matter as we only extract the
        %   values at exact position. Though, it has been checked that values with function
        %   rotrk_trk2roi.m has the same problem with pos but denote the output needed.
        %   ***Most likely this is a problem with indexing either starting at 0
        %   or 1
        %**
        
        
        %%======================================================================
        % Translate continuous vertex coordinates into discrete voxel coordinates
        pos =TRKS_IN.sstr(ii).vox_coord(:,1:3);
        pos=pos+1;
        %Same replacing but for extreme values (based of header.dim(x/y/z)
        extreme_x=find(pos(:,1)>=TRKS_IN.header.dim(1)) ; for gg=1:numel(extreme_x); pos(extreme_x(gg),1)=TRKS_IN.header.dim(1) ; end
        extreme_y=find(pos(:,2)>=TRKS_IN.header.dim(2)) ; for gg=1:numel(extreme_y); pos(extreme_y(gg),2)=TRKS_IN.header.dim(2) ; end
        extreme_z=find(pos(:,3)>=TRKS_IN.header.dim(3)) ; for gg=1:numel(extreme_z); pos(extreme_z(gg),3)=TRKS_IN.header.dim(3) ; end
        
        %%======================================================================
        % Index into volume to extract scalar values
        ind                = sub2ind(TRKS_IN.header.dim, pos(:,1), pos(:,2), pos(:,3));
        cur_scalar             = V_vol(ind);
        
        TRKS_OUT.sstr(ii).vox_coord = [TRKS_OUT.sstr(ii).vox_coord, cur_scalar];
    
        TRKS_OUT.sstr(ii).matrix = TRKS_IN.sstr(ii).matrix;
        TRKS_OUT.sstr(ii).nPoints = TRKS_IN.sstr(ii).nPoints;
    end
    
    
    %This will occur if TRKS_IN.unique_voxles struct array exist!
    if isfield(TRKS_IN,'unique_voxels')
         %**
        % **For some reason, pos (X Y Z coordinates) are +1 indexed (eg. in
        %   FSLView the value at 88 80 30 will make pos to have coordinates 89 81 31
        %   (now in function rotrk_ROIxyz.m, where we get the exact coordinates (and others),
        %   we get rid of this indexing problem (by -1ing all coordinates) to get the
        %   correct coordinates. Here pos values don't matter as we only extract the
        %   values at exact position. Though, it has been checked that values with function
        %   rotrk_trk2roi.m has the same problem with pos but denote the output needed.
        %   ***Most likely this is a problem with indexing either starting at 0
        %   or 1
        %**
        pos =TRKS_IN.unique_voxels(:,1:3);
        pos=pos+1;
        %Same replacing but for extreme values (based of header.dim(x/y/z)
        extreme_x=find(pos(:,1)>=TRKS_IN.header.dim(1)) ; for gg=1:numel(extreme_x); pos(extreme_x(gg),1)=TRKS_IN.header.dim(1) ; end
        extreme_y=find(pos(:,2)>=TRKS_IN.header.dim(2)) ; for gg=1:numel(extreme_y); pos(extreme_y(gg),2)=TRKS_IN.header.dim(2) ; end
        extreme_z=find(pos(:,3)>=TRKS_IN.header.dim(3)) ; for gg=1:numel(extreme_z); pos(extreme_z(gg),3)=TRKS_IN.header.dim(3) ; end
        %%======================================================================
        % Index into volume to extract scalar values
        ind                = sub2ind(TRKS_IN.header.dim, pos(:,1), pos(:,2), pos(:,3));
        cur_scalar             = V_vol(ind);
        TRKS_OUT.unique_voxels = [TRKS_OUT.unique_voxels, cur_scalar];
    end
end



%Gzip again if needeD:
for ii=1:size(vol_input_diffmetric,1)
    if strcmp(ronii_ext{ii},'.gz')
        system([ 'gzip -f ' vol_input_diffmetric{ii}.filename{end} ] );
    end
end
