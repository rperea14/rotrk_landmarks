function rotrk_plot(header,tracts,orientation, color_trk, volume,n_slices, color_vol)
%function rotrk_plot(header,tracts,orientation, color_trk, volume,n_slices, color_vol)
%       *Modification given from along_tract trk_plot function...
%
% Syntax: drigo_trk_plot(header,tracts,orientation, color, what_matrix, volume)
%
% Inputs:
%    header         -> .trk file header
%    tracts         -> .trk file strlines
%    orientation    ->  if orientation='xy'     -> XY view (default)
%                       if orientation='yz'     -> YZ view
%                       if orientation='xz'     -> XZ view
%                       if orientation='3d'     -> 3D default 3D viewer
%                       if orientation='-3d'    -> -3D viewer
%                       if orientation='fornix' -> default fornix view
%   color        ->  'rainbow'               -> raibow color per streamline
%                   ->  'r'                     -> red streamlines (blue dot initial)
%                   ->  'b'                     -> blue streamlines (red dot initial)
%    volume  - (optional)   -> Scalar MRI volume to use for slice overlays
%    n_sliced - (to implement!!)  ->  'x' to render only the x slice
%                               'y' to render only the y slice
%                               'z' to render only the z slice (defaults xyz)
%   color_vol - (optional)  ->  'rainbow'   - Color encodes assumed correspondence, so like colors will be
%                                             collapsed together.
%                                'scalar'    - Color encode one of the tract scalars
%                                (default: gray)
% Outputs:
%    The plot :P


% Input argument defaults
if nargin < 3, orientation = 'xy' ; end
if nargin < 4, color_trk = ''; end
if nargin < 5, volume = ''; end
if nargin < 6, n_slices = 'xyz'; end
if nargin < 7, color_vol = 'gray'; end



debug=[];

if ~isstruct(tracts), error('tracts must be in structure form. Try running TRK_RESTRUC first.'), end


%Dealing with Volumes passing arguments
if ~isempty(volume)
    if isstruct(volume)
        H_vol=spm_vol(cell2char_rdp(volume.filename));
        
    elseif iscell(volume)
        H_vol=spm_vol(cell2char_rdp(volume));
    else
        H_vol=spm_vol(volume);
    end
    V_vol=spm_read_vols(H_vol);
end
%Done dealing with volume




% Plot streamlines
hold on

for iTrk = 1:length(tracts)
    matrix = tracts(iTrk).matrix;
    [maxpts, maxidx ]  = max(arrayfun(@(x) size(x.matrix, 1), tracts));
    
    if ~isempty(matrix)
        if strcmp(color_trk,'rainbow')
            cline(matrix(:,1), matrix(:,2), matrix(:,3), (0:(size(matrix, 1)-1))/(maxpts))
        elseif strcmp(color_trk,'myrainbow')
            if size(matrix,2) < 4
                error('Error: diffusion metric not found. Make sure your data has at least a 4th column.');
                error('Exiting...');
                break
            else
                cline(matrix(:,1), matrix(:,2), matrix(:,3), matrix(:,4))
            end
        elseif strcmp(color_trk,'r')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'r')
            if debug, plot3(matrix(:,1), matrix(:,2), matrix(:,3), 'g.'), end
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'b.','markersize',30)
        elseif strcmp(color_trk,'rr')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'r')
            
        elseif strcmp(color_trk,'bb')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'b')
        elseif strcmp(color_trk,'cc')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'c')
            
        elseif strcmp(color_trk,'gg')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'g')
        elseif strcmp(color_trk,'kk')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'k')
            
        elseif strcmp(color_trk,'r.')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'r.')
            if debug, plot3(matrix(:,1), matrix(:,2), matrix(:,3), 'g.'), end
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'r.')
        elseif strcmp(color_trk,'kline')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'k.','markersize',30)
            if debug, plot3(matrix(:,1), matrix(:,2), matrix(:,3), 'g.'), end
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'r.')
            
        elseif strcmp(color_trk,'b')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'b')
            if debug, plot3(matrix(:,1), matrix(:,2), matrix(:,3), 'k.'), end
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'b.')
        elseif strcmp(color_trk,'g')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'g')
            if debug, plot3(matrix(:,1), matrix(:,2), matrix(:,3), 'k.'), end
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'g.')
            
        elseif strcmp(color_trk,'k')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'k')
            if debug, plot3(matrix(:,1), matrix(:,2), matrix(:,3), 'g.'), end
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'k.')
        elseif strcmp(color_trk,'c')
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'c')
            if debug, plot3(matrix(:,1), matrix(:,2), matrix(:,3), 'g.'), end
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'c.')
        elseif strcmp(color_trk,'density')
            len_marker=volume;
            cline(matrix(:,1), matrix(:,2), matrix(:,3),len_marker(1:size(matrix(:,3),1)))
            %   if debug, plot3(matrix(:,1), matrix(:,2), matrix(:,3), 'b.'), end
            %   plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'b.')
        else
            plot3(matrix(:,1), matrix(:,2), matrix(:,3),'b-')
            % plot3(matrix(:,1), matrix(:,2), matrix(:,3),'b.')
            if debug, plot3(matrix(:,1), matrix(:,2), matrix(:,3), 'r.'), end
            plot3(matrix(1,1), matrix(1,2), matrix(1,3), 'r.','markersize',20)
        end
    end
