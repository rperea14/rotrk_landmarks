function [ TRKS_OUT ] = rotrk_add_sc(TRKS_IN, vol_input_diffmetric_untyped,diffmetric, nproj )
%function [ TRKS_OUT ] = rotrk_add_sc(TRKS_IN, vol_input_diffmetric_untyped,diffmetric, nproj )
% By Rodrigo Perea --> github.com/Drigomaniac
%Attaches a scalar value to each vertex in a .trk track group
%For example, this function can look in an FA volume, and attach the
%corresponding voxel FA value to each streamline vertex.
%
% Inputs:
%    TRKS_IN.header - Header information from .trk file [struc]
%    TRKS_IN.tracts - Tract data struc array [1 x ntracts]
%    vol_input_diffmetric_untyprf - Scalar MRI volume to be added into the tract data struct
%    diffmetric - designates the diffmetric of the vol_input (e.g. FA)
%    nproj - (optional) do you want to project perpendicualr values instead
%                       of the value intself? If so, 1 for 1 voxel away, 
%                       2 for 2 voxels away, etc...
% Outputs:
%    TRKS.OUT.header - Updated header
%    TRKS.OUT.sstr - Updated tracts structure



%%%%%%%%SPLITTING THTE TRACTS_STRUCT FORM INTO TRACTS AND HEADER
TRKS_OUT.header=TRKS_IN.header;
TRKS_OUT.id=TRKS_IN.id;


%CHECK ARGUMENT TYPES:
for chck_argtype=1:1
    if isfield(TRKS_IN,'filename')
        TRKS_OUT.filename=TRKS_IN.filename;
    else
        TRKS_OUT.filename='';
    end
    TRKS_OUT.sstr=TRKS_IN.sstr;
    if isfield(TRKS_IN,'maxsstrlen')
        TRKS_OUT.maxsstrlen = TRKS_IN.maxsstrlen;
    end
    if isfield(TRKS_IN,'all_sstrlen')
        TRKS_OUT.all_sstrlen = TRKS_IN.all_sstrlen;
    end
    
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
        vol_input_diffmetric{1}.filename={vol_input_diffmetric_untyped};
        if nargin > 2
            vol_input_diffmetric{1}.identifier=diffmetric;
        else
            vol_input_diffmetric{1}.identifier='null';
        end
    else
        vol_input_diffmetric=vol_input_diffmetric_untyped;
    end
end

%Adding scalar name to the streamlines (for reference)
if nargin < 2    
    error('Make sure you add a scalar volime as your 2nd argument!')
end

if nargin < 4
    nproj=''; %No project is set. Working on the actual voxel value...
end

if isfield(TRKS_IN.header,'scalar_IDs')
    scalar_count=size(TRKS_IN.header.scalar_IDs,2);
%    warning('Adding scalars to already existing data!');
else
    scalar_count=1;
end



%GZIP FILE CHECK:
for ii=1:size(vol_input_diffmetric,1)
    [ ronii_dirpath{ii}, ronii_filename{ii}, ronii_ext{ii} ] = fileparts(vol_input_diffmetric{ii}.filename{end});
    if strcmp(ronii_ext,'.gz')
       % disp(['Gunzipping...' vol_input_diffmetric{ii}.filename{end} ]);
       system([ 'gunzip -f ' vol_input_diffmetric{ii}.filename{end} ] );
       if strcmp(ronii_dirpath{ii},'')
           ronii_dirpath{ii}='./';
       end
        vol_input_diffmetric{ii}.filename = {[ ronii_dirpath{ii} filesep ronii_filename{ii} ]};
    end
end


