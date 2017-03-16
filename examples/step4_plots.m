% %%

%%
%Adding the xls values
disp('Adding xls_data to values from rotrk_2landmarks.m ...');
TRKS_FX_centerline_R = rotrk_add_xls(xls_DATA,TRKS_FX_centerline_R);
TRKS_FX_centerline_L = rotrk_add_xls(xls_DATA,TRKS_FX_centerline_L);
TRKS_FX_trimmed_L = rotrk_add_xls(xls_DATA,TRKS_FX_trimmed_L);
TRKS_FX_trimmed_R = rotrk_add_xls(xls_DATA,TRKS_FX_trimmed_R);

TRKS_FX_DOT=rotrk_add_xls(xls_DATA,TRKS_FX_DOT);
TRKS_FX_FIMBRIA_L=rotrk_add_xls(xls_DATA,TRKS_FX_FIMBRIA_L);
TRKS_FX_FIMBRIA_R=rotrk_add_xls(xls_DATA,TRKS_FX_FIMBRIA_R);
%%





% %Plotting default tracking parameters

%%
%First let's get the *.plot parameters to be passed
for tocomment=1:1
    for ii=1:numel(TRKS_FX_DOT)
        TRKS_FX_DOT{ii}.plot_params.color='bb';
        TRKS_FX_DOT{ii}.plot_params.orientation='fornix';
        TRKS_FX_DOT{ii}.plot_params.xlim=[ 85 165 ] ;
        TRKS_FX_DOT{ii}.plot_params.ylim=[ 105 165 ] ;
        TRKS_FX_DOT{ii}.plot_params.zlim=[ 35 95 ] ;
         
    end
    
    for ii=1:numel(TRKS_FX_FIMBRIA_R)
        TRKS_FX_FIMBRIA_R{ii}.plot_params.color='gg';
        TRKS_FX_FIMBRIA_R{ii}.plot_params.orientation='fornix';
        TRKS_FX_FIMBRIA_R{ii}.plot_params.xlim=[ 85 165 ] ;
        TRKS_FX_FIMBRIA_R{ii}.plot_params.ylim=[ 105 165 ] ;
        TRKS_FX_FIMBRIA_R{ii}.plot_params.zlim=[ 35 95 ] ;
        
        
        TRKS_FX_trimmed_R{ii}.plot_params.color='gg';
        TRKS_FX_trimmed_R{ii}.plot_params.orientation='fornix';
        TRKS_FX_trimmed_R{ii}.plot_params.xlim=[ 85 165 ] ;
        TRKS_FX_trimmed_R{ii}.plot_params.ylim=[ 105 165 ] ;
        TRKS_FX_trimmed_R{ii}.plot_params.zlim=[ 35 95 ] ;
        
        TRKS_FX_centerline_R{ii}.plot_params.color='gg';
        TRKS_FX_centerline_R{ii}.plot_params.orientation='fornix';
        TRKS_FX_centerline_R{ii}.plot_params.xlim=[ 85 165 ] ;
        TRKS_FX_centerline_R{ii}.plot_params.ylim=[ 105 165 ] ;
        TRKS_FX_centerline_R{ii}.plot_params.zlm=[ 35 95 ] ;
    end
    
    for ii=1:numel(TRKS_FX_FIMBRIA_L)
        TRKS_FX_FIMBRIA_L{ii}.plot_params.color='rr';
        TRKS_FX_FIMBRIA_L{ii}.plot_params.orientation='fornix';
        TRKS_FX_FIMBRIA_L{ii}.plot_params.xlim=[ 85 165 ] ;
        TRKS_FX_FIMBRIA_L{ii}.plot_params.ylim=[ 105 165 ] ;
        TRKS_FX_FIMBRIA_L{ii}.plot_params.zlim=[ 35 95 ] ;
        
        
        TRKS_FX_trimmed_L{ii}.plot_params.color='rr';
        TRKS_FX_trimmed_L{ii}.plot_params.orientation='fornix';
        TRKS_FX_trimmed_L{ii}.plot_params.xlim=[ 85 165 ] ;
        TRKS_FX_trimmed_L{ii}.plot_params.ylim=[ 105 165 ] ;
        TRKS_FX_trimmed_L{ii}.plot_params.zlim=[ 35 95 ] ;
        
        TRKS_FX_centerline_L{ii}.plot_params.color='rr';
        TRKS_FX_centerline_L{ii}.plot_params.orientation='fornix';
        TRKS_FX_centerline_L{ii}.plot_params.xlim=[ 85 165 ] ;
        TRKS_FX_centerline_L{ii}.plot_params.ylim=[ 105 165 ] ;
        TRKS_FX_centerline_L{ii}.plot_params.zlim=[ 35 95 ] ;
    end
end

%%
%
%All strlimes:
rotrk_plot(TRKS_FX_DOT,'','age','AD',TRKS_FX_FIMBRIA_R,TRKS_FX_FIMBRIA_L,'add','sex','add','age');
rotrk_plot(TRKS_FX_DOT,'','age','NC',TRKS_FX_FIMBRIA_R,TRKS_FX_FIMBRIA_L,'add','sex','add','age');

%%
%Trimmed lines:
rotrk_plot(TRKS_FX_trimmed_R,'','age','AD',TRKS_FX_trimmed_L,'add','sex','add','age');
rotrk_plot(TRKS_FX_trimmed_R,'','age','NC',TRKS_FX_trimmed_L,'add','sex','add','age');

%%
%Centerlines:
rotrk_plot(TRKS_FX_centerline_R,'','age','AD',TRKS_FX_centerline_L,'add','sex','add','age')
rotrk_plot(TRKS_FX_centelrine_R,'','age','NC',TRKS_FX_centerline_L,'add','sex','add','age');


%%
%Localized plots
disp('In GFA localized stats...')
[ tval_R_GFA, pval_R_GFA, tval_L_GFA, pval_L_GFA ] =rotrk_localized_stats('GFA','150304_8CS00253','dx',TRKS_FX_centerline_R,TRKS_FX_centerline_L);
disp('In NQA0 localized stats...')
[ tval_R_NQA0, pval_R_NQA0, tval_L_NQA0, pval_L_NQA0 ] =rotrk_localized_stats('NQA0','150304_8CS00253','dx',TRKS_FX_centerline_R,TRKS_FX_centerline_L);
disp('In FA localized stats...')
[ tval_R_FA, pval_R_FA, tval_L_FA, pval_L_FA ] =rotrk_localized_stats('FA','150304_8CS00253','dx',TRKS_FX_centerline_R,TRKS_FX_centerline_L);
disp('In RD localized stats...')
[ tval_R_RD, pval_R_RD, tval_L_RD, pval_L_RD ] =rotrk_localized_stats('RD','150304_8CS00253','dx',TRKS_FX_centerline_R,TRKS_FX_centerline_L);
disp('In MD localized stats...')
[ tval_R_MD, pval_R_MD, tval_L_MD, pval_L_MD ] =rotrk_localized_stats('MD','150304_8CS00253','dx',TRKS_FX_centerline_R,TRKS_FX_centerline_L);

