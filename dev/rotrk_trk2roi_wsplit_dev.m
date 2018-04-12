function  rotrk_trk2roi(header, tracts, vol_input,roi_name,split,tolerance, ROI_for_mid )
%function  rotrk_trk2roi(header, tracts, vol_input,roi_name,split,tolerance, ROI_for_mid )
% Reads in a tract (in *.trk NOT *.trk.gz!) and exports an ROI in NIFTII
% format
%
%   Dependencies:
%                   trk_read
%  If 3 arguments are passed:
%   IN ->
%     header:       (header) in struct format
%     tracts:       (tracts) in *.trk struct format
%     vol_input:   (volume)  in *.nii format NOT *.nii.gz!
%     roi_name:     Filename to save (optional. default name: new_ROIROI.nii)
%     split:        *optional: if 'splitx'
%                              then it will look at the 'end' and 'beg'
%                              coordinates in x-pos and split it if it goes
%                              beyond:
%                                       x-coord +- <tolerance>  or
%                                       mx+b (if ROI_for_mid is passed)
%                    unilateral
%                   If any coordiante goes beyond
%     tolerance:    *optional for splitx: tolerance on how to do splitting
%                    (Default: +-2 points in the coordinate system)
%     ROI_for_mid   *optional for splitx: if passed, it will calculate the
%                   mean value of the specific ROI_for mid
%
%                   *Also, for future implementation: a mid region equating
%                   'y=mx+b' using center from header.dim and center
%                    from ROI_for_mid
%
%  If 2 arguments are passed:
%     header:   (*.trk) file
%     tracts:   (volume) in nii format

%   OUT ->
%     new_ROIROI:  in *.nii format


%%CHECKING VARIABLE INITIALIZING...
if nargin < 4
    roi_name='new_ROI.nii' ;
    warning('No name passed as an input. Using new_ROI.nii as the name output...')
    split='no_split';
end

if nargin < 5
    split='no_split';
end

if nargin < 6
    tolerance=2;
    split='no_split';
end

if nargin < 7
    if ~(strcmp(split,'no_split'))
        ROI_for_mid='';
        warning('No ROI for midpoint passed. Using mid_slice...');
    end
end
%~~~~~~~~~~end of checking variables initialization~~~~~~~~

%IS IT GZIPPED??
%VOL_INPUT NII:
[ ronii_dirpath, ronii_filename, ronii_ext ] = fileparts(vol_input);
if strcmp(ronii_ext,'.gz')
    disp(['Gunzipping...' vol_input ]);
    system([ 'gunzip ' vol_input ] );
    vol_input = [ ronii_dirpath filesep ronii_filename ];
end

%ROI_NAME:
[ roii_folder, roii_name, roii_ext ] = fileparts(roi_name);
if strcmp(roii_ext,'.gz')
    if isempty(roii_folder)
        roi_name = [ '.' filesep roii_name ] ;
    else
        roi_name = [ roii_folder filesep roii_name ] ;
    end
end


%CHECKING STRUCTURE TYPE FOR vol_input
if isstruct(vol_input)
    if iscell(vol_input.filename)
        H_vol= spm_vol(cell2char_rdp(vol_input.filename));
    else
        H_vol= spm_vol(vol_input.filename);
    end
elseif iscell(vol_input)
    H_vol= spm_vol(cell2char_rdp(vol_input));
else
    H_vol= spm_vol(vol_input);
end
V_vol=spm_read_vols(H_vol);
%~~~~~~~~~~end of checking structure type~~~~~~~~


if strcmp(split,'no_split')
    new_ROI=zeros(size(V_vol));
else
    disp('split activated. Applying unilateral split...')
    new_ROI_R=zeros(size(V_vol));
    new_ROI_L=zeros(size(V_vol));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%STARTING MAIN IMPLEMENTATION HERE:
