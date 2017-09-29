function [ TRKS_OUT ] = rotrk_interp(TRKS_IN, number_coordinates)
%function [ TRKS_OUT ] = rotrk_interp(TRKS_IN, number_coordinates)
%IN:
%           TRKS_IN.header      : header file  (header structure format)
%           TRKS_IN.tracts      : tracts file  (trk structure format)
%           number_coordinates : number of points for the spline
%                               interpolation (Default: 40).
%
%           *method:               'mean' or 'high_sc' (Default: mean)
%                                   method for centerline to be used.
%                                   *if high_sc is choosen make sure
%                                   you add the diffmetric as the 7th
%                                   argument!
%           *diffmetric         :if method=high_sc then we need scalars
%                               that can be passed as [ GFA NQA0 ]

%OUT:
%           TRKS_OUT

%%%%%%%%SPLITTING THTE TRACTS_STRUCT FORM INTO TRACTS AND HEADER
if isempty(TRKS_IN.sstr)
    warning('TRKS_IN.sstr is empty. CANNOT interpolate an empty string')
    TRKS_OUT=TRKS_IN;
else
    TRKS_OUT.id=TRKS_IN.id;
    if isfield(TRKS_IN,'filename')
        TRKS_OUT.filename=TRKS_IN.filename;
    end
    if ~isfield(TRKS_IN,'trk_name')
        TRKS_OUT.trk_name='interp_noname';
    else
        TRKS_OUT.trk_name=['interp_' TRKS_IN.trk_name];
    end
    %~~~
    
    
    %Adding scalar name to the streamlines (for reference)
    if nargin < 2
        number_coordinates=40
    end
    
    
    
    nPoints_new=number_coordinates; %Changed to 60 based on the Fornix bundle # of volumes (mean for the n34 was 61).
    spacing=[];
    tie_at_center=[];
    
    %%
    tracts_interp   = zeros(nPoints_new, 3, length(TRKS_IN.sstr));
    pp = repmat({[]},length(TRKS_IN.sstr));
    
    
    %%
    % Interpolate streamlines so that each has the same number of vertices, spread
    % evenly along its length (i.e. vertex spacing will vary between streamlines)
    %parfor iTrk=1:length(TRKS_IN.sstr)
    for iTrk=1:length(TRKS_IN.sstr)
        tracts_tmp = TRKS_IN.sstr(iTrk);
        if size(TRKS_IN.sstr(iTrk).matrix,2) ~= 3
            tracts_tmp=TRKS_IN.sstr(iTrk).matrix(:,1:3);
            warning('tracts.matrix have scalar values. This values might be lost due to interpolation!')
        end
        % Determine streamline segment lengths
        segs = sqrt(sum((tracts_tmp.matrix(2:end,1:3) - tracts_tmp.matrix(1:(end-1),1:3)).^2, 2));
        dist = [0; cumsum(segs)]; %eg. 1 2 3 4 ... <n_numbers of lines-1>
        
        % Remove duplicates
        [dist, I]= unique(dist);
        
        % Fit spline
        pp{iTrk} = spline(dist, tracts_tmp.matrix(I,:)');
        
        % Resample streamline along the spline
        tracts_interp(:,:,iTrk) = ppval(pp{iTrk}, linspace(0, max(dist), nPoints_new))';
    end
    
    % Interpolate streamlines so that the vertices have equal spacing for a central
    % "tie-down" origin. This means streamlines will have varying #s of vertices
    if ~isempty(spacing)
        % Calculate streamline lengths
        lengths = rotrk_length(tracts_interp);
        
        % Determine the mean tract geometry and grab the middle vertex
        track_mean      = mean(tracts_interp, 3);
        middle          = track_mean(round(length(track_mean)/2),:);
        
        % Interpolate streamlines again, but this time sample with constant vertex
        % spacing for all streamlines. This means that the longer streamlines will now
        % have more vertices.
        tracts_interp = repmat(struct('nPoints', 0, 'matrix', [], 'tiePoint', 0), 1, length(TRKS_IN.sstr));
        parfor iTrk=1:length(TRKS_IN.sstr)
            tracts_interp(iTrk).matrix  = ppval(pp{iTrk}, 0:spacing:lengths(iTrk))';
            tracts_interp(iTrk).nPoints = size(tracts_interp(iTrk).matrix, 1);
            
            % Also determine which vertex is the "tie down" point by finding the one
            % closest to the middle point of the mean tract geometry
            dists = sqrt(sum(bsxfun(@minus, tracts_interp(iTrk).matrix, middle).^2,2));
            [tmp, ind] = min(dists);
            tracts_interp(iTrk).tiePoint = ind;
        end
    end
    
    % Streamlines will all have the same # of vertices, but now they will be spread
    % out so that an equal proportion lies on either side of a central origin.
    if ~isempty(nPoints_new) && ~isempty(tie_at_center)
        % Make nPoints_new odd
        nPoints_new_odd = floor(nPoints_new/2)*2+1;
        
        % Calculate streamline lengths
        lengths = rotrk_length(TRKS_IN.sstr);
        
        % Determine the mean tract geometry and grab the middle vertex
        track_mean      = mean(tracts_interp, 3);
        trk_mean_length = rotrk_length(track_mean);
        middle          = track_mean(round(length(track_mean)/2),:);
        
        tracts_interp_tmp = zeros(nPoints_new_odd, 3, length(TRKS_IN.sstr));
        
        parfor iTrk=1:length(TRKS_IN.sstr)
            dists = sqrt(sum(bsxfun(@minus, tracts_interp(:,:,iTrk), middle).^2,2));
            [tmp, ind] = min(dists);
            
            first_half  = ppval(pp{iTrk}, linspace(0, lengths(iTrk)*(ind/nPoints_new), ceil(nPoints_new_odd/2)))';
            second_half = ppval(pp{iTrk}, linspace(lengths(iTrk)*(ind/nPoints_new), lengths(iTrk), ceil(nPoints_new_odd/2)))';
            tracts_interp_tmp(:,:,iTrk) = [first_half; second_half(2:end,:)];
        end
        
        tracts_interp = tracts_interp_tmp;
        
    end
    %%
    %now assigning in a struct form
    tmp_header_interp=TRKS_IN.header;
    tmp_header_interp.scalar_IDs=''; %Null as values will be regiven after interpolation (or must do).
    tmp_header_interp.n_count=size(tracts_interp,3);
    for jj=1:size(tracts_interp,3)
        tmp_tracts_interp(jj).matrix=tracts_interp(:,:,jj);
        tmp_tracts_interp(jj).vox_coord=round(tracts_interp(:,:,jj) ./ repmat(TRKS_IN.header.voxel_size, size(tracts_interp(:,:,jj),1),1 ));
        tmp_tracts_interp(jj).nPoints=size(tracts_interp(:,:,jj),1);
    end
    %~~~~~~~~~~~~~~~~~~~~~~~~DONE WITH SPLINE INTERPOLATION~~~~~~~~~~~~~~~~~~~
    
    
    
    %PUTTING EVERYTING IN THE TRKS_header and TRKS_sstr struct form
    TRKS_OUT.sstr=tmp_tracts_interp;
    TRKS_OUT.header=tmp_header_interp;
    
    
    
    
    %ADDING UNIQUE VOXELS!
    all_vox=TRKS_OUT.sstr(1).vox_coord ;        %initializing vox_coord
    for ii=2:size(TRKS_OUT.sstr,2)
        all_vox=vertcat(all_vox,TRKS_OUT.sstr(ii).vox_coord);
    end
    
    TRKS_OUT.unique_voxels=unique(all_vox,'rows');
    TRKS_OUT.num_uvox=size(TRKS_OUT.unique_voxels,1);
    
    
    %ADDING MAXLEN:
    len=0;
    for ii=1:size(TRKS_OUT.sstr,2)
        cur_len=0;
        for jj=1:(size(TRKS_OUT.sstr(ii).matrix,1)-1)
            cur_len=cur_len+pdist2(TRKS_OUT.sstr(ii).matrix(jj,:),TRKS_OUT.sstr(ii).matrix(jj+1,:));
        end
        sstr_len(ii)=cur_len;
        
        if len < cur_len
            len=cur_len;
        end
    end
    TRKS_OUT.maxsstrlen=len;
    TRKS_OUT.all_sstrlen=sstr_len';
end
