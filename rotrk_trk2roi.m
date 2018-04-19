function  rotrk_trk2roi(header, tracts, vol_input,roi_name,opt)
%function  rotrk_trk2roi(header, tracts, vol_input,roi_name,opt)
%  If 3 arguments are passed:
%   IN ->
%     header:       (header) in struct format
%     tracts:       (tracts) in *.trk struct format
%     vol_input:   (volume)  in *.nii format
%     roi_name:     Filename to save (optional. default name: new_ROIROI.nii)
%     opt:          nth column (in number format) that selects the
%                   diffmetric column of interest
%   OUT ->
%     new_ROIROI:  in *.nii format


%%CHECKING VARIABLE INITIALIZING...
if nargin < 4
    roi_name='new_ROI.nii' ;
    warning('No name passed as an input. Using new_ROI.nii as the name output...')
    split='no_split';
end
if nargin < 5
    opt = '';
end
%~~~~~~~~~~end of checking variables initialization~~~~~~~~

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

new_ROI=zeros(size(V_vol));


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
        ind = sub2ind(header.dim, pos(:,1), pos(:,2), pos(:,3));
        
        if isempty(opt)
            new_ROI(ind)=1;
        else
            idx_diffM=NaN;
            for tt=1:numel(header.scalar_IDs)
                if strcmp(header.scalar_IDs{tt},opt)
                    idx_diffM = tt ; 
                    break
                end
            end
            try
                if strcmp('FA',opt)
                    new_ROI(ind)=1000*tracts.vox_coord(:,3+idx_diffM);
                else %sassuming AxD, MD or RD
                    new_ROI(ind)=1000000*tracts.vox_coord(:,3+idx_diffM);
                end
            catch
                error(['No metric: ' opt ' found. Cannot put values on it']);
            end
        end
end
        %Writing into a file (all of the streamlines, that's why this if statements
        %are outside the for loop...
        H_vol.fname = roi_name;
        dir_exist=fileparts(H_vol.fname);
        if ~isempty(dir_exist)
            system([ 'mkdir -p ' fileparts(H_vol.fname) ] );
        end
        clear dir_exist
        spm_write_vol(H_vol,new_ROI);
        display(['The nii: ' H_vol.fname ' was successfully generated ' ]);
        %%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    %GZIP ISSUES:
    if strcmp(roii_ext,'.gz') %for output ROI_NAME
        system(['gzip -f ' roi_name ] );
    end
    if strcmp(ronii_ext,'.gz') %for input VOL_INPUT
        system([ 'gzip -f ' vol_input ] );
    end
    