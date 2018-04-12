function TRKS_OUT = rotrk_rm_bylen(TRKS_IN, defparam_TRKS_OUT,flag_rmpercentile)
%function TRKS_OUT = rotrk_rm_bylen(TRKS_IN, defparam_TRKS_OUT)
%   This function will take a TRKS_IN and
%
%       1) Remove streamlines the shorter streamlines until it reaches a
%       normal distribution and,
%
%       2) After 1), it will also remove streamlines that are < 5th or >
%       95th percentile (unless flag_rmpercentile == 1!
%
%       Optional: defparam_TRKS_OUT is an optional parameter used to pass
%       TRKS_OUT.header and TRKS_OUT.filename information if needed.
%
%       *If less than 5 streamlines are found. A simple copy will do with a
%       warning message!

%Init header
TRKS_OUT.header=TRKS_IN.header;

%
if nargin < 3
    flag_rmpercentile=0; %apply percentile cut!
end

%Copying defparams
if nargin >1
    TRKS_OUT.header=defparam_TRKS_OUT.header;
    TRKS_OUT.id=defparam_TRKS_OUT.id;
    TRKS_OUT.filename=defparam_TRKS_OUT.filename;
else
    TRKS_OUT.header=TRKS_IN.header;
    TRKS_OUT.id='noID';
    TRKS_OUT.filename=['./trk_rmbylen_' TRKS_IN.header.id];
end


if numel(TRKS_IN.sstr) < 5
    TRKS_OUT.id=TRKS_IN.id;
    TRKS_OUT.sstr=TRKS_IN.sstr;
    TRKS_OUT.header=TRKS_IN.header;
    disp('In rotrk_rm_bylen');
    disp([ TRKS_IN.header.id ' and fiber  ' TRKS_IN.header.specific_name ...
        ' have ' num2str(numel(TRKS_IN.sstr)) '. Copying TRKS_IN to TRKS_OUT']);
else
    
    for ii=1:numel(TRKS_IN.sstr)
        %len(ii)=pdist2(TRKS_IN.sstr(ii).matrix(1,:),TRKS_IN.sstr(ii).matrix(end,:));
        %len(ii)=pdist2(TRKS_IN.sstr(ii).matrix(1,:),TRKS_IN.sstr(ii).matrix(end,:),'cityblock');
        %len(ii)=size(TRKS_IN.sstr(ii).matrix,1);
        len(ii)=0;
        for jj=1:size(TRKS_IN.sstr(ii).matrix,1)
            if jj~=size(TRKS_IN.sstr(ii).matrix,1)
                len(ii)=len(ii)+pdist2(TRKS_IN.sstr(ii).matrix(jj,:),TRKS_IN.sstr(ii).matrix(jj+1,:));
            end
        end
    end
    
    [ sort_len sort_lenidx ] =sort(len);
    
    %Test for Normality first!
    h=0;
    if numel(sort_len) > 4
        h = lillietest(sort_len);
        while h==1
            %If I never yield a normal distribution
            %and I keep removing data points, then
            %most likely the fiber populations that
            %we want already exist. We will quit
            %this while loop and remove those that
            %are > 2*std from the mean.
            if numel(sort_len) == 5
                h=0;
                [ sort_len sort_lenidx ] =sort(len);
            else
                sort_len=sort_len(2:end);
                sort_lenidx=sort_lenidx(2:end);
                h = lillietest(sort_len);
                
                %TODEBUG disp(['numel of points:' num2str(numel(sort_tmp_distance))]);
            end
        end
    end
    
    %Finding the 5th and 95th percentile:
    percntiles=prctile(sort_len, [5 95] );
    
    %For loop to remove  values that are beyond the 5th and 95th percentile
    newidx=1;
    for ii=1:numel(sort_len)
        if flag_rmpercentile == 1
            %Allocating the corresponding values:
            TRKS_OUT.sstr(newidx).matrix=TRKS_IN.sstr(sort_lenidx(ii)).matrix;
            TRKS_OUT.sstr(newidx).vox_coord=TRKS_IN.sstr(sort_lenidx(ii)).vox_coord;
            TRKS_OUT.sstr(newidx).nPoints=TRKS_IN.sstr(sort_lenidx(ii)).nPoints;
            new_sort(newidx)=sort_len(ii);
            new_sortidx(newidx)=sort_lenidx(ii);
            newidx=newidx+1;
        else
            if sort_len(ii) > percntiles(1) && sort_len(ii) < percntiles(2)
                %Allocating the corresponding values:
                TRKS_OUT.sstr(newidx).matrix=TRKS_IN.sstr(sort_lenidx(ii)).matrix;
                TRKS_OUT.sstr(newidx).vox_coord=TRKS_IN.sstr(sort_lenidx(ii)).vox_coord;
                TRKS_OUT.sstr(newidx).nPoints=TRKS_IN.sstr(sort_lenidx(ii)).nPoints;
                new_sort(newidx)=sort_len(ii);
                new_sortidx(newidx)=sort_lenidx(ii);
                newidx=newidx+1;
            end
        end
    end
    TRKS_OUT.header.n_count=numel(TRKS_OUT.sstr);
    
end

 %Get the volume of non-overlapping XYZ vox_coord values
    all_vox=TRKS_OUT.sstr(1).vox_coord ;        %initializing vox_coord
    for ii=2:size(TRKS_OUT.sstr,2)
        all_vox=vertcat(all_vox,TRKS_OUT.sstr(ii).vox_coord);
    end
    %s_all_vox=sort(all_vox); %sort if bad! I believe it doesn't freeze the Y
    %and Z columns so no good to do this!
    TRKS_OUT.unique_voxels=unique(all_vox,'rows');
    TRKS_OUT.num_uvox=size(TRKS_OUT.unique_voxels,1);
    if isfield(TRKS_IN,'trk_name')
        TRKS_OUT.trk_name=[ 'cleanByLen_' TRKS_IN.trk_name ] ;
    else
        TRKS_OUT.trk_name=[ 'cleanByLen_Notrkname' ] ;
    end




