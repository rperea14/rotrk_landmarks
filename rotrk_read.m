function [tract_out] = rotrk_read(filePath, identifier, vol_data_untyped,specific_name)
%function [header,tracts] = rotrk_read(filePath, identifier, vol_data, specific_name)
%~~%Modified from along_tracts to input 2 arguments ( additional identifier)
%   -Changes made by rdp20 to account for vol_data orientation (not
%   necessarily LPS! )
%   -Changes are denoted by %/~~~ and %~~~~/
%~~
%TRK_READ - Load .trk files
% Syntax: [header,tracks] = trk_read(filePath)
%
% Inputs:
%    filePath - Full path to .trk file or in struc form (filePath.id
%               filePath.filename)
%    identifier - This will get us the filename ID if found
%    vol_data - vol_data with accurate orientation!
%    specific_name - will give you a unique identifier for what
%                     this tract is (e.g. dot_fornix). Default: 'none'
%
% Outputs:
%    tract
%           tract.header - Header information from .trk file [struc]
%           tract.trk_name - (field will pass what specific_name is...)
%           tract.sstr - tract data structure array [1 x ntracts]
%           tract.sstr.nPoints - # of points in each streamline
%           tract.sstr.matrix  - XYZ coordinates (in mm) and associated scalars [nPoints x 3+nScalars]




if nargin < 3, error('Please provide at least 3 arguments as the nii_vol is needed for orientation purposes') ; end

if nargin < 4, specific_name='none' ; end

if ischar(vol_data_untyped)
    vol_data.filename={vol_data_untyped};
else
    vol_data=vol_data_untyped;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make the necessary arguments of 'char' type
if iscell(filePath) ; filePath=cell2char(filePath); end
if iscell(identifier) ; identifier=cell2char(identifier); end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make sure you are not sending gzippoed file. If so, unzip read and rezip
%and the end

%TRKS.trk.gz
[ ro_dirpath, ro_filename, ro_ext ] = fileparts(filePath);
if strcmp(ro_ext,'.gz')
    disp(['Gunzipping...' filePath ]);
    system([ 'gunzip ' filePath] );
    filePath=[ro_dirpath ro_filename ];
end

[ ronii_dirpath, ronii_filename, ronii_ext ] = fileparts(cell2char(vol_data.filename));
%VOLDATA.nii.gz
if strcmp(ronii_ext,'.gz')
    disp(['Gunzipping...' vol_data.filename ]);
    system([ 'gunzip ' cell2char(vol_data.filename) ] );
    vol_data.filename=[ronii_dirpath filesep ronii_filename ];
    ro_filename=vol_data.filename;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Parse in header
fid    = fopen(filePath, 'r');
header = get_header(fid);

header.specific_name = specific_name;
%/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Reading the vol_data orientation to find the same orientation...
if isstruct(vol_data)
    if iscell(vol_data.filename)
        tmp_vol=spm_vol(cell2char(vol_data.filename));
    else
        tmp_vol=spm_vol(vol_data.filename);
    end
    
else
    tmp_vol=spm_vol(vol_data);
end

%Gzip the niftii files now...
if strcmp(ronii_ext,'.gz') ;  system([ 'gzip ' ro_filename  ] ); end



%check if the orientation is the same:
%Having issues with floating points (so 1.8000 not equal to 1.80000001) so
%I'll add a tolerance comparator
tolerance=0.0001;
flag_x=0;flag_y=0; flag_z=0;
warn=0;
if ~(abs(tmp_vol.mat(1,1) - header.vox_to_ras(1,1))) < tolerance
    warn=1;
    %warning('Volume matrix in the x coordinate is not equal to the trk matrix. Flipping to fit same orientation')
    %warning('Double check orientation after using this!')
    %flag_x=-1;
    
end

if ~(abs(tmp_vol.mat(2,2) - header.vox_to_ras(2,2))) < tolerance
    %warning('Volume matrix in the y coordinate is not equal to the trk matrix. Flipping to fit same orientation')
    %warning('Double check orientation after using this!')
    %    flag_y=-1;
    warn=1;
end

