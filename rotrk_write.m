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
    if header.invert_x == 1
        coords(:,ix) = header.dim(ix)*header.voxel_size(ix) - coords(:,ix);
    end
    if header.invert_y == 1
        coords(:,iy) = header.dim(iy)*header.voxel_size(iy) - coords(:,iy);
    end
    if header.invert_z == 1
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


