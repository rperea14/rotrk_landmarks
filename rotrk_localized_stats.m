function [ t_val_R, p_val_R, t_val_L, p_val_L ] = rotrk_localized_stats2(diffmetric, ref_id, identifier, TRKS_IN_R, TRKS_IN_L)
%function [ t_val_R, p_val_R, t_val_L, p_val_R ] = rotrk_localized_stats2(diffmetric, ref_id, identifier, TRKS_IN_R, TRKS_IN_L)
%Goal: To plot are retrieved the mean values of a centerline
%Input:
%       diffmetric  : diffmetric to be used (e.g. 'GFA' or 'NQA1' or etc.
%                     *Info should be a 4/5/6th column in the sstr.matrix
%       ref_id      : id used as a reference for plotting
%       identifier  : tells you how to split the data (e.g. "dx" for NCvsAD)
%       TRKS_IN_R
%       TRKS_IN_L   : TRKS_IN of interest for left and right locations)
%                ***TRKS_IN_R should be the larger in size (not
%                  *necessary the right side!
%
%
%Created by Rodrigo Perea, rpereacamargo@mgh.harvard.edu

%CHECKING ARGUMENT INITIALIZATION:
if nargin < 3
    error('No enough arguments. Please pass at least an identifier (e.g. dx and a hdr_XX and sstr_XX')
end

if nargin < 4
    warning('Using only onse header and strline list. Probably unilateral results?')
end



%CODE IMPLEMENTATION STARTS HERE:

%Now assign values to the matrices...
flag_identifier=TRKS_IN_R{1}.header.data.(identifier); %value equals "NC"

%COPYING TEMPLATE (ref_id) XYZ COORDINATES:
[ xref_R, yref_R, zref_R, xref_TRK_R ] = local_get_xyz_ref(ref_id, TRKS_IN_R);
[ xref_L, yref_L, zref_L, xref_TRK_L ] = local_get_xyz_ref(ref_id, TRKS_IN_L);

%ASSIGNED EITHER NC OR AD TRKS (BASED ON 'identifier'):
if strcmp(flag_identifier,'NC') %~~~> will only change the names based on identifier
    [ TRKS_L_NC_tmp TRKS_L_AD_tmp ] = local_split_TRKS_basedon_identifier(flag_identifier, identifier, TRKS_IN_L);
    [ TRKS_R_NC_tmp TRKS_R_AD_tmp ] = local_split_TRKS_basedon_identifier(flag_identifier, identifier, TRKS_IN_R);
else
    [ TRKS_L_AD_tmp TRKS_L_NC_tmp ] = local_split_TRKS_basedon_identifier(flag_identifier, identifier, TRKS_IN_L);
    [ TRKS_R_AD_tmp TRKS_R_NC_tmp ] = local_split_TRKS_basedon_identifier(flag_identifier, identifier, TRKS_IN_R);
end

%CHECK FOR SAME N FOR EACH GROUP: (maybe remove this for non-agematched data?)
[ TRKS_L_NC TRKS_L_AD ] = local_check_age_matched(TRKS_L_NC_tmp, TRKS_L_AD_tmp) ;
[ TRKS_R_NC TRKS_R_AD ] = local_check_age_matched(TRKS_R_NC_tmp, TRKS_R_AD_tmp) ;

%NOW GENERATE A TABLE PER EACH POINT:
[ theTable_L, nTableL ] = local_gen_tables(TRKS_L_NC , TRKS_L_AD, diffmetric);
[ theTable_R, nTableR ] = local_gen_tables(TRKS_R_NC , TRKS_R_AD, diffmetric);

%CREATING fitlm and retrieve the p_values and t-stats
[ p_val_L, t_val_L ] = local_get_stats(theTable_L, nTableL, diffmetric);
[ p_val_R, t_val_R ] = local_get_stats(theTable_R, nTableR, diffmetric);

%FOR NEGATIVITY, LETS ABSOLUTE THE T VALUES
t_val_L=abs(t_val_L);
t_val_R=abs(t_val_R);



%Checking for one-tailed at 0.05 w/ 
%one side:
newidx=1;
x_1marked=nan;
for ii=1:numel(t_val_R)
    if t_val_R(ii) >= 1.68 %1.68 for (n=38 to 51, 40 comparisons total)
        x_1marked(newidx)=xref_R(ii);
        y_1marked(newidx)=yref_R(ii);
        z_1marked(newidx)=zref_R(ii);
        t_1marked(newidx)=t_val_R(ii);
        newidx=1+newidx;
    end
end
%the other side:
newidx=1;
x_2marked=nan;
for ii=1:numel(t_val_L)
    if t_val_L(ii) >= 1.68%1.68 for (n=38 to 51, 40 comparisons total)
        x_2marked(newidx)=xref_L(ii);
        y_2marked(newidx)=yref_L(ii);
        z_2marked(newidx)=zref_L(ii);
        t_2marked(newidx)=t_val_L(ii);
        newidx=1+newidx;
    end
end

%PLOTTING NOW....
figure
hold on
%Plotting the values now...
tomaxmin=[ t_val_R t_val_L];
mincolor=median(tomaxmin)-std(tomaxmin);
maxcolor=median(tomaxmin)+std(tomaxmin);

HH=scatter3(xref_R,yref_R,zref_R,2000,t_val_R,'filled');
%t_2(10:30)=-200 --> Checkin which side is left and/or right
HH2=scatter3(xref_L,yref_L,zref_L,2000,t_val_L,'filled');


%RED ASTERISK BEING PLOTTED
% if ~isnan(x_1marked)
% TT=scatter3(x_1marked,y_1marked,z_1marked,2000,t_1marked,'filled'); %T-vals above significance!
% TT.MarkerEdgeColor='red';
% TT.Marker='*';
% end
% 
% if ~isnan(x_2marked)
% TT2=scatter3(x_2marked,y_2marked,z_2marked,2000,t_2marked,'filled'); 
% TT2.MarkerEdgeColor='red';
% TT2.Marker='*';
% end


c=colorbar;
c.Label.String = diffmetric;
colormap('parula') %can try jet as well
%caxis([mincolor maxcolor ])
caxis([0 2.5 ]);
title( [ 'T-values for ' diffmetric ],'fontsize',30 );
%xlim([100 160]) ; ylim([110 160]) ; zlim([55 85]) ; 

view(43,10)
%view(-45,14) %or view(45,14)
% view(51,8) or view(51,-8)
%set(c,'YTick',[2.02])

%%Removing the axis but keeping other variables..
hFig=gcf;
color = get(hFig,'Color');
set(gca,'XColor',color,'YColor',color,'Zcolor',color,'TickDir','out');
set(gca,'FontSize',24)
%Removing XYZ units...
set(gca,'XTickLabelMode','Manual') ; set(gca,'YTickLabelMode','Manual') ; set(gca,'ZTickLabelMode','Manual')

% %Adding lateral view
% text(xref_L(end)+5,yref_L(end)+5,zref_L(end) ,'Left','fontsize',20 );
% text(xref_R(end)+5,yref_R(end)+5,zref_R(end)-3 ,'Right','fontsize',20 );

%Some verifications....
hold off

%%#########################################################################
%%##################LOCAL FUNCTIONS START HERE: ###########################

%FUNCTION local_get_xyz_ref:
function [x_loc, y_loc, z_loc, ref_TRK ] = local_get_xyz_ref(ref_id, local_TRKS_IN)
for ii=1:numel(local_TRKS_IN)
    if strcmp(ref_id,local_TRKS_IN{ii}.header.id)
        x_loc=local_TRKS_IN{ii}.sstr.matrix(:,1);
        y_loc=local_TRKS_IN{ii}.sstr.matrix(:,2);
        z_loc=local_TRKS_IN{ii}.sstr.matrix(:,3);
        ref_TRK=local_TRKS_IN{ii};
    end
end

%#############################################
%FUNCTION local_split_TRKS_basedon_identifier:
function [ TRKS_R_sameID TRKS_R_notsameID ] = local_split_TRKS_basedon_identifier(flag_identifier, identifier,local_TRKS_IN )
counter_same=1;
counter_notsame=1;
for ii=1:numel(local_TRKS_IN)
    if strcmp(local_TRKS_IN{ii}.header.data.(identifier),flag_identifier)
        TRKS_R_sameID{counter_same}=local_TRKS_IN{ii};
        counter_same=1+counter_same;
    else
        TRKS_R_notsameID{counter_notsame}=local_TRKS_IN{ii};
        counter_notsame=1+counter_notsame;
    end
end

%################################
%FUNCTION local_check_age_matched:
function [ newTRKS_NC newTRKS_AD ] = local_check_age_matched(TRKS_IN_NC, TRKS_IN_AD)
%TRKS_IN_NC should be larger in size, as TRKS_IN_AD will be automatically
%passed the same values...
newTRKS_AD=TRKS_IN_AD;
counter_newNC=1;
newTRKS_NC={''};
for ii=1:numel(TRKS_IN_NC)
    for jj=1:numel(TRKS_IN_AD)
        %See if we find a agematched id in the AD trks, if so, create it!
        if TRKS_IN_NC{ii}.header.data.agematched == TRKS_IN_AD{jj}.header.data.agematched
            newTRKS_NC{counter_newNC}=TRKS_IN_NC{ii};
            counter_newNC=counter_newNC+1;
        end
    end
end

%#########################
%FUNCTION local_gen_tables:
function [ table_out, num_points ] = local_gen_tables(TRKS_IN_NC , TRKS_IN_AD, diffmetric)
table_out={''};

%MERGING BOTH TRACTS:
ALL_TRKS= [ TRKS_IN_NC, TRKS_IN_AD ];

%All these TRKS_IN{any} should have the same number of points (e.g. n=40),
%and equal DIFFMETRICS.
%HENCE WE WILL USE THE idx 1 to initialize variables!!
num_points=ALL_TRKS{1}.sstr.nPoints;

%CHECK WHAT DIFFMETRIC WE WILL BE USING:
for tt=1:size(ALL_TRKS{1}.header.scalar_IDs,2)
    if strcmp(ALL_TRKS{1}.header.scalar_IDs(tt),diffmetric)
        diff_cc=3+tt; % 3 adds the xyz  coordinates!
    end
end

%CREATING A TABLE PER nPoint:
for ii=1:num_points 
    cur_diffmetric=[ diffmetric '_n' num2str(ii) ];
    for jj=1:numel(ALL_TRKS) %number of SUBJECTS
        if ii==1
            cur_table.id{jj,1}=ALL_TRKS{jj}.header.id;
            cur_table.dx{jj,1}=ALL_TRKS{jj}.header.data.dx;
            cur_table.fimbria_volL(jj,1)=ALL_TRKS{jj}.header.data.fimbria_volDIL_L;
            cur_table.fimbria_volR(jj,1)=ALL_TRKS{jj}.header.data.fimbria_volDIL_R;
            cur_table.diffmotion(jj,1)=ALL_TRKS{jj}.header.data.diffmotion;
        end
        cur_table.(cur_diffmetric)(jj,1)=ALL_TRKS{jj}.sstr.vox_coord(ii,diff_cc);
    end
end
table_out=struct2table(cur_table);

%#########################
%FUNCTION local_get_stats
function [ p_val, t_val ] = local_get_stats(table_IN, num_points, diffmetric)
for ii=1:num_points
    n_diffmetric=[ diffmetric '_n' num2str(ii) ];
    mdl_tmp=fitlm(table_IN, [ (n_diffmetric) '~dx+diffmotion']);
    
    p_val(ii)=mdl_tmp.Coefficients.pValue(2);
    t_val(ii)=mdl_tmp.Coefficients.tStat(2);
    clear mdl_tmp
end
