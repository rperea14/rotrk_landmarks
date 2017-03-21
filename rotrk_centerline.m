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
TRKS_OUT.filename=TRKS_IN.filename;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%%%ARGUMENT CHECKING...
%if selected_metric is not included in the header of the image, sent an
%error that the scalar does not exist
if isempty(TRKS_IN.header.scalar_IDs) 
    error('Make sure that the field TRKS_IN.header.scalar_IDs exists.') 
    error('Exiting...') ; 
end

if nargin < 2
    method='high_sc';
    selected_metric='null';
    warning('No metric selected as the flag for centerline. Using null (denoting unassigned)');
end

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
            hasdist1{kk}{ii}=ModHausdorffDist(TRKS_IN.sstr(kk).matrix,TRKS_IN.sstr(ii).matrix);
        end
        
        AA(kk)=ModHausdorffDist(TRKS_IN.sstr(kk).matrix,TRKS_IN.sstr(1).matrix);
        nstr1(kk)=TRKS_IN.sstr(kk).nPoints;
        %[max1 idx_max1 ] = m ax(hasdist1);
        %[min1 idx_min1 ] = min(hasdist1);
    end
    fprintf('...done \n');
    %Mean distances:
    for jj=1:numel(hasdist1)
        mean_dist1(jj)=mean(cell2mat(hasdist1{jj}));
    end
    %Select the streamline whose Hausdorff distance is the lowers
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