if ~(abs(tmp_vol.mat(3,3) - header.vox_to_ras(3,3)) < tolerance)
    warn=1;
    warning('Volume matrix in the z coordinate is not equal to the trk matrix. Flipping to fit same orientation')
    warning('Double check orientation after using this!')
    %    flag_z=-1;
end

if warn==1
    % warning('Volume matrix in the xyz coordinate is not equal to the trk matrix. Flipping to fit same orientation')
    % warning('Double check orientation after using this!')
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/

% Check for byte order
if header.hdr_size~=1000
    fclose(fid);
    fid    = fopen(filePath, 'r', 'b'); % Big endian for old PPCs
    header = get_header(fid);
end

if header.hdr_size~=1000, error('Header length is wrong. Make sure is gunzipped!'), end
%
% % Check orientation
% [tmp ix] = max(abs(header.image_orientation_patient(1:3)));
% [tmp iy] = max(abs(header.image_orientation_patient(4:6)));
% iz = 1:3;
% iz([ix iy]) = [];
ix=1; iy=2; iz=3;

% Fix volume dimensions to match the reported orientation.
header.dim        = header.dim([ix iy iz]);
header.voxel_size = header.voxel_size([ix iy iz]);

% Parse in body
if header.n_count > 0
    max_n_trks = header.n_count;
else
    % Unknown number of tracts; we'll just have to read until we run out.
    max_n_trks = inf;
end

%/~~~~~~~~~~~~~~~~
header.id=identifier;
%~~~~~~~~~~~~~~~~~~/



iTrk = 1;
while iTrk <= max_n_trks
    pts = fread(fid, 1, 'int');
    if feof(fid)
        break;
    end
    tracts(iTrk).nPoints = pts;
    tracts(iTrk).matrix  = fread(fid, [3+header.n_scalars, tracts(iTrk).nPoints], '*float')';
    if header.n_properties
        tracts(iTrk).props = fread(fid, header.n_properties, '*float');
    end
    %/~~~~~~~~~~~~~~~COMMENTED OUT FROM ALONG_TRACTS! NOT SURE IF IT WORKS....
    %     % Modify orientation of tracts (always LPS) to match orientation of volume
    %     coords = tracts(iTrk).matrix(:,1:3);
    %     coords = coords(:,[ix iy iz]);
    %     if header.image_orientation_patient(ix) < 0
    %         coords(:,ix) = header.dim(ix)*header.voxel_size(ix) - coords(:,ix);
    %     end
    %     if header.image_orientation_patient(3+iy) < 0
    %         coords(:,iy) = header.dim(iy)*header.voxel_size(iy) - coords(:,iy);
    %     end
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/
    
    %/~~~~~~~~~~~~~~~~~~~~
    %Code modified to make sure the order is correct!
    coords = tracts(iTrk).matrix(:,1:3);
    
    if flag_x < 0 %Change by reversing all if vol_data differs from tract!
        coords(:,ix) = header.dim(ix)*header.voxel_size(ix) - coords(:,ix);
        %Now changing parameters...
        header.invert_x=1;
        if header.voxel_order(1) == 'L'
            header.voxel_order(1) = 'R';
            header.pad2(1) = 'R';
        else
            header.voxel_order(1) = 'L';
            header.pad2(1) = 'L';
        end
    end
    if flag_y < 0
        coords(:,iy) = header.dim(iy)*header.voxel_size(iy) - coords(:,iy);
        header.invert_z=1;
        if header.voxel_order(3) == 'S'
            header.voxel_order(3) = 'I';
            header.pad2(3) = 'I';
        else
            header.voxel_order(3) = 'S';
            header.pad2(3) = 'S';
        end
    end
    if flag_z < 0
        coords(:,iz) = header.dim(iz)*header.voxel_size(iz) - coords(:,iz);
        header.invert_z=1;
        if header.voxel_order(3) == 'S'
            header.voxel_order(3) = 'I';
            header.pad2(3) = 'I';
        else
            header.voxel_order(3) = 'S';
            header.pad2(3) = 'S';
        end
    end
    %~~~~~~~~~~~~~~~~~~~~/
    
    tracts(iTrk).matrix(:,1:3) = coords;
    iTrk = iTrk + 1;
end


