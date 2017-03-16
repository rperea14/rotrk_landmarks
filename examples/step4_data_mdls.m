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

TRKS_GENU=rotrk_add_xls(xls_DATA,TRKS_GENU)
TRKS_GENU_centerline=rotrk_add_xls(xls_DATA,TRKS_GENU_centerline)
disp('DONE! (Adding xls_data to values from rotrk_2landmarks.m ...)');
%%


%%
%Generate the major table
disp('Generating the table');
%Adding the necessary values to a table:
[unclean_Table, vars_out] = rotrk_2table(TRKS_FX_DOT, TRKS_FX_FIMBRIA_L,TRKS_FX_FIMBRIA_R,TRKS_FX_trimmed_L, TRKS_FX_trimmed_R, TRKS_FX_centerline_L, TRKS_FX_centerline_R, TRKS_GENU_centerline);
%Remove nans and the matched pair:
clean_Table=rotrk_re_pair_nans(unclean_Table,'agematched_id',9);
theTable=clean_Table;
disp('Done! (generating the table)');
%%
%THE STATS DEFAULT TRACKING (FOR PUBLICATION):
clc
%
%STREAMLINE LENGTHS (BASED ON DEF. TRACKING):
mdl_dot_maxlen_bil=fitlm(theTable, 'maxlen_fx_DOT~dx+diffmotion+vol_fimbriaDIL_L+vol_fimbriaDIL_R')
mdl_dot_maxlen_bil_diffonly=fitlm(theTable, 'maxlen_fx_DOT~dx+diffmotion')
mdl_dot_maxlen_L=fitlm(theTable, 'maxlen_fx_fimbria_L~dx+diffmotion+vol_fimbriaDIL_L')
mdl_dot_maxlen_R=fitlm(theTable, 'maxlen_fx_fimbria_R~dx+diffmotion+vol_fimbriaDIL_R')

%VOL BASED ON DOT TRACTOGRAPHY:
mdl_dot_voltrx_FX_bil=fitlm(theTable, 'voltrx_FX_DOT_bil~dx+diffmotion+vol_fimbriaDIL_L+vol_fimbriaDIL_R')
mdl_dot_voltrx_FX_bil_diffonly=fitlm(theTable, 'voltrx_FX_DOT_bil~dx+diffmotion')
mdl_dot_voltrx_FX_L=fitlm(theTable, 'voltrx_FX_DOT_L~dx+diffmotion+vol_fimbriaDIL_L')
mdl_dot_voltrx_FX_R=fitlm(theTable, 'voltrx_FX_DOT_R~dx+diffmotion+vol_fimbriaDIL_R')

%NUMBER OF STREAMLINE PER TRACKING
mdl_dot_numsstr_FX_DOT=fitlm(theTable, 'numsstr_fx_DOT~dx+diffmotion+vol_fimbriaDIL_L+vol_fimbriaDIL_R')
mdl_dot_numsstr_FX_DOT=fitlm(theTable, 'numsstr_fx_DOT~dx+diffmotion')
mdl_dot_numsstr_FX_FIMBRIA_L=fitlm(theTable, 'numsstr_fx_fimbria_L~dx+diffmotion+vol_fimbriaDIL_L')
mdl_dot_numsstr_FX_FIMBRIA_R=fitlm(theTable, 'numsstr_fx_fimbria_R~dx+diffmotion+vol_fimbriaDIL_R')



%%
clc
%%THE STATS GENU (FOR PUBLICATION)
mdl_GENU_cline_GFA=fitlm(theTable, 'meanGFA_genu_trimmed_centerline~dx+diffmotion')
mdl_GENU_cline_NQA0=fitlm(theTable, 'meanNQA0_genu_trimmed_centerline~dx+diffmotion')
mdl_GENU_cline_QA0=fitlm(theTable, 'meanQA0_genu_trimmed_centerline~dx+diffmotion')
mdl_GENU_cline_NQA1=fitlm(theTable, 'meanNQA1_genu_trimmed_centerline~dx+diffmotion')

