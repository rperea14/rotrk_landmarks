function [ new_DATA ] = rotrk_xls(filePath, sheet, group_flag)
%function [ new_DATA ] = rotrk_xls(filePath, sheet, group_flag)
% Output:
%Somer examples: 
% xls_DATA.id --> 'MRI Session_ID' (mandatory to make the comparison
% xls_DATA.dx --> 'Dx'
% xls_DATA.age --> 'Age'
% xls_DATA.sex --> 'Gender'
% xls_DATA.motion --> 'Motion'


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Using xls_read
[DATA,NUM, RAW ] = xlsread(filePath, sheet);

HERE=1;

HEADER=RAW(1,:);

if nargin < 3
    group_flag='ADRC_n46';
end
for ii=1:size(HEADER,2)
    if strcmp(group_flag,'ADRC_n46')
        if strcmp(HEADER(ii),'MRI_Session_ID')
            new_DATA.id=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'Age')
            new_DATA.age=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'Yrs_Edu')
            new_DATA.education=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'HABorCONTOME')
            new_DATA.protocol=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'Dx')
            new_DATA.dx=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'Dx_pseudo')
            new_DATA.dx_pse=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'Gender')
            new_DATA.sex=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'diffMotion')
            new_DATA.diffmotion=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'volROI_fimbriaL')
            new_DATA.fimbria_volDIL_L=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'volROI_fimbriaR')
            new_DATA.fimbria_volDIL_R=RAW(2:end,ii);
        %This two elseifs are keep (for compatibility with previous version
        %(before Aug 2017):
        elseif strcmp(HEADER(ii),'dwi_DIL_fimbria_vol_L(mm)')
            new_DATA.fimbria_volDIL_L=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'dwi_DIL_fimbria_vol_R(mm)')
            new_DATA.fimbria_volDIL_R=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'Matched_ID')
            new_DATA.matchid=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'def_voltrx_FX_DOT_R')
            new_DATA.def_voltrx_FX_DOT_R_mm3=RAW(2:end,ii);    
        elseif strcmp(HEADER(ii),'def_voltrx_FX_DOT_L')
            new_DATA.def_voltrx_FX_DOT_L_mm3=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'def_voltrx_FX_DOT_bil')
            new_DATA.def_voltrx_FX_DOT_BIL_mm3=RAW(2:end,ii);
        
        elseif strcmp(HEADER(ii),'trimmed_voltrx_FX_DOTFIM_R')
            new_DATA.trimmed_voltrx_FX_DOTFIM_L_mm3=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'trimmed_voltrx_FX_DOTFIM_L')
            new_DATA.trimmed_voltrx_FX_DOTFIM_R_mm3=RAW(2:end,ii);
            
            
            
            
        elseif strcmp(HEADER(ii),'n23AgeMatchedCodedPairs')
            new_DATA.agematched=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'T1_hippoVol_L(mm)')
            new_DATA.T1_hippovol_L=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'T1_hippoVol_R(mm)')
            new_DATA.T1_hippovol_R=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'vol_R_CA1_subiculum')
            new_DATA.CA1Subvol_R=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'vol_L_CA1_subiculum')
            new_DATA.CA1Subvol_L=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'tractx_L_hippo2thal')
            new_DATA.tractx_L_hippo2thal=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'tractx_L_thal2hippo')
            new_DATA.tractx_L_thal2hippo=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'tractx_R_hippo2thal')
            new_DATA.tractx_R_hippo2thal=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'tractx_R_thal2hippo')
            new_DATA.tractx_R_thal2hippo=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'TAU_Age')
            new_DATA.tauAge=RAW(2:end,ii);
        elseif strcmp(HEADER(ii),'Handedness_code')
            new_DATA.Handedness=RAW(2:end,ii);
            
        elseif strcmp(HEADER(ii),'after_vol_TRKS_FX_DOT_bil(mm)')
            new_DATA.vol_FX_DOT_bil=RAW(2:end,ii);
        end
        
        
    elseif strcmp(group_flag,'TAU_CONTOME')
         if strcmp(HEADER(ii),'MRI Session_ID')
            new_DATA.id=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'IDs')
             new_DATA.id=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'Dx')
             new_DATA.dx=RAW(2:end,ii);             
         elseif strcmp(HEADER(ii),'Age')
             new_DATA.age=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'TAU_Age')
             new_DATA.Tau_age=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'Gender')
             new_DATA.sex=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'Yrs_Edu')
             new_DATA.education=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'MMSE')
             new_DATA.mmse=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'TAU_FS_SUVR_PVC_entorhinal_lh')
             new_DATA.tau_entho_lh=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'TAU_FS_SUVR_PVC_entorhinal_rh')
             new_DATA.tau_entho_rh=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'TAU_FS_SUVR_PVC_entorhinal_bh')
             new_DATA.tau_entho_lh=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'TAU_FS_SUVR_PVC_inferiortemporal_lh')
             new_DATA.tau_inftemp_lh=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'TAU_FS_SUVR_PVC_inferiortemporal_rh')
             new_DATA.tau_inftemp_rh=RAW(2:end,ii);
         elseif strcmp(HEADER(ii),'TAU_FS_SUVR_PVC_inferiortemporal_bh')
             new_DATA.tau_inftemp_bh=RAW(2:end,ii);
         end
         
    elseif strcmp(group_flag,'all')
        %Move all the values from xls to the new_DATA struct
        for jj=1:numel(HEADER)
            if strcmp(HEADER(ii),'MRI_Session_ID')
                new_DATA.id=RAW(2:end,ii);
            else
                new_DATA.(HEADER{ii})=RAW(2:end,ii);
            end
        end
    end
end


%Adding additional values...
if strcmp(group_flag,'ADRC_n46')
    counter=1;
    for jj=62:numel(HEADER)
        new_DATA.(HEADER{jj})=RAW(2:end,jj);
        counter=counter+1;
    end
end