for ii = 1:numel(tracts)
    % Translate continuous vertex coordinates into discrete voxel coordinates
    pos=tracts(ii).vox_coord;
    pos=pos+1;
    %DUE TO INDEXING ISSUES STARTING AT 1 or 0...
    %Same replacing but for extreme values (based of header.dim(x/y/z)
    extreme_x=find(pos(:,1)>header.dim(1)) ; for gg=1:numel(extreme_x); pos(extreme_x(gg),1)=header.dim(1) ; end
    extreme_y=find(pos(:,2)>header.dim(2)) ; for gg=1:numel(extreme_y); pos(extreme_y(gg),2)=header.dim(2) ; end
    extreme_z=find(pos(:,3)>header.dim(3)) ; for gg=1:numel(extreme_z); pos(extreme_z(gg),3)=header.dim(3) ; end
    %disp([ 'in ii: ' num2str(ii)]);
    switch split
        case 'no_split'  %No unilateral split...
            [ ind_bil , ~ , ~ ]  = local_calc_idx(header,pos);
            new_ROI(ind_bil)=1;
            
        case 'splitx'
            %NOT WORKING as there are issues with the misaligments of the
            %diffusion images in native space and the L/R lateralization is
            %unclear. As an alternative, we masked out dilated WM_L/R masks
            %coming from FreeSurfer previously aligned to dwi space
            error('DO NOT USE THIS TO SPLIT THE NIIS AS PREVIOUS IMPLEMENTATION WAS ERRONEUOS!')
            
            
            %             cut_label=1; % 1 for x-axis, 2 for y-axis, 3 for z-axis
            %             %Calculating index
            %             [ ind_L, ind_R, ~ ] =local_calc_idx(header,pos,cut_label, tolerance, ...
            %                 ROI_for_mid); % 1 signifies 'x-coordinate'
            %
            %             if ~(any(isnan(ind_L))) ; new_ROI_L(ind_L)=1; end
            %             if ~(any(isnan(ind_R))) ; new_ROI_R(ind_R)=1; end
    end
end


%Writing into a file (all of the streamlines, that's why this if statements
%are outside the for loop...
if strcmp(split,'no_split')
    local_write_filename(H_vol,new_ROI,0,roi_name);
else
    if ~isempty(find(new_ROI_L==1)) ;  local_write_filename(H_vol,new_ROI_L, 1, roi_name,'.nii','_L.nii'); end
    if ~isempty(find(new_ROI_R==1)) ;  local_write_filename(H_vol,new_ROI_R, 1,roi_name,'.nii','_R.nii'); end
end
display(' ');



%GZIP ISSUES:
if strcmp(roii_ext,'.gz')
    system(['gzip -f ' roi_name ] )
end
if strcmp(ronii_ext,'.gz')
    system([ 'gzip -f ' vol_input ] );
end


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



%%!!!!
%%%%%%%%%%%%%%%%%%%%%%LOCAL FUNCTION calc_idx%%%%%%%%%%%%%%%%%%%%%%%%
function [ind_bil_or_L , ind_R, split_value ] = local_calc_idx(header,pos,cut_label,tolerance,ROI_for_mid)
if nargin < 3  %Simple calculation, no need to split it
    ind_bil_or_L = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
    ind_R = '';
    split_value='';
else    %Else apply some sort of splitting...
    %~~> Split value implementation either half of header dim:
    if isempty(ROI_for_mid) %apply header.dim(cutlabel)/2
        split_value=header.dim(cut_label)/2;
    else
        if isnumeric(ROI_for_mid) %An x_y_z coordinate system
            mean_ROI_here=ROI_for_mid;
        else %might be a filename so try applying rotrk_ROImean
            try
                mean_ROI_here=rotrk_ROImean(ROI_for_mid);
            catch
                error('Problems with the assigned ROI passed. Please verify');
            end
        end
        split_value=mean_ROI_here(cut_label)/header.voxel_size(cut_label);
        split_slice=header.dim(cut_label)/2;
        %~~> Another POSSIBILITYor calculate a liner fit (y=mx+b) to assigned the mid of
        %CHECK other rotrk_trk2roi and poly functions
        %the brain based on the ROI_for_mid
        %split_value='Toimplement';
    end
    
    %Initializing ind_L/R
    ind_R=nan;
    ind_bil_or_L=nan;
    flag_notR=0;
    flag_notL=0;
    
    for jj=2:size(pos,1)
        if pos(jj,cut_label)-tolerance > split_value(cut_label)%split_slice(cut_label)
            flag_notR=1;
        end
    end
    if ~flag_notR
        ind_R= sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
    else
        for jj=2:size(pos,1)
            if pos(jj,cut_label)+tolerance < split_value(cut_label) %split_slice(cut_label)
                flag_notL=1;
            end
        end
        if ~flag_notL
            ind_bil_or_L = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
        end
    end
end
%~~~~~~~~~~~~~~~~~~~~~END OF FUNCTION calc_idx~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%%%%%%%%%%%%%%%%%%%%%%LOCAL FUNCTION write_filename%%%%%%%%%%%%%%%%%%%%%%%%
function local_write_filename(H_vol,newROI_vol,is_split, roi_name,old_str,replaced_with)
if ~is_split
    H_vol.fname = roi_name;  %new_ROIROIname;
else
    H_vol.fname = strrep(roi_name,old_str,replaced_with);  %new_ROIROIname;
end



try
    system([ 'mkdir -p ' fileparts(H_vol.fname) ] );
    spm_write_vol(H_vol,newROI_vol);
    display(['The nii: ' H_vol.fname ' was successfully generated ' ]);
catch
    error('Cannot save the file. *Make sure *.nii is added as the roi_name! Is SPM installed?')
end
%~~~~~~~~~~~~~~~~~~~~~~END OF LOCAL FUNCTION
%write_filename~~~~~~~~~~~~~~~~~~~~~~