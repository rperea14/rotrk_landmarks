function [ TRKS_OUT ] = rotrk_trimmedbyROI(TRKS_IN, ROIS_IN, WHAT_TOI)
%   function [ TRKS_OUT ] = rotrk_trimmedbyROI(TRKS_IN, ROI_IN, WHAT_TOI)
%   This script will trimmed any *.trk streamline being passed. 
%   IN ->
%           TRKS_IN             : tracts in TRKS format
%           ROI_IN              : the ROI used for trimming references (usually from
%                                  FreeSurfer Segmentations.
%           WHAT_TOI            : 'postcing' or 'fx' or 'to-implement-others;
%           ROI_ORIENTATION     : (mandatory so it works correctly!) 'RAS'
%                                 or 'LPS'
%   OUTPUT:
%           TRKS_OUT    : Trimmed TRK  output

%Created by Rodrigo Perea


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEALING WITH INPUTS:
for tohide=1:1
    if nargin < 3
        error('no enough arguments. Plese re-run! ')
    end
    
    %Dealing with ROI_IN:
    for jj=1:numel(ROIS_IN)
        if ischar(ROIS_IN{jj})
            %roi_in=rotrk_ROIxyz(ROI_IN,WHAT_TOI,ROI_ORIENTATION);
            roi_in{jj}=rotrk_ROIxyz(ROIS_IN{jj},WHAT_TOI);
        else
            display('Not impoemented yet (easy fix!)...')
            error([ 'In: ' mfilename ' ROI_IN has only been implemented to use char types. Please implement otherwise']);
        end
    end
    
    
    %Dealing with TRKS_IN type:
    if isstruct(TRKS_IN)
        trks_in = TRKS_IN;
    else
        display('Not impoemented yet (easy fix!)...')
        error([ 'In: ' mfilename ' TRKS_IN has only been implemented to use struct types. Please implement otherwise']);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%IMPLEMETANTION STARTS HERE
%Preparing values
for jj=1:numel(ROIS_IN)
    %Trk_coord limits (not ideal for flagging as they dont exactly fit!)
    roi_lim{jj} = [ min(roi_in{jj}.trk_coord(:,1)) max(roi_in{jj}.trk_coord(:,1))  ...
        min(roi_in{jj}.trk_coord(:,2)) max(roi_in{jj}.trk_coord(:,2)) ...
        min(roi_in{jj}.trk_coord(:,3)) max(roi_in{jj}.trk_coord(:,3)) ] ;
    
    roi_mean{jj} = [  mean(roi_in{jj}.trk_coord(:,1))  mean(roi_in{jj}.trk_coord(:,2)) mean(roi_in{jj}.trk_coord(:,3)) ] ;
    %Vox_coord limits:
    roi_vlim{jj} = [ min(roi_in{jj}.vox_coord(:,1)) max(roi_in{jj}.vox_coord(:,1))  ...
        min(roi_in{jj}.vox_coord(:,2)) max(roi_in{jj}.vox_coord(:,2)) ...
        min(roi_in{jj}.vox_coord(:,3)) max(roi_in{jj}.vox_coord(:,3)) ] ;
    
    roi_vmidpoint{jj} = [ (roi_vlim{jj}(2)+roi_vlim{jj}(1))/2 (roi_vlim{jj}(4)+roi_vlim{jj}(3))/2 (roi_vlim{jj}(6)+roi_vlim{jj}(5))/2] ;
    
end

%


%Dealing with specific TOIs
switch WHAT_TOI
    case {'fx_lh','fx_rh'}
        for tohide=1:1
            display('Trimming trks based on the hippocampus (for the fornix bundle)');
            %Flip trks to start at the anterior regions:
            tmp_val=[];
            tmpmaxidx = [];
            if strcmp(WHAT_TOI,'fx_lh')
                point_flag = [ roi_vlim{2}(2) roi_vlim{2}(4) roi_vlim{2}(6)];
            else
                point_flag = [ roi_vlim{2}(1) roi_vlim{2}(4) roi_vlim{2}(6)];
            end

            flipped_trks_in = rotrk_flip(trks_in,point_flag,true);  %3rd argument denotes the usage of vox_coord instead of trks.
            % rotrk_flip(trks_in,roi_mean{1});
            %INIT *;sstr fields:
            trks_out.header=flipped_trks_in.header;
            trks_out.header.specific_name=[ 'trimmed_' flipped_trks_in.header.specific_name ] ;
            trks_out.id=flipped_trks_in.id;
            trks_out.sstr=flipped_trks_in.sstr;
            trks_out.trk_name=[ 'trimmed_' flipped_trks_in.trk_name ];
            
            
            %Implementation here:
            for itrk=1:numel(flipped_trks_in.sstr)
                wasdone=0;
                for ixyz=1:size(flipped_trks_in.sstr(itrk).vox_coord,1)
                    %Trimming based on Thalamus (make sure this is the 1st ROI_IN):
                    if flipped_trks_in.sstr(itrk).vox_coord(ixyz,2) < roi_vlim{1}(4) &&  flipped_trks_in.sstr(itrk).vox_coord(ixyz,3) > roi_vmidpoint{1}(3)+2
                        %assignt he trks_out values:
                        trks_out.sstr(itrk).vox_coord(1:ixyz,:)=[];
                        trks_out.sstr(itrk).matrix(1:ixyz,:)=[];
                        %TODEBUG: display(['itrk is: ' num2str(itrk) ' and ixyz is: ' num2str(ixyz)]);
                        break
                    end
                end
                for ixyz=1:size(trks_out.sstr(itrk).vox_coord,1)
                    %Trimming based on hippo midpoint:
                    if trks_out.sstr(itrk).vox_coord(ixyz,3) < roi_vmidpoint{2}(3)
                        %assignt he trks_out values:
                        trks_out.sstr(itrk).vox_coord(ixyz:end,:)=[];
                        trks_out.sstr(itrk).matrix(ixyz:end,:)=[];
                        %TODEBUG: display(['itrk is: ' num2str(itrk) ' and ixyz is: ' num2str(ixyz)]);
                        wasdone=1; %this flag will avoid being inside this if statement twice (ideally, continue will take care of it but not sure if it works appropiately)
                        break
                    end
                end
            end
        end
    case {'postcing_lh', 'postcing_rh'}
        for tohide=1:1
            display('Trimming trks based on the hippocampal cingulum modification');
            %Flip trks to start at the most anterior regions:
            tmp_val=[];
            tmpmaxidx = [];
            %             CODE FOR max_Zline commented because it gives us bad results
            %             max_zstrline=0;
            %             for itrk=1:numel(trks_in.sstr)
            %                 [ tmp_val, tmp_idx ] = max(trks_in.sstr(itrk).matrix(:,3));
            %                 if tmp_val > max_zstrline
            %                     max_zstrline=trks_in.sstr(itrk).matrix(tmp_idx,1:3);
            %                 end
            %             end
            %          flipped_trks_in = rotrk_flip(trks_in,max_zstrline,true);
           
            %Now for the lowest part of hippo
            flipped_trks_in = rotrk_flip(trks_in,[roi_vlim{1}(2) roi_vlim{1}(4) roi_vlim{1}(5)  ],true);
            
            %HEMISPHERE CROSSING CHECK UP!
            %First, remove those streamline that cross the hemisphere (due
            %to contamination with corpus callosum:
            mid_line=flipped_trks_in.header.dim(1)/2;
            flag_hemi=0;
            for itrk=1:numel(flipped_trks_in.sstr)
                if strcmp(WHAT_TOI,'postcing_lh')
                    hemi_flag = max(flipped_trks_in.sstr(itrk).vox_coord(:,1)) ;
                    if hemi_flag > mid_line
                        flipped_trks_in.sstr(itrk).vox_coord=[];
                        flipped_trks_in.sstr(itrk).matrix=[];
                        flag_hemi=1;
                    end
                else
                    hemi_flag = min(flipped_trks_in.sstr(itrk).vox_coord(:,1)) ;
                    if hemi_flag < mid_line
                        flipped_trks_in.sstr(itrk).vox_coord=[];
                        flipped_trks_in.sstr(itrk).matrix=[];
                        flag_hemi=1;
                    end
                end
            end
            if flag_hemi==1; %then reassign a overlapping value from a non-empyt slot
                for itrk=1:numel(flipped_trks_in.sstr)
                    if isempty(flipped_trks_in.sstr(itrk).vox_coord)
                        if itrk ~=1
                            flipped_trks_in.sstr(itrk).vox_coord=flipped_trks_in.sstr(itrk-1).vox_coord;
                            flipped_trks_in.sstr(itrk).matrix=flipped_trks_in.sstr(itrk-1).matrix;
                        else
                            flipped_trks_in.sstr(itrk).vox_coord=flipped_trks_in.sstr(end).vox_coord;
                            flipped_trks_in.sstr(itrk).matrix=flipped_trks_in.sstr(end).matrix;
                        end
                    end
                end
            end
            %INIT *;sstr fields:
            trks_out.header=flipped_trks_in.header;
            trks_out.header.specific_name=[ 'trimmed_' flipped_trks_in.header.specific_name ] ;
            trks_out.id=flipped_trks_in.id;
            trks_out.sstr=flipped_trks_in.sstr;
            trks_out.trk_name=[ 'trimmed_' flipped_trks_in.trk_name ];
            %At this stage, initial XYZ coords should be close to
            %hippocampus. We will remove all those that go below the
            %midpoint of the hippocampus and reach midpoing of posterior
            %cingulate (or the x-axis is the same -  a deviation of
            %anterior-posterior drectionality!
            for itrk=1:numel(flipped_trks_in.sstr)
                hippotrim_done=0;
                %Hippo midpoint now (Hippo ROI is compulsory --> roi{1})...)
                for ixyz=1:size(flipped_trks_in.sstr(itrk).vox_coord,1)
                    %Trimming based on posterior cingulate (make sure this is the 1st ROI_IN):
                    if hippotrim_done~=1 && flipped_trks_in.sstr(itrk).vox_coord(ixyz,3) >  roi_vmidpoint{1}(3)
                        %assignt he trks_out values:
                        trks_out.sstr(itrk).vox_coord(1:ixyz,:)=[];
                        trks_out.sstr(itrk).matrix(1:ixyz,:)=[];
                        hippotrim_done=1;
                    end
                end
                %Now trim by posterior cingulate (midpoint or if trks dont follow an anterior posterior direction:
                for ixyz=1:size(trks_out.sstr(itrk).vox_coord,1)
                    %Trimming based on  hippocampus (2nd ROI_IN):
                    if  hippotrim_done==1 && trks_out.sstr(itrk).vox_coord(ixyz,3) > roi_vlim{2}(5)  && trks_out.sstr(itrk).vox_coord(ixyz,2) > roi_vmidpoint{1}(2)   %...
                        %assignt he trks_out values:
                        trks_out.sstr(itrk).vox_coord(ixyz:end,:)=[];
                        trks_out.sstr(itrk).matrix(ixyz:end,:)=[];
                        break
                    end
                    
                end
            end
        end
    case {'cingulum_lh', 'cingulum_rh'}
        for tohide=1:1
            display('Trimming trks based on the anterior cingulum modification');
            %Flip trks to start at the most anterior regions:
            tmp_val=[];
            tmpmaxidx = [];
            min_ystrline=0;
            for itrk=1:numel(trks_in.sstr)
                [ tmp_val, tmp_idx ] = min(trks_in.sstr(itrk).matrix(:,2));
                if tmp_val < min_ystrline
                    min_ystrline=trks_in.sstr(itrk).matrix(tmp_idx,1:3);
                end
            end
            flipped_trks_in = rotrk_flip(trks_in,min_ystrline,true);
            %INIT *;sstr fields:
            trks_out.header=flipped_trks_in.header;
            trks_out.header.specific_name=[ 'trimmed_' flipped_trks_in.header.specific_name ] ;
            trks_out.id=flipped_trks_in.id;
            trks_out.sstr=flipped_trks_in.sstr;
            trks_out.trk_name=[ 'trimmed_' flipped_trks_in.trk_name ];
            
            for itrk=1:numel(flipped_trks_in.sstr)
                postcingtrim_done=0;
                %Posterior Cingulate  midpoint now (PostCing ROI is compulsory --> roi{1})...)
                for ixyz=1:size(flipped_trks_in.sstr(itrk).vox_coord,1)
                    %Trimming based on posterior cingulate (make sure this is the 1st ROI_IN):
                    if postcingtrim_done~=1 && flipped_trks_in.sstr(itrk).vox_coord(ixyz,2) >  roi_vmidpoint{1}(2) && flipped_trks_in.sstr(itrk).vox_coord(ixyz,3) >  roi_vlim{1}(5)
                        %assignt he trks_out values:
                        trks_out.sstr(itrk).vox_coord(1:ixyz,:)=[];
                        trks_out.sstr(itrk).matrix(1:ixyz,:)=[];
                        postcingtrim_done=1;
                    end
                end
                %Now trim by anterior cingulate (most anterior or if trks dont
                %follow an anterior posterior direction
                for ixyz=1:size(trks_out.sstr(itrk).vox_coord,1)
                    %Trimming based on  hippocampus (2nd ROI_IN):
                    if  postcingtrim_done==1 && trks_out.sstr(itrk).vox_coord(ixyz,2) > roi_vmidpoint{2}(2)   %...
                        %assignt he trks_out values:
                        trks_out.sstr(itrk).vox_coord(ixyz:end,:)=[];
                        trks_out.sstr(itrk).matrix(ixyz:end,:)=[];
                        break
                    end
                    
                end
            end
        end
    otherwise
        error(['WHAT_TOI argument: ' WHAT_TOI ' in ' mfilename ' is not implemented. Either check input or implement!' ]);

end

%OTHER IMPLEMENTATION EQUAL FOR EVERYN TOI:
%Removing empty fields if exist
for itrk=1:numel(trks_out.sstr)
    if isempty(trks_out.sstr(itrk).vox_coord)
        if itrk ~=1
            trks_out.sstr(itrk).vox_coord=trks_out.sstr(itrk-1).vox_coord;
            trks_out.sstr(itrk).matrix=trks_out.sstr(itrk-1).matrix;
        else
            trks_out.sstr(itrk).vox_coord=trks_out.sstr(end).vox_coord;
            trks_out.sstr(itrk).matrix=trks_out.sstr(end).matrix;
        end
    end
end


%Input the nPoints information:
for itrk=1:numel(trks_out.sstr)
    trks_out.sstr(itrk).nPoints=size(trks_out.sstr(itrk).matrix,1);
end

%Get Unique voxels information
all_vox=trks_out.sstr(1).vox_coord ;        %initializing vox_coord
for ii=2:size(trks_out.sstr,2)
    all_vox=vertcat(all_vox,trks_out.sstr(ii).vox_coord);
end
%s_all_vox=sort(all_vox); %sort if bad! I believe it doesn't freeze the Y
%and Z columns so no good to do this! 
trks_out.unique_voxels=unique(all_vox,'rows');
trks_out.num_uvox=size(trks_out.unique_voxels,1);

%Moving TRKS_OUT to exit...
TRKS_OUT=trks_out;


