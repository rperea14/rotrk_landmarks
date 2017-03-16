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
    split='';
end

if nargin < 5
    split='no_split';
end

if nargin < 6
    tolerance=2;
end

if nargin < 7
    ROI_for_mid='';
end
%~~~~~~~~~~end of checking variables initialization~~~~~~~~


%CHECKING STRUCTURE TYPE FOR vol_input
if isstruct(vol_input)
    if iscell(vol_input.filename)
        H_vol= spm_vol(cell2char(vol_input.filename));
    else
        H_vol= spm_vol(vol_input.filename);
    end
elseif iscell(vol_input)
    H_vol= spm_vol(cell2char(vol_input));
else
    H_vol= spm_vol(vol_input);
end
V_vol=spm_read_vols(H_vol);
%~~~~~~~~~~end of checking structure type~~~~~~~~


if strcmp(split,'no_split') 
    new_ROI=zeros(size(V_vol));
    center_slice='';
    center_roi='';
else
    disp('split activated. Applying unilateral split...')
    new_ROI_R=zeros(size(V_vol));
    new_ROI_L=zeros(size(V_vol));
    
    %Getting the center of the slice and the center of ROI
    %coordinates
    center_slice=header.dim/2 ;
    if isnumeric(ROI_for_mid) %An x_y_z coordinate system
        center_roi=ROI_for_mid./header.voxel_size;
    else %might be a filename so try applying rotrk_ROImean
        try
            center_roi=rotrk_ROImean(ROI_for_mid)./header.voxel_size;
        catch
            error('Problems with the assigned ROI passed. Please verify');
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%STARTING MAIN IMPLEMENTATION HERE:
for ii = 1:numel(tracts)
    % Translate continuous vertex coordinates into discrete voxel coordinates
    %pos = round(tracts(ii).matrix(:,1:3) ./ repmat(header.voxel_size, tracts(ii).nPoints,1))
    pos = ceil(tracts(ii).matrix(:,1:3) ./ repmat(header.voxel_size, tracts(ii).nPoints,1));
    %disp([ 'in ii: ' num2str(ii)]);
    switch split
        case 'no_split'  %No unilateral split...
            [ ind_bil , ~ , ~ ]  = local_calc_idx(header,pos);
            new_ROI(ind_bil)=1;
            
        case 'splitx'
            
            %AFTER TRYING TO SET A y=mx+b line to check for the midline, I
            %decided to keep the center_slice to do the computation on
            %every single voxel rather that the trats itself. The reason:
            %1. There is no exact centerline (more approx is the
            %center_slice)
            %2. Due to voxel sice the y=mx+b approach is not as  helful as
            %the center_slice
            
            %Calculating index
           % [ ind_L, ind_R ] =local_calc_idx(header,pos,'splitx',center_slice, ...
            %    center_roi, tolerance ) ;
            coeffs=polyfit([center_roi(1) center_slice(1)], [center_roi(2) center_slice(2) ], 1) ; % This will change on splits
            for ii=1:size(pos,1)
                index=sub2ind(header.dim, pos(ii,1), pos(ii,2), pos(ii,3));
                if pos(ii,1) <= center_slice(1) % 
                % if pos(ii,2)-1 <=  coeffs(1)*pos(ii,1)+coeffs(2)
                    new_ROI_L(index)=1;
                else
                    new_ROI_R(index)=1;
                end
            end
            
            
            

%             if ~(any(isnan(ind_L))) ; new_ROI_L(ind_L)=1; end
%             if ~(any(isnan(ind_R))) ; new_ROI_R(ind_R)=1; end
    end
end


