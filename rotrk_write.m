function rotrk_write(header,tracks,savePath)
%function rotrk_write(header,tracks,savePath)
% Inputs:
%    header   - Header information for .trk file [struc]
%    tracks   - Track data struc array [1 x nTracks]
%    savePath - Path where .trk file will be saved [char]
%
% Output files:
%    Saves .trk file to disk at location given by 'savePath'.

%First check that tracks.sstr is not empty. If so, just send a warning:
if numel(tracks) <= 1 
    if numel(tracks) == 0 
        warning('In trk_write(): Refusing to write a trk_file since header.sstr is empty')
        return
    end
    %Since it could be a centerline, we need to check if its empty, se we
    %added another if statement...
    if isempty(tracks.matrix)
        warning('In trk_write(): Refusing to write a trk_file since header.sstr is empty')
        return
    end
end
[ cur_folder, cur_name, cur_ext ] = fileparts(savePath);
if strcmp(cur_ext,'.gz')
    if isempty(cur_folder)
        savePath = [ '.' filesep cur_name ] ;
    else
        savePath = [ cur_folder filesep cur_name ] ;
    end
end
%CHECKI DIRECTIONALITY FOR ORIENTATION
%Now, we will always write withouth inversion happening so...

%THE FOLLOWING LINES HAVE BEEN COMMENTED AS EVERYTHING SHOULD BE TAKEN CARE
%WHEN READING THE TRKS (AND NOT WRITING). THE WRITING TRK AND TRK2NII
%SHOULD BE CARRIED AWAT BY THE ROTRK_READ.m FUNCTION AND THE ORIENTATION OF THE *.nii MATRIX!!
%
%INVERT_X
xflag=0;
if header.invert_x == 1
    header.invert_x = 0;
    xflag=1; %This will allow us to change the orientation in the .tracts or .sstr values
    if strcmp(header.pad2(1),'L')
        header.pad2(1)='R';
    elseif strcmp(header.pad2(1),'R')
        header.pad2(1)='L';
    else
        header.pad2(1)='?';
    end
    if strcmp(header.voxel_order(1),'L')
        header.voxel_order(1)='R';
    elseif strcmp(header.voxel_order(1),'R')
        header.voxel_order(1)='L';
    else
        header.voxel_order(1)='?';
    end    
end

%INVERT_Y
yflag=0;
if header.invert_y == 1
    header.invert_y = 0;
    yflag=1; %This will allow us to change the orientation in the .tracts or .sstr values
    if strcmp(header.pad2(2),'P')
        header.pad2(1)='A';
    elseif strcmp(header.pad2(2),'A')
        header.pad2(2)='P';
    else
        header.pad2(2)='?';
    end
    if strcmp(header.voxel_order(2),'P')
        header.voxel_order(2)='A';
    elseif strcmp(header.voxel_order(2),'A')
        header.voxel_order(2)='P';
    else
        header.voxel_order(2)='?';
    end    
end


%INVERT_z
zflag=0;
if header.invert_z == 1
    header.invert_z = 0;
    zflag=1; %This will allow us to change the orientation in the .tracts or .sstr values
    if strcmp(header.pad2(3),'S')
        header.pad2(3)='I';
    elseif strcmp(header.pad2(3),'I')
        header.pad2(3)='S';
    else
        header.pad2(3)='?';
    end
    if strcmp(header.voxel_order(3),'S')
        header.voxel_order(3)='I';
    elseif strcmp(header.voxel_order(3),'I')
        header.voxel_order(3)='S';
    else
        header.voxel_order(3)='?';
    end    
end



%WRITING HEADER INFORMATION:
fid = fopen(savePath, 'w');
% Write header
fwrite(fid, header.id_string, '*char');
fwrite(fid, header.dim, 'short');
fwrite(fid, header.voxel_size, 'float');
fwrite(fid, header.origin, 'float');
fwrite(fid, header.n_scalars , 'short');
fwrite(fid, header.scalar_name', '*char');
fwrite(fid, header.n_properties, 'short');
fwrite(fid, header.property_name', '*char');
fwrite(fid, header.vox_to_ras', 'float');
fwrite(fid, header.reserved, '*char');
fwrite(fid, header.voxel_order, '*char');
fwrite(fid, header.pad2, '*char');
fwrite(fid, header.image_orientation_patient, 'float');
fwrite(fid, header.pad1, '*char');
fwrite(fid, header.invert_x, 'uchar');
fwrite(fid, header.invert_y, 'uchar');
fwrite(fid, header.invert_z, 'uchar');
fwrite(fid, header.swap_xy, 'uchar');
fwrite(fid, header.swap_yz, 'uchar');
fwrite(fid, header.swap_zx, 'uchar');
fwrite(fid, header.n_count, 'int');
fwrite(fid, header.version, 'int');
fwrite(fid, header.hdr_size, 'int');



%Check orientation values...
ix=1;
iy=2;
iz=3;


% Write body
for iTrk = 1:header.n_count
    % Modify orientation back to LPS for display in TrackVis
    header.dim        = header.dim([ix iy iz]);
    header.voxel_size = header.voxel_size([ix iy iz]);
    coords = tracks(iTrk).matrix(:,1:3);
    coords = coords(:,[ix iy iz]);
    if xflag == 1
        coords(:,ix) = header.dim(ix)*header.voxel_size(ix) - coords(:,ix);
    end
    if yflag == 1
        coords(:,iy) = header.dim(iy)*header.voxel_size(iy) - coords(:,iy);
    end
    if zflag == 1
        coords(:,iz) = header.dim(iz)*header.voxel_size(iz) - coords(:,iz);
    end
    
    tracks(iTrk).matrix(:,1:3) = coords;
    
    fwrite(fid, tracks(iTrk).nPoints, 'int');
    fwrite(fid, tracks(iTrk).matrix', 'float');
    %REmove as the tracks.props field will never exist!
    %    if header.n_properties
    %       fwrite(fid, tracks(iTrk).props, 'float');
    %  end
end
fclose(fid);
if strcmp(cur_ext,'.gz')
    system(['gzip -f ' savePath ]);
end
