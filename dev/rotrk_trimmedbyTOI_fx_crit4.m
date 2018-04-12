function [ TRKS_OUT ] = rotrk_trimmedbyROI_fx_crit4(TRKS_IN, ROIS_IN, WHAT_TOI, ID)
%function [ TRKS_OUT ] = rotrk_trimmedbyROI_fx_crit4(TRKS_IN, ROIS_IN, WHAT_TOI, ID)

%Created by Rodrigo Perea
%This scripts will apply the separation between stria terminalis and fornix
%in our TRKLAND algorithm called the CRITERIA 4 FOR TRKLAND 
%How is this done? 
% 1. First, we will remove those streamlines that have less than
%    [MODE-=STD] number of coordinate points.
% 2. 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FIRST STEP:
temp_trks_out=TRKS_IN;
%do we have enough coordinate points to apply C4?

if numel(TRKS_IN.sstr) > 10
    %Selecting the number of coordinates per streamline
    for ijk=1:numel(temp_trks_out.sstr)
        if ~isempty(temp_trks_out.sstr(ijk).matrix)
            n_coords(ijk,:) = [ijk size(temp_trks_out.sstr(ijk).matrix,1) ] ;
        else
            n_coords(ijk,:) = [ijk 0 ];
        end
    end
    
    %Removing empty cells, finding the MODE and STD of the data
    ref_n_coords=n_coords(find(n_coords(:,2)~=0),:);
    mode_crit4 = mode(ref_n_coords(:,2));
    std_crit4  = std(ref_n_coords(:,2));
    
    %IDX to repopulate streamlines
    cc=1;
    %Loop at select those sstr MODE+-STD if there are > 10 streamlines
    
    for ijk=1:numel(ref_n_coords(:,2))
        if ref_n_coords(ijk,2) > mode_crit4-std_crit4-10 && ref_n_coords(ijk,2) < mode_crit4+std_crit4+10
            temp_trks_out_crit4.sstr(cc)=temp_trks_out.sstr(ref_n_coords(ijk,1));
            temp_trks_out_crit4.sstr(cc).nPoints=size(temp_trks_out.sstr(ref_n_coords(ijk,1)).matrix,1);
            cc=cc+1;
        end
    end
else
    temp_trks_out_crit4=TRKS_IN; %Nothing to do, not that many fibers. 
end
%Header info:
temp_trks_out_crit4.header=TRKS_IN.header;
temp_trks_out_crit4.header.ncount = size(temp_trks_out_crit4.sstr,2);
clear cc;


%STEP TWO: SELECTING THE MOST EXTREME X:

%Looping to get the closer to the extreme_x region.
%*Note: This will happen in 10th percentile of the coordinates closer to
%       the end of the body of the fornix
for ijk=1:numel(temp_trks_out_crit4.sstr)
    %%display(num2str(ijk));
    if ~isempty(temp_trks_out_crit4.sstr(ijk).matrix)
        crit4(ijk).sstr = temp_trks_out_crit4.sstr(ijk).matrix(end-round(0.05*numel(temp_trks_out_crit4.sstr(ijk).matrix)):end,:);
        crit4(ijk).max_z = max(crit4(ijk).sstr(:,3)); % THIS WONT BE NEEDE FOR NOW.
        if strcmp(WHAT_TOI,'fx_rh')
            crit4(ijk).extreme_x = max(temp_trks_out_crit4.header.dim(1)*temp_trks_out_crit4.header.voxel_size(1)-crit4(ijk).sstr(end,1));
        else
            crit4(ijk).extreme_x = min(crit4(ijk).sstr(:,1));
        end
    else
        crit4(ijk).sstr = [];
        crit4(ijk).max_z = [];
        crit4(ijk).extreme_x = [];
    end
end
%Now we will 1.Make a single array, 2. incorporate NaNs to empty values and 3. make all values double for consistency
for ijk=1:numel(crit4)
    %display(num2str(ijk))
    if ~isempty(crit4(ijk).sstr)
        c4_extreme(ijk,:) = double(crit4(ijk).extreme_x) ;
        c4_size_nsstrs(ijk,:)=double(size(crit4(ijk).sstr,1));
    else
        c4_extreme(ijk,:) = NaN  ;
        c4_size_nsstrs(ijk,:)= NaN;
    end
end

%Selec the indx of the extreme streamline

[~, C4_sstr_idx ] = max(c4_extreme); %left vs. side hemisphere was taken care when selecting the extreme (earlier in the code)
C4_ninterp=round(nanmean(c4_size_nsstrs)); %this will give us the value for interpolation



%STEP THREE: PERFORM STATISTICAL TEST TO SELECT STREAMLINES OF INTEREST
for ijk=1:numel(crit4)
    if ~isempty(crit4(ijk).sstr)
        c4_hdorff(ijk,:) = [ ijk rotrk_get_distance_HDorff(crit4(C4_sstr_idx).sstr,crit4(ijk).sstr) ];
    else
        c4_hdorff(ijk,:) = [ ijk 1000 ]; %All these should be cancel out value of 1000 is an unreal distance
    end
end

%HDorff Normality test
test_c4=sortrows(c4_hdorff,2);
%Include all values that distance is not 1000:
test_c4=test_c4(find(test_c4(:,2)~=1000),:);

if size(test_c4,1) > 10
    h = lillietest(test_c4(:,2),'alpha',0.05);
    while h==1
        %If I never yield a normal distribution (of HDistance)
        %and I keep removing data points, then
        %most likely the fiber populations that
        %we want already exist. We will quit
        %this while loop and remove those that
        %are > 2*std from the mean.
        test_c4=test_c4(1:end-1,:);
        h = lillietest(test_c4(:,2),'alpha',0.05);
        if size(test_c4,1) < 6
            display('ending with less than 5 streamlines when applying TRKLAND_fx');
            h=0;
        end
    end
end
%FOUR:
%Replaces those trimmed tracts with the respective ones in the
%test_c4(:,1) index.

%Make sure we clear the trks_out.sstr field
clear trks_out.sstr 
%Populate trks_out.sstr based on my previous work...
for ijk=1:size(test_c4,1)
    %TODEBUG display(num2str(ijk))
    trks_out.sstr(ijk).matrix=temp_trks_out_crit4.sstr(test_c4(ijk,1)).matrix;
    trks_out.sstr(ijk).vox_coord=temp_trks_out_crit4.sstr(test_c4(ijk,1)).vox_coord;
    trks_out.sstr(ijk).nPoints=temp_trks_out_crit4.sstr(test_c4(ijk,1)).nPoints;
end

%ADDDED TRKS_OUT header information:
trks_out.header = TRKS_IN.header;
trks_out.header.n_count=size(trks_out.sstr,2);

%MOVE OUTPUT TO GLOBAL OUTPUT
TRKS_OUT = trks_out;


end