%Writing into a file (all of the streamlines, that's why this if statements
%are outside the for loop...
if strcmp(split,'no_split')
    local_write_filename(H_vol,new_ROI,0,roi_name);
else
    if ~isempty(find(new_ROI_L==1, 1)) ;  local_write_filename(H_vol,new_ROI_L, 1, roi_name,'.nii','_L.nii'); end
    if ~isempty(find(new_ROI_R==1, 1)) ;  local_write_filename(H_vol,new_ROI_R, 1,roi_name,'.nii','_R.nii'); end
end
display(' ');

%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



%%!!!!
%%%%%%%%%%%%%%%%%%%%%%LOCAL FUNCTION calc_idx%%%%%%%%%%%%%%%%%%%%%%%%
function [ind_bil_or_L , ind_R ] = local_calc_idx(header,pos,cut_label,center_slice, center_roi,tolerance)
if nargin < 3  %Simple calculation, no need to split it
    ind_bil_or_L = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
    ind_R = '';
    
else
    %init variables
    flag_notR=0;
    flag_notL=0;
    ind_bil_or_L=nan;
    ind_R=nan;
    %Now we have some sort of split
    switch cut_label
        case 'splitx',
            %Create a linear fit between the center_roi and center_slice
            coeffs=polyfit([center_roi(1) center_slice(1)], [center_roi(2) center_slice(2) ], 1) ; % This will change on splits
            
           %Right side check
           if pos(1,2) < coeffs(1)*pos(1,1)+coeffs(2)
               [maxi, idx_max] = max(pos(2:end,1))
               if pos(idx_max,2) > coeffs(1)*pos(idx_max,1)+coeffs(2)
                   flag_notR=1;
               end
               if ~flag_notR
                   ind_R = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
               end
           else pos(1,2) > coeffs(1)*pos(1,1)+coeffs(2)
               [maxi, idx_max] = max(pos(2:end,1))
               if pos(idx_max,2) < coeffs(1)*pos(idx_max,1)+coeffs(2)
                   flag_notL=1;
               end
               if ~flag_notL
                   ind_bil_or_L = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
                   
               end
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
%~~~~~~~~~~~~~~~~~~~~~~END OF FUNCTION
%write_filename~~~~~~~~~~~~~~~~~~~~~~







%%%%%%%%%%%%%%%%%%%%%%%%%%%CODE RECYCLED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%     %Else apply some sort of splitting...
%     %~~> Split value implementation either half of header dim:
%     if isempty(ROI_for_mid) %apply header.dim(cutlabel)/2
%         split_value=header.dim(cut_label)/2;
%     else
%         if isnumeric(ROI_for_mid) %An x_y_z coordinate system
%             mean_ROI_here=ROI_for_mid;
%         else %might be a filename so try applying rotrk_ROImean
%             try
%                 mean_ROI_here=rotrk_ROImean(ROI_for_mid);
%             catch
%                 error('Problems with the assigned ROI passed. Please verify');
%             end
%         end
%         split_value=mean_ROI_here(cut_label)/header.voxel_size(cut_label);
%         
%       %~~> Another POSSIBILITYor calculate a liner fit (y=mx+b) to assigned the mid of
%         %the brain based on the ROI_for_mid
%         %split_value='Toimplement';
%     end
%         
%     %Initializing ind_L/R
%     ind_R=nan;
%     ind_bil_or_L=nan;
%     flag_notR=0;
%     flag_notL=0;
%     
%     %Initial split
%     %check what happens if they start in the same position....
% 
% %###DEBUGGING CODE    
% %     pos(1:5,:)
% %     pos(end-5:end,:)
% %     AA=1
% %##END OF DEBUGGING CODE     
%     
%     if pos(1,cut_label) == split_value % || pos(end,cut_label) == split_value
%         
%          for jj=2:size(pos,1)
%             if ~(pos(jj,cut_label) <= split_value+tolerance)
%                 flag_notR=1;
%             end
%             if ~(pos(jj,cut_label) >= split_value-tolerance)
%                 flag_notL=1;
%             end
%          end
%         %If none go to the other hemisphere, then return a number of idxs
%         if ~flag_notR
%             ind_R= sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
%         end
%         if ~flag_notL
%             ind_L= sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
%         end
%     %-->if initial value (pos(1,...) or final coordinate is beyond the cut_label
%     %hemisphere
%     elseif pos(1,cut_label) < split_value % || pos(end,cut_label) < split_value 
%         for jj=2:size(pos,1)
%             if ~(pos(jj,cut_label) <= split_value+tolerance)
%                 flag_notR=1;
%             end
%         end
%         %If none go to the other hemisphere, then return a number of idxs
%         if ~flag_notR
%             ind_R= sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
%         end
%     elseif pos(1,cut_label) > split_value % || pos(end,cut_label) > split_value ) 
%         for jj=2:size(pos,1)
%             if ~(pos(jj,cut_label) >= split_value-tolerance)
%                 flag_notL=1;
%             end
%         end
%         %If none go to the other hemisphere, then return a number of idxs
%         if ~flag_notL
%             ind_bil_or_L = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
%         end
%         
%     end