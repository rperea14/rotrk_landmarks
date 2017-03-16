%Here we will be adding additional trks that were reconstructed separate
%from the fornix bundle. In this case I'll be working with the genu and
%splenium of the corpus callosum.
%
%

clear ROI_GENU_L ROI_GENU_R
clear TRKS_GENU
clear TRKS_GENU_trimmed TRKS_GENU_centerline

%WORKING ON THE GENU....
%Initializing ROIs:
ROI_GENU_L=rotrk_list('../../ROIs/ROIs_genu_bt/','TER_genu_L_','.nii');
ROI_GENU_R=rotrk_list('../../ROIs/ROIs_genu_bt/','TER_genu_R_','.nii');
%Initializing TRKS:
TRKS_GENU=rotrk_list('../../TRKS/TRKS_genu/','trk_ROIsgenusLR_10k_','.trk');
for genu_hide=1:1
    REF_VOL=ROI_GENU_L{1}; %Reference volume for image dimensions (the scripts assumes all the volumes have the same dimensions
    %Reading TRKS and trimming in the same loop:
    for ii=1:numel(TRKS_GENU)
        [ TRKS_GENU{ii} ] = rotrk_read(TRKS_GENU{ii}.filename,TRKS_GENU{ii}.id,REF_VOL,'trk_genu');
        %Trimming will occur in the plane the ROIs were creates and assumes left
        %and right ROIs were created in the same plane
        for jj=1:numel(ROI_GENU_L)
            if strcmp(ROI_GENU_L{jj}.id, TRKS_GENU{ii}.id )
                for kk=1:numel(ROI_GENU_R)
                    if strcmp(ROI_GENU_R{kk}.id, TRKS_GENU{ii}.id )
                        disp([ 'trimming streamlines for ID: ' TRKS_GENU{ii}.id  ' index: ' num2str(ii) ] );
                        %Setting starting point closer to the L_ROI...
                        TRKS_GENU{ii}=rotrk_flip(TRKS_GENU{ii},[ rotrk_ROImean(ROI_GENU_L{jj}.filename) ] );
                        %trimming...
                        [ TRKS_GENU_trimmed{ii} ] = rotrk_trimmedbyROI(TRKS_GENU{ii},ROI_GENU_R{kk}, 'genu',ROI_GENU_L{jj});
                        
                      
                    end
                end
            end
        end
    end
    %%
    %Adding xls data and
    for ii=1:numel(TRKS_GENU)
    end
    
    %Adding data values:
    TRKS_GENU_trimmed = rotrk_add_xls(xls_DATA,TRKS_GENU_trimmed);
    
    %Adding the scalar variables and creating a centerline...
    for ii=1:numel(TRKS_GENU_trimmed)
        for pp=1:size(DIFFMETRICS,2)
            if strcmp(cell2char(DIFFMETRICS{1,pp}.id), TRKS_GENU_trimmed{ii}.id)
                TRKS_GENU_trimmed{ii} = rotrk_add_sc(TRKS_GENU_trimmed{ii}, DIFFMETRICS(:,pp));
                disp([ 'centerline trimming...' cell2char(DIFFMETRICS{1,pp}.id) ] )
                TRKS_GENU_centerline{ii} = rotrk_centerline(TRKS_GENU_trimmed{ii}, 'high_sc', 'GFA');
            end
        end
    end
end

% %%
% %%SAVING NISS and TRKS
% for to_save=1:1
%     for ii=1:numel(TRKS_GENU)
%                     %Saving TRKs...
%                     system('mkdir -p ./trks/genu_trimmed');
%                     rotrk_write(TRKS_GENU_trimmed{ii}.header,TRKS_GENU_trimmed{ii}.sstr,[ './trks/genu_trimmed/' TRKS_GENU_trimmed{ii}.id '_genu_trimmed.trk']);
%     
%                     %Saving TRKS to ROIs...
%                     system('mkdir -p ./niis/niis_genu_trimmed');
%                     rotrk_trk2roi(TRKS_GENU_trimmed{ii}.header,TRKS_GENU_trimmed{ii}.sstr,REF_VOL, ['./niis/niis_genu_trimmed/' TRKS_GENU_trimmed{ii}.id '_genu_trimmed.nii']);
%                 
%                     %Saving centerline TRKs...
%                     system('mkdir -p ./trks/genu_centerline');
%                     rotrk_write(TRKS_GENU_centerline{ii}.header,TRKS_GENU_centerline{ii}.sstr,[ './trks/genu_centerline/' TRKS_GENU_centerline{ii}.id '_genu_centerline.trk']);
%     
%                     %Saving centerline TRKS to ROIs...
%                     system('mkdir -p ./niis/niis_genu_centerline');
%                     rotrk_trk2roi(TRKS_GENU_centerline{ii}.header,TRKS_GENU_centerline{ii}.sstr,REF_VOL, ['./niis/niis_genu_centerline/' TRKS_GENU_centerline{ii}.id '_genu_centerline.nii']);
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                             DONE WITH THE GENU                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