end



xlabel('x'), ylabel('y'), zlabel('z', 'Rotation', 0)
box off
axis image
axis ij
if strcmp(orientation,'xy')
    view(-90,0);
elseif  strcmp(orientation,'yz')
    view(-90,0);
elseif strcmp(orientation,'xz')
    view(0,0)
elseif strcmp(orientation,'-3d')
    view(37.5,-30)
elseif strcmp(orientation,'fornix')
    %view(229,0)
    view(-80,24)
elseif strcmp(orientation,'fornix2')
    view(124,-10)
elseif strcmp(orientation,'fornix3')
    view(180,0)
elseif strcmp(orientation,'fornix4')
    %view(-125,-8)
     view(-107,6)
elseif strcmp(orientation,'cingL')
    %view(229,0)
    view(131,10)
elseif strcmp(orientation,'crus')
    %view(229,0)
    view(-42,39)
elseif strcmp(orientation,'ori1')
    %view(229,0)
    view(120,0)
elseif strcmp(orientation,'ori2')
    %view(229,0)
    view(-180,90)
else
    view(3)
end





% Plot slice overlays
if nargin>2 && ~isempty(volume)
    slices = header.dim/2; %setting slices to the middle of each coordinate
    slices    = (slices - .5).*header.voxel_size; %fit midslices to xyz based on voxel_size
    [x, y, z] = meshgrid(header.voxel_size(1)*(0.5:header.dim(1)),...
        header.voxel_size(2)*(0.5:header.dim(2)),...
        header.voxel_size(3)*(0.5:header.dim(3)));
    h2 = slice(x,y,z,permute(V_vol, [2 1 3]), slices(1), slices(2), slices(3), 'nearest');
    shading flat
    if any(strcmp(color_vol, {'rainbow' 'scalar'}))
        colormap([jet(100);gray(100)])
        %         slice_cdata = get(h2, 'CData');
        %         slice_cdata = cellfun(@(x) x+1, slice_cdata, 'UniformOutput', false);
        %         for iSlice=1:3
        %             set(h2(iSlice), 'CData', slice_cdata{iSlice});
        %         end
        %         caxis([0 2])
    else
        colormap(gray)
    end
    
    
    %Set transparency
    set(h2(1),'Alphadata',get(h2(1),'CData')*250,'Facealpha','flat','AlphaDataMapping','direct')
    set(h2(2),'FaceAlpha',0)
    set(h2(3),'FaceAlpha',0)
    
    %     set(h2(1),'Alphadata',get(h2(1),'CData'),'Facealpha','flat')
    %     set(h2(2),'Alphadata',get(h2(2),'CData'),'Facealpha','flat')
    %     set(h2(3),'Alphadata',get(h2(3),'CData'),'Facealpha','flat')
    
    
    [row1, col1 ] = find(h2(1).CData>0);
    [row2 col2 ] = find(h2(2).CData>0);
    [row3 col3 ] = find(h2(3).CData>0);
    
    %!!This will work for symmetric voxels, CHECK voxel_size(index) for
    %non-symmetric voxels
    %ylim([min(row1)*header.voxel_size(2), max(row1)*header.voxel_size(2)])
    %zlim([min(col2)*header.voxel_size(3), max(col2)*header.voxel_size(3)])
    %xlim([min(col3)*h
    
    
    %Setting xyzlimits based on nonzero values (which are inside the skull)
    
end



%%Removing the axis but keeping other variables..
% hFig=gcf;
% color = get(hFig,'Color');
% set(gca,'XColor',color,'YColor',color,'Zcolor',color,'TickDir','out');

%Removing XYZ units...
% set(gca,'XTickLabelMode','Manual') ; set(gca,'YTickLabelMode','Manual') ; set(gca,'ZTickLabelMode','Manual')
% set(gca,'XTick',[]) ; set(gca,'YTick',[]) ; set(gca,'ZTick',[])


%Reverse x-orientation so it looks like in dsi_studio
set(gca,'xdir','reverse'); shg