mdl_GENU_cline_FA=fitlm(theTable, 'meanFA_genu_trimmed_centerline~dx+diffmotion')
mdl_GENU_cline_RD=fitlm(theTable, 'meanRD_genu_trimmed_centerline~dx+diffmotion')
mdl_GENU_cline_MD=fitlm(theTable, 'meanMD_genu_trimmed_centerline~dx+diffmotion')
mdl_GENU_cline_AxD=fitlm(theTable, 'meanAxD_genu_trimmed_centerline~dx+diffmotion')



%%
%THE STATS MINIMIZED TRACKING (FOR PUBLICATION):
clc

mdl_centerline_GFA_L=fitlm(theTable, 'meanGFA_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_GFA_R=fitlm(theTable, 'meanGFA_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_QA0_L=fitlm(theTable, 'meanQA0_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_QA0_R=fitlm(theTable, 'meanQA0_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_NQA0_L_peakmax=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_NQA0_R_peakmax=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_NQA0_L_peakGENU=fitlm(theTable, 'meanNQA0_GENU_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_NQA0_R_peakGENU=fitlm(theTable, 'meanNQA0_GENU_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_NQA0_L_peakFORNIX=fitlm(theTable, 'meanNQA0_FX_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_NQA0_R_peakFORNIX=fitlm(theTable, 'meanNQA0_FX_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_NQA1_L=fitlm(theTable, 'meanNQA1_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_NQA1_R=fitlm(theTable, 'meanNQA1_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_NQA2_L=fitlm(theTable, 'meanNQA2_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_NQA2_R=fitlm(theTable, 'meanNQA2_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_FA_L=fitlm(theTable, 'meanFA_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_FA_R=fitlm(theTable, 'meanFA_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_RD_L=fitlm(theTable, 'meanRD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_RD_R=fitlm(theTable, 'meanRD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_AxD_L=fitlm(theTable, 'meanAxD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_AxD_R=fitlm(theTable, 'meanAxD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_MD_L=fitlm(theTable, 'meanMD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_MD_R=fitlm(theTable, 'meanMD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')




mdl_centerline_ISO_L=fitlm(theTable, 'meanISO_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_ISO_R=fitlm(theTable, 'meanISO_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_RDI1L_L=fitlm(theTable, 'meanRDI1L_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_RDI1L_R=fitlm(theTable, 'meanRDI1L_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')



%%
mdl_centerline_NQA0_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_NQA0_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')


mdl_centerline_NQA1_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_NQA1_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')

mdl_centerline_NQA2_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
mdl_centerline_NQA2_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')







%%
%IN CENTERLINES:
% clc
% %mdl_dot_length_L=fitlm(theTable, 'dotlength_Left~dx+diffmotion+vol_fimbriaDIL_L')
% %mdl_dot_length_R=fitlm(theTable, 'dotlength_Right~dx+diffmotion+vol_fimbriaDIL_R')
% 
% %mdl_vol_joinedL=fitlm(theTable, 'vol_fornix_joinedL_mm3~dx+diffmotion+vol_fimbriaDIL_L')
% %mdl_vol_joinedR=fitlm(theTable, 'vol_fornix_joinedR_mm3~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_GFA_L=fitlm(theTable, 'meanGFA_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_GFA_R=fitlm(theTable, 'meanGFA_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_NQA0_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_NQA0_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_NQA0_FX_L=fitlm(theTable, 'meanNQA0_FX_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_NQA0_FX_R=fitlm(theTable, 'meanNQA0_FX_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_NQA0_GENU_L=fitlm(theTable, 'meanNQA0_GENU_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_NQA0_GENU_R=fitlm(theTable, 'meanNQA0_GENU_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_NQA1_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_NQA1_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% 
% mdl_NQA2_L=fitlm(theTable, 'meanNQA2_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_NQA2_R=fitlm(theTable, 'meanNQA2_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% 
% mdl_QA0_L=fitlm(theTable, 'meanQA0_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_QA0_R=fitlm(theTable, 'meanQA0_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_QA1_L=fitlm(theTable, 'meanQA1_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_QA1_R=fitlm(theTable, 'meanQA1_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_QA2_L=fitlm(theTable, 'meanQA2_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_QA2_R=fitlm(theTable, 'meanQA2_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_ISO_L=fitlm(theTable, 'meanISO_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_ISO_R=fitlm(theTable, 'meanISO_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_RDI1L_L=fitlm(theTable, 'meanRDI1L_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_RDI1L_R=fitlm(theTable, 'meanRDI1L_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% 
% 
% %Other Interesting Metrics
% mdl_FA_L=fitlm(theTable, 'meanFA_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_FA_R=fitlm(theTable, 'meanFA_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_RD_L=fitlm(theTable, 'meanRD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_RD_R=fitlm(theTable, 'meanRD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_AxD_L=fitlm(theTable, 'meanAxD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_AxD_R=fitlm(theTable, 'meanAxD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% mdl_MD_L=fitlm(theTable, 'meanMD_fx_dotfimbriaL_centerline~dx+diffmotion+vol_fimbriaDIL_L')
% mdl_MD_R=fitlm(theTable, 'meanMD_fx_dotfimbriaR_centerline~dx+diffmotion+vol_fimbriaDIL_R')
% 
% %%
% %TO PUBLISH MODELS!
% 
% 
% 
% %%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % %%OTHER MODELS
% % %%SAME VALUES BUT ONLY CONTROLLING FOR DIFFMOTION
% % clc
% % %mdl_dot_length_L=fitlm(theTable, 'dotlength_Left~dx+diffmotion')
% % %mdl_dot_length_R=fitlm(theTable, 'dotlength_Right~dx+diffmotion')
% % 
% % %mdl_vol_joinedL=fitlm(theTable, 'vol_fornix_joinedL_mm3~dx+diffmotion')
% % %mdl_vol_joinedR=fitlm(theTable, 'vol_fornix_joinedR_mm3~dx+diffmotion')
% % 
% % mdl_GFA_L=fitlm(theTable, 'meanGFA_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_GFA_R=fitlm(theTable, 'meanGFA_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_NQA0_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_NQA0_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_NQA0_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_NQA0_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_NQA1_L=fitlm(theTable, 'meanNQA1_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_NQA1_R=fitlm(theTable, 'meanNQA1_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_NQA2_L=fitlm(theTable, 'meanNQA2_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_NQA2_R=fitlm(theTable, 'meanNQA2_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % 
% % mdl_QA0_L=fitlm(theTable, 'meanQA0_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_QA0_R=fitlm(theTable, 'meanQA0_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_QA1_L=fitlm(theTable, 'meanQA1_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_QA1_R=fitlm(theTable, 'meanQA1_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_QA2_L=fitlm(theTable, 'meanQA2_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_QA2_R=fitlm(theTable, 'meanQA2_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % 
% % mdl_ISO_L=fitlm(theTable, 'meanISO_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_ISO_R=fitlm(theTable, 'meanISO_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_RDI1L_L=fitlm(theTable, 'meanRDI1L_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_RDI1L_R=fitlm(theTable, 'meanRDI1L_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % 
% % 
% % %Other Interesting Metrics
% % % mdl_NMD_L=fitlm(theTable, 'meanNMD_fx_dotfimbriaL_centerline~dx+diffmotion')
% % % mdl_NMD_R=fitlm(theTable, 'meanNMD_fx_dotfimbriaR_centerline~dx+diffmotion')
% % % 
% % % mdl_NRD_L=fitlm(theTable, 'meanNRD_fx_dotfimbriaL_centerline~dx+diffmotion')
% % % mdl_NRD_R=fitlm(theTable, 'meanNRD_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_FA_L=fitlm(theTable, 'meanFA_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_FA_R=fitlm(theTable, 'meanFA_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_RD_L=fitlm(theTable, 'meanRD_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_RD_R=fitlm(theTable, 'meanRD_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_AxD_L=fitlm(theTable, 'meanAxD_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_AxD_R=fitlm(theTable, 'meanAxD_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % mdl_MD_L=fitlm(theTable, 'meanMD_fx_dotfimbriaL_centerline~dx+diffmotion')
% % mdl_MD_R=fitlm(theTable, 'meanMD_fx_dotfimbriaR_centerline~dx+diffmotion')
% % 
% % 
% % 
% % %%
% % %IN TRIMMED TRKS
% % 
% % mdl_GFA_L=fitlm(theTable, 'meanGFA_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
% % mdl_GFA_R=fitlm(theTable, 'meanGFA_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')
% % 
% % mdl_NQA0_L=fitlm(theTable, 'meanNQA0_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
% % mdl_NQA0_R=fitlm(theTable, 'meanNQA0_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')
% % 
% % 
% % %Other Interesting Metrics
% % mdl_FA_L=fitlm(theTable, 'meanFA_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
% % mdl_FA_R=fitlm(theTable, 'meanFA_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')
% % 
% % mdl_RD_L=fitlm(theTable, 'meanRD_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
% % mdl_RD_R=fitlm(theTable, 'meanRD_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')
% % 
% % mdl_AxD_L=fitlm(theTable, 'meanAxD_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
% % mdl_AxD_R=fitlm(theTable, 'meanAxD_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')
% % 
% % mdl_MD_L=fitlm(theTable, 'meanMD_fx_dotfimbriaL_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaL_trimmedx2')
% % mdl_MD_R=fitlm(theTable, 'meanMD_fx_dotfimbriaR_trimmedx2~dx+diffmotion+numsstr_fx_dotfimbriaR_trimmedx2')
% % 
% % 
% % %%
% % %Getting a filtered table...
% % dx_means=theTable(:,{'dx','meanNQA0_fx_dotfimbriaL_centerline','meanNQA0_fx_dotfimbriaR_centerline' , ...
% %       'meanNQA1_fx_dotfimbriaL_centerline','meanNQA1_fx_dotfimbriaR_centerline' , ...
% %       'meanNQA2_fx_dotfimbriaL_centerline','meanNQA2_fx_dotfimbriaR_centerline' , ...
% %         'meanQA0_fx_dotfimbriaL_centerline','meanQA0_fx_dotfimbriaR_centerline' , ...
% %     'meanQA1_fx_dotfimbriaL_centerline','meanQA1_fx_dotfimbriaR_centerline' , ...
% %     'meanQA2_fx_dotfimbriaL_centerline','meanQA2_fx_dotfimbriaR_centerline' , ...
% %     'meanISO_fx_dotfimbriaL_centerline','meanISO_fx_dotfimbriaR_centerline' , ...
% %     'meanRDI1L_fx_dotfimbriaL_centerline','meanRDI1L_fx_dotfimbriaR_centerline' , ...
% %     });
% % 
% % AA=grpstats(dx_means,'dx',{'mean','std'})
% % 
% % 
% % %%
% % %CHECKING QAs PEAKS
% % 
% % TT=readtable('../../xls/take_me_there/ADRC_161227.xlsx','Sheet','QC_peakQAs','ReadRowNames',true)
% % mdl_peakQA0s=fitlm(TT,'Max_QA0~DX+diffmotion')
% % mdl_peakQA0s=fitlm(TT,'Max_QA0~DX')
% % 
% % mdl_peakQA1s=fitlm(TT,'Max_QA1~DX+diffmotion')
% % mdl_peakQA1s=fitlm(TT,'Max_QA1~DX')
% % 
% % mdl_peakQA2s=fitlm(TT,'Max_QA2~DX+diffmotion')
% % mdl_peakQA2s=fitlm(TT,'Max_QA2~DX')
% 
% % 
% % figure
% % gscatter(TT.Loc_QA0_X,TT.Max_QA0,TT.DX,'br','xo')
% % xlabel('X Coordinate');
% % ylabel('Max QA0');
% % figure
% % gscatter(TT.Loc_QA1_X,TT.Max_QA1,TT.DX,'br','xo')
% % xlabel('X Coordinate');
% % ylabel('Max QA1');
% % figure
% % gscatter(TT.Loc_QA2_X,TT.Max_QA2,TT.DX,'br','xo')
% % xlabel('X Coordinate');
% % ylabel('Max QA2');
% 
% %Check the genu as the max QA0
% %highest or average value? 
% %and the fornix