% %BELOW IS CODE BEING RECYCLED ~~~~~~>>>
% % ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~
% % ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~
% % ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~~~~ ~~~
% %~~~~~~~~~~~~~~~~~~~~~~~~STARTING CENTERLINE IMPLEMENTATION~~~~~~~~~~~~~~~~
% %Here it starts the centerline process (after interpolation have been
% %given...
% if strcmp(method,'mean') || strcmp(method,'median')
%     xyz_row=nan(size(TRKS_IN.sstr,2),3);
%     mean_location=nan(size(TRKS_IN.sstr,1),3);
%     median_location=nan(size(TRKS_IN.sstr,1),3);
%     %storing every row xyz in a column
%     for ii=1:size(TRKS_IN.sstr,1)
%         %clear xyz_row
%         for jj=1:size(TRKS_IN.sstr,3)
%             %Here I store every row into xyz_row to then execute the
%             %mean/median
%             xyz_row(jj,1:3)=TRKS_IN.sstr(ii,1:3,jj);
%         end
%         mean_location(ii,:)=mean(xyz_row);
%         median_location(ii,:)=median(xyz_row);
%     end
%     
%     
%     %Additional steps to calculate the eucledian distance on each coordinate system,
%     %then add them up and select the streamline with the shortest distance to
%     %the mean streamline.
%     for ij=1:size(TRKS_IN.sstr,3) % # of strlines
%         for ik=1:size(TRKS_IN.sstr,1) % # of coordinates in strlines
%             %Here I created a matrix distance that computes the distance
%             %between every row_coordinate location to each TRKS_IN.sstr
%             %point
%             if strcmp(method,'mean')
%                 distance(ij,ik,1)=sqrt( (TRKS_IN.sstr(ik,1,ij) - mean_location(ik,1) )^2 +  (TRKS_IN.sstr(ik,2,ij) - mean_location(ik,2))^2 + (TRKS_IN.sstr(ik,3,ij) - mean_location(ik,3))^2);
%             else
%                 disp('choosing median');
%                 distance(ij,ik,1)=sqrt( (TRKS_IN.sstr(ik,1,ij) - median_location(ik,1) )^2 +  (TRKS_IN.sstr(ik,2,ij) - median_location(ik,2))^2 + (TRKS_IN.sstr(ik,3,ij) - median_location(ik,3))^2);
%             end
%         end
%         
%     end
%     total_distance=sum(distance'); %adding up every xyz_row distance and computer the one with the minimun value
%     [value idx ] = min(total_distance);
%     
%     selected_tracts.matrix=TRKS_IN.sstr(:,:,idx);
%     selected_tracts.nPoints=size(selected_tracts.matrix,1);
%     
%     %Adding scalar values now... (not needed earlier as won;t change the
%     %celection of the centerline as in the case of 'high_sc' implemented below)
%     if ~isempty(diffmetric)
%         
%         for ss=1:numel(diffmetric)
%             [ selected_header,  selected_tracts ] =  rotrk_add_sc(selected_header,  selected_tracts,diffmetric(ss),diffmetric(ss).identifier);
%         end
%     end
%     
% elseif strcmp(method,'high_sc') || strcmp(method,'high_sc_top')
%     if ~isempty(diffmetric)
%         flag_meanval=nan(1,size(tmp_TRKS_IN.sstr,2));
%         for ss=1:numel(diffmetric)
%             [ tmp_TRKS_IN.sstr ] =  rotrk_add_sc(selected_header,  tmp_TRKS_IN.sstr, diffmetric(ss), diffmetric(ss).identifier);
%         end
%         %Here is where we mean each streamline group based on the values
%         %for column 4 (if NQA0 is column 4, then it will be the high_sc of
%         %NQA0 instead than for GFA). !!!
%         for kk=1:size(tmp_TRKS_IN.sstr,2)
%             %this will select the streamline within the 4,5,6th column
%             flag_meanval(kk)=mean(tmp_TRKS_IN.sstr(kk).matrix(:,4));
%             %flag_meanval(kk)=mean(tmp_TRKS_IN.sstr(kk).matrix(:,5));
%             %flag_meanval(kk)=mean(tmp_TRKS_IN.sstr(kk).matrix(:,6));
%         end
%         
%         if strcmp(method,'high_sc')
%             [value idx ] = max(flag_meanval);
%         else
%             %here I tried the top high_sc values but not sure if it works
%             %well...double check!
%             [value idx ] = max(flag_meanval(round(size(flag_meanval,2)/4):end));
%         end
%         
%         selected_tracts.matrix=tmp_TRKS_IN.sstr(idx).matrix;
%         selected_tracts.nPoints=size(selected_tracts.matrix,1);
%     end
% 
% elseif strcmp(method,'low_sc')
%     if ~isempty(diffmetric)
%         flag_meanval=nan(1,size(tmp_TRKS_IN.sstr,2));
%         for ss=1:numel(diffmetric)
%             [ selected_header,  tmp_TRKS_IN.sstr ] =  rotrk_add_sc(selected_header,  tmp_TRKS_IN.sstr, diffmetric(ss), diffmetric(ss).identifier);
%         end
%         %Here is where we mean each streamline group based on the values
%         %for column 4 (if NQA0 is column 4, then it will be the high_sc of
%         %NQA0 instead than for GFA). !!!
%         for kk=1:size(tmp_TRKS_IN.sstr,2)
%             %this will select the streamline within the 4,5,6th column
%             flag_meanval(kk)=mean(tmp_TRKS_IN.sstr(kk).matrix(:,4));
%             %flag_meanval(kk)=mean(tmp_TRKS_IN.sstr(kk).matrix(:,5));
%             %flag_meanval(kk)=mean(tmp_TRKS_IN.sstr(kk).matrix(:,6));
%         end
%         
%         [value idx ] = min(flag_meanval);
%         
%         selected_tracts.matrix=tmp_TRKS_IN.sstr(idx).matrix;
%         selected_tracts.nPoints=size(selected_tracts.matrix,1);
%         
%         
%     else
%         error('Make sure you pass the diffmetric argument containing valid diffmetrics')
%         error('How can I select a centerline if I have no diffmetric values??')
%     end
%     
%     
% else
%     error('Incorrect method for choosing a centerline. Please use either mean or high_sc')
% end
% 
% 
% 
% %%REFILLING THE SSTR INFOR IN THE TRKS STRUCT FORMAT:
% TRKS_OUT.sstr=selected_tracts

    
