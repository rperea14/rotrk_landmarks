function TRKS_OUT = rotrk_rm_byHDorff(CLINE_IN, TRKS_IN, defparam_TRKS_OUT)
%function TRKS_OUT = rotrk_rm_byHDorff(CLINE_IN, TRKS_IN, defparam_TRKS_OUT)
%   This function will take a TRKS_IN and
%
%       1) Remove streamlines (from TRKS_IN) that are farther away from
%       CLINE_IN [based on a modified Hausdorff Distance (check rotrk_get_distance_HDorff.m) ]
%       until it reaches a normal distribution and,
%
%       2) After 1), it will also remove streamlines that are < 5th or >
%       95th percentile of the HDorff
%
%       Optional: defparam_TRKS_OUT is an optional parameter used to pass
%       TRKS_OUT.header and TRKS_OUT.filename information if needed.

if numel(TRKS_IN.sstr) < 5
    TRKS_OUT=TRKS_IN;
    disp('In rotrk_rm_byHDorff');
    disp([ TRKS_IN.header.id ' and fiber  ' TRKS_IN.header.specific_name ...
        ' have ' num2str(numel(TRKS_IN.sstr)) '. Copying TRKS_IN to TRKS_OUT']);
else
    
    
    %Init header
    TRKS_OUT.header=TRKS_IN.header;
    
    %Copying defparams
    if nargin >2
        TRKS_OUT.header=defparam_TRKS_OUT.header;
        TRKS_OUT.id=defparam_TRKS_OUT.id;
        TRKS_OUT.filename=defparam_TRKS_OUT.filename;
    else
        TRKS_OUT.header=TRKS_IN.header;
        TRKS_OUT.header='noID';
        TRKS_OUT.filename=['./trk_rmbylen_' TRKS_IN.header.id];
    end
    
    %Compute the modified Hausdorff distance
    for ii=1:numel(TRKS_IN.sstr)
        hdorff(ii)=rotrk_get_distance_HDorff(TRKS_IN.sstr(ii).matrix,CLINE_IN.sstr.matrix);
    end
    
    [ sort_hdorff sort_hdorffidx ] =sort(hdorff);
    
    %Test for Normality first!
    h=0;
    if numel(sort_hdorff) > 4
        h = lillietest(sort_hdorff);
        while h==1
            %If I never yield a normal distribution
            %and I keep removing data points, then
            %most likely the fiber populations that
            %we want already exist. We will quit
            %this while loop and remove those that
            %are > 2*std from the mean.
            if numel(sort_hdorff) == 5
                h=0;
                [ sort_hdorff sort_hdorffidx ] =sort(hdorff);
            else
                sort_hdorff=sort_hdorff(1:end-1);
                sort_hdorffidx=sort_hdorffidx(1:end-1);
                h = lillietest(sort_hdorff);
                
                %TODEBUG disp(['numel of points:' num2str(numel(sort_tmp_distance))]);
            end
        end
    end
    
    %Finding the 5th and 95th percentile:
    percntiles=prctile(sort_hdorff, [5 95] );
    
    %For loop to remove  values that are beyond the 5th and 95th percentile
    newidx=1;
    for ii=1:numel(sort_hdorff)
        if sort_hdorff(ii) > percntiles(1) && sort_hdorff(ii) < percntiles(2)
            %Allocating the corresponding values:
            TRKS_OUT.sstr(newidx).matrix=TRKS_IN.sstr(sort_hdorffidx(ii)).matrix;
            TRKS_OUT.sstr(newidx).vox_coord=TRKS_IN.sstr(sort_hdorffidx(ii)).vox_coord;
            TRKS_OUT.sstr(newidx).nPoints=TRKS_IN.sstr(sort_hdorffidx(ii)).nPoints;
            new_sort(newidx)=sort_hdorff(ii);
            new_sortidx(newidx)=sort_hdorffidx(ii);
            newidx=newidx+1;
        end
    end
    TRKS_OUT.header.n_count=numel(TRKS_OUT.sstr);
    
end





