%matlab version used: R2015b (8.6.0.267246)
%Read_Fimbra
%Rodrigo Perea -->  rpereacamargo@mgh.harvard.edu
%Objective: To read necessary dependencies for a tract analyses! 

%Dependencies: 
%/Users/rdp20/Dropbox/Martinos/Scripts/matlab_scripts/trk_landmarks
%/Users/rdp20/Dropbox/Martinos/Scripts/matlab_scripts/dependencies

clear all;
clc;
%%
%==========================================================================
% INITIALIZING ROIs USED IN THE ANALYSES 
%DOT_FORNIX ROI:
ROI_FX_DOT=rotrk_list('../../ROIs/ROI_dotfornix','ROI_dotfornix_','.nii');
%FIMBRIAL ROI:
ROI_FX_FIMBRIA_L=rotrk_list('../../ROIs/ROI_fimbriaL/goodOri','','_dwi_lh_Fimbria.nii');
%FIMBRIAR ROI:
ROI_FX_FIMBRIA_R=rotrk_list('../../ROIs/ROI_fimbriaR/goodOri','','_dwi_rh_Fimbria.nii');

%GFA:
GFA=rotrk_list('../../DIFFMETRICS/GFA/','','.src.gz.odf8.f3.rdi.gqi.1.25.fib.gz.gfa.nii','','GFA');
%QA0:
QA0=rotrk_list('../../DIFFMETRICS/QA0/','','.src.gz.odf8.f3.rdi.gqi.1.25.fib.gz.qa0.nii','','QA0');
%QA1:
QA1=rotrk_list('../../DIFFMETRICS/QA1/','','.src.gz.odf8.f3.rdi.gqi.1.25.fib.gz.qa1.nii','','QA1');
%QA2:
QA2=rotrk_list('../../DIFFMETRICS/QA2/','','.src.gz.odf8.f3.rdi.gqi.1.25.fib.gz.qa2.nii','','QA2');
%ISO:
ISO=rotrk_list('../../DIFFMETRICS/ISO/','','.src.gz.odf8.f3.rdi.gqi.1.25.fib.gz.iso.nii','','ISO');
%RDI1L:
RDI1L=rotrk_list('../../DIFFMETRICS/RDI1L/','','.src.gz.odf8.f3.rdi.gqi.1.25.fib.gz.rdi1L.nii','','RDI1L');
%NQA0:
NQA0=rotrk_list('../../DIFFMETRICS/NQA0/','','.src.gz.odf8.f3.rdi.gqi.1.25.fib.gz.nqa0.nii','','NQA0');

%NQA0_fx:
NQA0_FX=rotrk_list('../../DIFFMETRICS/NQA0_FX/','','_nqa0_from_fx_peak.nii','','NQA0_FX');

%NQA0_genu:
NQA0_GENU=rotrk_list('../../DIFFMETRICS/NQA0_GENU/','','_nqa0_from_genu_peak.nii','','NQA0_GENU');

%NQA1:
NQA1=rotrk_list('../../DIFFMETRICS/NQA1/','','.src.gz.odf8.f3.rdi.gqi.1.25.fib.gz.nqa1.nii','e','NQA1');
%NQA2:
NQA2=rotrk_list('../../DIFFMETRICS/NQA2/','','.src.gz.odf8.f3.rdi.gqi.1.25.fib.gz.nqa2.nii','','NQA2');
%FA:
FA=rotrk_list('../../DIFFMETRICS/FA/','','_FA.nii','','FA');
%RD:
RD=rotrk_list('../../DIFFMETRICS/RD/','','_RD.nii','','RD');
%AxD:
AxD=rotrk_list('../../DIFFMETRICS/AxD/','','_L1.nii','','AxD');
%MD:
MD=rotrk_list('../../DIFFMETRICS/MD/','','_MD.nii','','MD');

DIFFMETRICS=[ GFA ; NQA0; NQA1; NQA2; NQA0_FX; NQA0_GENU ; QA0; QA1; QA2; RDI1L; ISO; FA; RD; MD; AxD];


%CHECK THAT DIFFMETRICS ARE IN THE SAME ID ORDER AND WITH THE SAME ID
[flagok_diffmetric, bad_diff ] = rotrk_check_diffmetrics(GFA,NQA0,NQA1,NQA2,QA0,QA1,FA,RD,AxD,MD);
if flagok_diffmetric ~= 0
    error(['Something is wrong with ' str2num(bad_diff) 'th argument. Proably the ' num2str(flagok_diffmetric) 'th ROI' ] );
end
clear flagok_diffmetric bad_diff
%~~end of checking diffmetrics. 

%TRKS:
TRKS_FX_DOT=rotrk_list('../../TRKS/TRKS_dotfornix/','trk_ROIdot_ROA178noAC_s500k_','.trk');

TRKS_FX_DOTFIMBRIA_L=rotrk_list('../../TRKS/TRKS_dotFimbriaL_seedfimbria/','trk_','_ROIdot_SEEDfimbriaL_ROA178noAC_s10k_40deg_nqathresh.02.trk');
TRKS_FX_DOTFIMBRIA_R=rotrk_list('../../TRKS/TRKS_dotFimbriaR_seedfimbria/','trk_','_ROIdot_SEEDfimbriaR_ROA178noAC_s10k_40deg_nqathresh.02.trk');

TRKS_FX_FIMBRIA_L=rotrk_list('../../TRKS/TRKS_fimbriaL/','trk_','_ROIfimbriaL_ROA178noAC_s500k_40degree_nqathresh.02.trk');
TRKS_FX_FIMBRIA_R=rotrk_list('../../TRKS/TRKS_fimbriaR/','trk_','_ROIfimbriaR_ROA178noAC_s500k_40degree_nqathresh.02.trk');

%ReadXLS:
xls_DATA=rotrk_readxls('../../xls/take_me_there/ADRC_170123.xlsx','AD23NC23_to_MATLAB');