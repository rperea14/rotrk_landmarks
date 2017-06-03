function [ TRKS_OUT OPT_distance] = rotrk_centerline(TRKS_IN, method, selected_metric)
%function [ selected_header, selected_tracts ] = rotrk_centerline(header,tracts)
%IN:
%           TRKS_IN.header          : header file  (header structure format)
%           TRKS_IN.tracts          : tracts file  (trk structure format)
%           *method:                ''high_sc' or 'low_sc' (default: high_sc)
%                                       method for centerline to be used.
%                                       *Means all the diffmetric from each
%                                       streamline, then if high_sc (it
%                                       selects the one with the highest
%                                       mean selected_metric or viceversa)
%                                     'hausdorff' outputs the streamline with
%                                     the mean lowest distance value
%                                     streamline
%           *selected_diffmetric    :if method=high_sc then we need scalars
%                                   that can be passed as [ GFA NQA0 ].
%                                   This information should come from
%                                   TRKS_IN.sstr.matrix{4:end}
%                        

%OUT:
%           TRKS_OUT
% *IMPORTANT:
%               MAKE SURE YOU'VE INTERPOLATED THE TRKS_IN 1st input*
% (Created by Rodrigo Perea)


%%%%%%%%SPLITTING THTE TRACTS_STRUCT FORM INTO TRACTS AND HEADER
TRKS_OUT.header=TRKS_IN.header;
TRKS_OUT.header.n_count=1;
TRKS_OUT.id=TRKS_IN.id;
if isfield(TRKS_OUT,'filename')
    TRKS_OUT.filename=strrep(TRKS_IN.filename,'.trk','_cline.trk');
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%%%ARGUMENT CHECKING...
%if selected_metric is not included in the header of the image, sent an
%error that the scalar does not exist
if ~strcmp(method,'hausdorff')
    try
        if ~isempty(TRKS_IN.header.scalar_IDs)
            %Assigned metric to do the cut....
            assigned_diffmetric='';
            assigned_col='';
            for pp=1:numel(TRKS_IN.header.scalar_IDs)
                if strcmp(selected_metric,TRKS_IN.header.scalar_IDs(pp))
                    assigned_diffmetric=TRKS_IN.header.scalar_IDs(pp);
                    assigned_col=3+pp; %This will assign the column we'll use to describe the method used
                end
            end
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
        end
    catch
        error('Make sure that the field TRKS_IN.header.scalar_IDs exists.')
        error('Exiting...') ;
    end
end

if nargin < 2
    method='high_sc';
    selected_metric='null';
    warning('No metric selected as the flag for centerline. Using null (denoting unassigned)');
end


%INITIALZING VARIABLES...
mean_vals=nan(size(TRKS_IN.sstr,2),1);
median_vals=nan(size(TRKS_IN.sstr,2),1);
highsc_vals=nan(size(TRKS_IN.sstr,2),1);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if strcmp(method,'hausdorff')
    disp('You selected the min. hausdorff distance. This might take a while...')
    fprintf(['Calculating the distance of fiber (n=' num2str(numel(TRKS_IN.sstr)) '): ' ])
    for kk=1:numel(TRKS_IN.sstr)
        fprintf([ num2str(kk) ' '])
        if ~mod(kk,20) ; fprintf('\n'); end
        for ii=1:numel(TRKS_IN.sstr);
           hasdist1{kk}{ii}=rotrk_get_distance_HDorff(TRKS_IN.sstr(kk).matrix,TRKS_IN.sstr(ii).matrix);
        end
        
        AA(kk)=rotrk_get_distance_HDorff(TRKS_IN.sstr(kk).matrix,TRKS_IN.sstr(1).matrix);
        nstr1(kk)=TRKS_IN.sstr(kk).nPoints;
        %[max1 idx_max1 ] = m ax(hasdist1);
        %[min1 idx_min1 ] = min(hasdist1);
    end
    fprintf('...done \n');
    %Mean distances:
    for jj=1:numel(hasdist1)
        mean_dist1(jj)=mean(cell2mat(hasdist1{jj}));
    end
    %Select the streamline whose Hausdorff distance is the lowest
    [mindist1 idx_mindist1 ] = min(mean_dist1);
    idx=idx_mindist1;    
else
    %CALCULATING THE SPECIFIC VARIABLES
    for ii=1:size(TRKS_IN.sstr,2)
        mean_vals(ii)=mean(TRKS_IN.sstr(ii).vox_coord(:,assigned_col));
        median_vals(ii)=mean(TRKS_IN.sstr(ii).vox_coord(:,assigned_col));
    end
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    %SELECT THE METHOD TO BE USED
    switch method
        case 'high_sc'
            [val_high, idx ] = max(mean_vals);
        case 'low_sc'
            [val_low, idx ] = min(mean_vals);
        case 'median' %<~~~NOT TESTED AS 01/20/2017
            [val_low, idx ] = median(median_vals);
    end
end
TRKS_OUT.sstr.matrix=TRKS_IN.sstr(idx).matrix;
TRKS_OUT.sstr.vox_coord=TRKS_IN.sstr(idx).vox_coord;
TRKS_OUT.sstr.nPoints=size(TRKS_IN.sstr(idx).matrix,1);

TRKS_OUT.header.specific_name=strcat(TRKS_IN.header.specific_name,'_centerline');

%Remove another naming convention...
TRKS_OUT.header.specific_name=strrep(TRKS_OUT.header.specific_name,'_trimmedx2','');



%Get the volume of non-overlapping XYZ vox_coord values
AA=1;
all_vox=TRKS_OUT.sstr(1).vox_coord;        %initializing vox_coord
%s_all_vox=sort(all_vox); %sort if bad! I believe it doesn't freeze the Y
%and Z columns so no good to do this! 
TRKS_OUT.unique_voxels=unique(all_vox,'rows');
TRKS_OUT.num_uvox=size(TRKS_OUT.unique_voxels,1);


%adding the matrix_length
len=0;
for jj=1:size(TRKS_OUT.sstr.matrix,1)
    if jj~=size(TRKS_OUT.sstr.matrix,1)
        len=len+pdist2(TRKS_OUT.sstr.matrix(jj,:),TRKS_OUT.sstr.matrix(jj+1,:));
    end
end
TRKS_OUT.len_matrix=len;