header.pad2=header.voxel_order;
if header.n_count == 0
    header.n_count = length(tracts);
end

fclose(fid);
header.voxel_order=header.voxel_order;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GZIPPING BACK IF NEEDED:
if strcmp(ro_ext,'.gz')
    disp(['gzipping now...' filePath ])
    system(['gzip ' filePath] )
    filePath=[ filePath '.gz' ];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Here we deal with xyz coordinates in MNI voxel system (creating
%tract.sstr.vox_coord ) and removing repeats
tract_out.header=header;
%%These should be of a 'char' type:
tract_out.filename=fullfile(filePath);
tract_out.id=identifier;
if ~strcmp(specific_name,'none')
    tract_out.trk_name=specific_name;
end
for ii=1:size(tracts,2)
    pos=round(tracts(ii).matrix(:,1:3) ./ repmat(header.voxel_size, tracts(ii).nPoints,1));
    %pos=pos+1;
    %CHECKING FOR DUPLICATED:"
    posnew_idx=0;
    
    %WITHOUT REMOVING DUPLICATES:
    tract_out.sstr(ii).matrix(:,1:3)=tracts(ii).matrix(:,1:3);
    tract_out.sstr(ii).vox_coord(:,1:3)=pos(:,1:3);
    
    %REMOVING DUPLICATES:
    %    for hh=1:size(pos,1)
    %Check all subsequent but the last one
    %         if hh~=size(pos,1)
    %             %Check if XYZ are the same coordinates, if so skip the
    %             %coordinate
    %             if ~(pos(hh,1) == pos(hh+1,1) && pos(hh,2) == pos(hh+1,2) && pos(hh,3) == pos(hh+1,3))
    %                 posnew_idx=1+posnew_idx;
    %                 %posnew{ii}(posnew_idx,:)=pos(hh,:);
    %                 tract_out.sstr(ii).matrix(posnew_idx,1:3)=tracts(ii).matrix(hh,1:3);
    %                 tract_out.sstr(ii).vox_coord(posnew_idx,1:3)=pos(hh,1:3);
    %             end
    %         else
    %Copying the last value...(if equal to previous, the
    %            %previous if statment will take care of it)
    posnew_idx=1+posnew_idx;
    %posnew{ii}(posnew_idx,:)=pos(hh,:);
    %           tract_out.sstr(ii).matrix(posnew_idx,1:3)=tracts(ii).matrix(hh,1:3);
    %           tract_out.sstr(ii).vox_coord(posnew_idx,1:3)=pos(hh,1:3);
    %        end
    %end
    % "END CHECKING FOR DUPLICATES
    tract_out.sstr(ii).nPoints=size(tract_out.sstr(ii).matrix,1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%LOCAL FUNCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header = get_header(fid)

header.id_string                 = fread(fid, 6, '*char')';
header.dim                       = fread(fid, 3, 'short')';
header.voxel_size                = fread(fid, 3, 'float')';
header.origin                    = fread(fid, 3, 'float')';
header.n_scalars                 = fread(fid, 1, 'short')';
header.scalar_name               = fread(fid, [20,10], '*char')';
header.n_properties              = fread(fid, 1, 'short')';
header.property_name             = fread(fid, [20,10], '*char')';
header.vox_to_ras                = fread(fid, [4,4], 'float')';
header.reserved                  = fread(fid, 444, '*char');
header.voxel_order               = fread(fid, 4, '*char')';
header.pad2                      = fread(fid, 4, '*char')';
header.image_orientation_patient = fread(fid, 6, 'float')';
header.pad1                      = fread(fid, 2, '*char')';
header.invert_x                  = fread(fid, 1, 'uchar');
header.invert_y                  = fread(fid, 1, 'uchar');
header.invert_z                  = fread(fid, 1, 'uchar');
header.swap_xy                   = fread(fid, 1, 'uchar');
header.swap_yz                   = fread(fid, 1, 'uchar');
header.swap_zx                   = fread(fid, 1, 'uchar');
header.n_count                   = fread(fid, 1, 'int')';
header.version                   = fread(fid, 1, 'int')';
header.hdr_size                  = fread(fid, 1, 'int')';



