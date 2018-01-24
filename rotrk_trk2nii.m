function  rotrk_trk2nii(TRKS_IN, vol_input,nii_name,metric)
%function  rotrk_trk2nii(TRKS_IN, vol_input,nii_name,metric)
%  Created by Rodrigo Perea
%  If 3 arguments are passed:
%   IN ->
%     TRKS_IN:     TRKS_IN trks in TRKS.sstr TRKS.header format (or
%                  filename)
%     vol_input:   (volume)  in *.nii format
%     nii_name:     Filename to save (optional. default name: new_ROI.nii)
%     metric:       (Optional) Metric value to get values from (e.g. 'FA')
%                   If not used, masking will be applied.
%   OUT ->
%     new_ROIROI:  in *.nii format
%


%Check whether TRKS_IN is a filename:
%If so, use rotrk_read to read it...
if ischar(TRKS_IN)
    TRKS_IN_fname=TRKS_IN; %move TRKS_IN to a filename instead
    TRKS_IN=rotrk_read(TRKS_IN_fname,'no_identifier',vol_input); %replace TRKS_IN with the specific format used.
end

%TRKS_IN into .header and .tracts
header=TRKS_IN.header;
tracts=TRKS_IN.sstr;

%%CHECKING VARIABLE INITIALIZING...
for check_varinit=1:1
    if nargin < 3 || isempty(nii_name)
        nii_name='new_ROI.nii' ;
        warning('No name passed as an input. Using new_ROI.nii as the name output...')
    end
    if nargin < 4
        metric = '';
    end
 
end
%~~~~~~~~~~end of checking variables initialization~~~~~~~~

%CHECKING  GZIP ROI_NAME or VOL_INPUT...
for checkinggzip=1:1
    %IS IT GZIPPED??
    %VOL_INPUT NII:
    if isstruct(vol_input)
        [ ronii_dirpath, ronii_filename, ronii_ext ] = fileparts(vol_input.filename{end});
    else
        [ ronii_dirpath, ronii_filename, ronii_ext ] = fileparts(vol_input);
    end
    if strcmp(ronii_ext,'.gz')
        disp(['Gunzipping...' vol_input ]);
        system([ 'gunzip ' vol_input ] );
        if isempty(ronii_dirpath)
            ronii_dirpath = [ '.' filesep ronii_dirpath ] ;
        end
        vol_input = [ ronii_dirpath filesep ronii_filename ];
    end
    
    %ROI_NAME:
    [ roii_folder, roii_name, roii_ext ] = fileparts(nii_name);
    if strcmp(roii_ext,'.gz')
        if isempty(roii_folder)
            nii_name = [ '.' filesep roii_name ] ;
        else
            nii_name = [ roii_folder filesep roii_name ] ;
        end
    end
end


%CHECKING STRUCTURE TYPE FOR vol_input
for check_structype=1:1
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
    new_ROI=zeros(size(V_vol));
end



%RECHECK GZIP ISSUES...
for check_gzip=1:1
    %GZIP ISSUES:
    if strcmp(roii_ext,'.gz') %for output ROI_NAME
        system(['gzip -f ' nii_name ] )
    end
    if strcmp(ronii_ext,'.gz') %for input VOL_INPUT
        system([ 'gzip -f ' vol_input ] );
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%STARTING MAIN IMPLEMENTATION HERE:
for ii = 1:numel(tracts)
    % Translate continuous vertex coordinates into discrete voxel coordinates
    pos=tracts(ii).vox_coord(:,1:3);
    pos=pos+1;
    
%!!!!!!!!!!!!!!!!!!!!!!!!!BEG OF EXCLAMATION!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
%THIS CODE IS UNNECESSARY. ALL THESE SHOULD BE TAKEN CARE IN rotrk_read.
% PLEASE COMMENT IT ALWAYS!
    %Now if inversion is done, then we need to remove the indexing of 0/1
    %to the original term
    %For x:
%     if TRKS_IN.header.invert_x ==1
%         pos(:,1)=pos(:,1)-1;
%     end
%     %For y:
%     if TRKS_IN.header.invert_y ==1
%         pos(:,2)=pos(:,2)-1;
%     end
%     %For z:
%     if TRKS_IN.header.invert_z ==1
%         pos(:,3)=pos(:,3)-1;
%     end
%!!!!!!!!!!!!!!!!!!!!!!!!!END OF EXCLAMATION!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    %DUE TO INDEXING ISSUES STARTING AT 1 or 0...
    %Same replacing but for extreme values (based of header.dim(x/y/z)
    extreme_x=find(pos(:,1)>header.dim(1)) ; for gg=1:numel(extreme_x); pos(extreme_x(gg),1)=header.dim(1) ; end
    extreme_y=find(pos(:,2)>header.dim(2)) ; for gg=1:numel(extreme_y); pos(extreme_y(gg),2)=header.dim(2) ; end
    extreme_z=find(pos(:,3)>header.dim(3)) ; for gg=1:numel(extreme_z); pos(extreme_z(gg),3)=header.dim(3) ; end
    
    %disp([ 'in ii: ' num2str(ii)]);
    ind = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
    
    if isempty(metric)
        new_ROI(ind)=1;
    else
        idx_diffM=NaN;
        for tt=1:numel(header.scalar_IDs)
            if strcmp(header.scalar_IDs{tt},metric)
                idx_diffM = tt ;
                break
            end
        end
%         try
          %~~~~~~THESE LINES AREN'T NEEDED AS NO PROBLEM WITH INTEGER
            %                               VALUES ARE FOUND:   ~~~~~~~~~~~
            %             %Values will change depending on the minimun number of decimals
            %             if flag_decimals == 0
            %                 min_dec = numel(num2str(max(tracts.vox_coord(:,3+idx_diffM))));
            %                 flag_decimals = 1 ;
            %             end
            %             %For FA, min_dec is 6. For AxD, min_dec is 10 so...
            %             if min_dec < 8 %7 or fewer...
            %                 new_ROI(ind)=1000*tracts.vox_coord(:,3+idx_diffM);
            %             else % 10 or more (e.g. sassuming AxD, MD or RD)
            %                 new_ROI(ind)=1000000*tracts.vox_coord(:,3+idx_diffM);
            %             end
            %~~~~~~~~~~END OF COMMENT
            
            %~~>TODEBUG: display(num2str(ii));
            new_ROI(ind)=tracts(ii).vox_coord(:,3+idx_diffM);

            %             if (strcmp('FA',metric) || strcmp('NQA0',metric) ) || (strcmp('proj1_FA',metric) || strcmp('proj1_NQA0',metric) )
            %                 new_ROI(ind)=1000*tracts.vox_coord(:,3+idx_diffM);
            %             else %sassuming AxD, MD or RD
            %                 new_ROI(ind)=1000000*tracts.vox_coord(:,3+idx_diffM);
            %             end
%         catch
%             error(['No metric ' metric ' found. Cannot put values on it']);
%         end
    end
end
%Writing into a file (all of the streamlines, that's why this if statements
%are outside the for loop...
H_vol.fname = nii_name;
dir_exist=fileparts(H_vol.fname);
if ~isempty(dir_exist)
    system([ 'mkdir -p ' fileparts(H_vol.fname) ] );
end
clear dir_exist
spm_write_vol(H_vol,new_ROI);
display(['The nii: ' H_vol.fname ' was successfully generated ' ]);
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if strcmp(roii_ext,'.gz')
   system(['gzip ' H_vol.fname ]);
end