for pp=1:size(vol_input_diffmetric,1)
    if size(vol_input_diffmetric,1) ==1 
        H_vol= spm_vol(cell2char(vol_input_diffmetric{pp}.filename));
    else
        H_vol= spm_vol(cell2char(vol_input_diffmetric{pp}.filename));
    end
    V_vol=spm_read_vols(H_vol);
    
    %Updating header fields...
    %TRKS_OUT.header.n_scalars = scalar_count; ~~> Note: updates as scalars
    %wont be in sstr.matrix but instead in sstr.vox_coord!!
    scalar_count=scalar_count+1;
    if size(vol_input_diffmetric,1) == 1
        if isfield(TRKS_IN.header,'scalar_IDs') == 0
            TRKS_OUT.header.scalar_IDs={vol_input_diffmetric{pp}.identifier};
        else
            TRKS_OUT.header.scalar_IDs=[ TRKS_IN.header.scalar_IDs {vol_input_diffmetric{pp}.identifier} ] ;
        end
    else
        if pp==1
            if isfield(TRKS_IN.header,'scalar_IDs') == 0
                TRKS_OUT.header.scalar_IDs={vol_input_diffmetric{pp}.identifier};
            else
                TRKS_OUT.header.scalar_IDs=[ TRKS_IN.header.scalar_IDs {vol_input_diffmetric{pp}.identifier} ] ;
            end
        else
            TRKS_OUT.header.scalar_IDs=[ TRKS_OUT.header.scalar_IDs {vol_input_diffmetric{pp}.identifier} ] ;
        end
    end
    
    if ~isempty(nproj)
        TRKS_OUT.header.scalar_IDs =[ 'proj' num2str(nproj) '_' TRKS_OUT.header.scalar_IDs{end} ];
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
        
        %HERE IS WHERE THE SCALAR MANIPULATION BEGINS
        %The idea is to project and select the highest FA among the
        %perpendicular locations of each voxel based on its previous voxel
        %location. 
        if isempty(nproj) %no perpendicular projectio needed...
            TRKS_OUT.sstr(ii).vox_coord = [TRKS_OUT.sstr(ii).vox_coord, cur_scalar];
        else
            %Replace cur_scalar w/ NaNs
            new_scalar=nan(size(cur_scalar,1),1);
            clear bin_flag n_different idx_diffs   ; 
            %!!##(Values are indexed val(x,y,z)-1 but pos it +1ed!) 
            for posidx=1:size(pos,1)
                %Assigning ref_XYZ to use (the preivous voxel will be ref_xyz):
                if posidx ~= 1
                    cur_xyz=pos(posidx,:);
                    ref_xyz=pos(posidx-1,:); %the next position
                else
                    cur_xyz=pos(posidx,:);
                    ref_xyz=pos(posidx+1,:); %the previous position
                end
                
                nscals=[ ]; %The actual voxel will be included in the A dot B scenario (as its denotes as [0 0 0] )
                binflag=(cur_xyz ~= ref_xyz);
                n_different=sum(binflag(:)==1); %denoting number of similar xyzs
                idx_diffs=find(binflag==1);
                
                
                vec_ofinterest=cur_xyz-ref_xyz;
                %Two vector are perpendicular if A dot B = 0!
                %Creating a cube with all possible scenarios
                %a total of 9 scenarios (including the actual voxel)
                pos_vals=[  0 0 0 ; -1 0 0 ; 1 0 0 ; 0 1 0 ; 0 -1 0 ; -1 -1 0 ; 1 1 0 ; -1 1 0 ; 1 -1 0; ... 
                    0 0 1 ; -1 0 1 ; 1 0 1 ; 0 1 1 ; 0 -1 1 ; -1 -1 1 ; 1 1 1 ; -1 1 1 ; 1 -1 1 ; ...
                    0 0 -1 ; -1 0 -1 ; 1 0 -1 ; 0 1 -1 ; 0 -1 -1 ; -1 -1 -1 ; 1 1 -1 ; -1 1 -1 ; 1 -1 -1];
                
                %So check what vectors are perpendicular:
                for idx_posvals=1:size(pos_vals,1) 
                    gg(idx_posvals)= dot(vec_ofinterest,pos_vals(idx_posvals,:));
                    if gg(idx_posvals) == 0
                        pos_vals(idx_posvals,:);
                        for kkk=1:nproj
                            tonproj=kkk-1; % Minus 1 each projection value
                            if pos_vals(idx_posvals,1) < 0
                                xnval=cur_xyz(1)+pos_vals(idx_posvals,1)-tonproj;
                            else
                                xnval=cur_xyz(1)+pos_vals(idx_posvals,1)+tonproj;
                            end
                            if pos_vals(idx_posvals,2) < 0
                                ynval=cur_xyz(2)+pos_vals(idx_posvals,2)-tonproj;
                            else
                                ynval=cur_xyz(2)+pos_vals(idx_posvals,2)+tonproj;
                            end
                            if pos_vals(idx_posvals,3) < 0
                                znval=cur_xyz(3)+pos_vals(idx_posvals,3)-tonproj;
                            else
                                znval=cur_xyz(3)+pos_vals(idx_posvals,3)+tonproj;
                            end
                            
                            if isempty(nscals)
                                nscals = [ V_vol(sub2ind(TRKS_IN.header.dim, xnval, ynval, znval))];
                            else
                                nscals = [ nscals V_vol(sub2ind(TRKS_IN.header.dim, xnval, ynval, znval))];
                            end
                        end
                    end
                end
                TRKS_OUT.sstr(ii).vox_coord(1,:)
           
                new_scalar(posidx) = max(nscals);
            end
            TRKS_OUT.sstr(ii).vox_coord = [TRKS_OUT.sstr(ii).vox_coord, new_scalar];
        end
    end
    
    
    TRKS_OUT.sstr(ii).matrix = TRKS_IN.sstr(ii).matrix;
    TRKS_OUT.sstr(ii).nPoints = TRKS_IN.sstr(ii).nPoints;


    
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



%GZIP FILE CHECK:
for ii=1:size(vol_input_diffmetric,1)
    if strcmp(ronii_ext{ii},'.gz')
        system([ 'gzip -f ' vol_input_diffmetric{ii}.filename{end} ] );
    end
end
