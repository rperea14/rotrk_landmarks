%Here we will be adding additional trks that were reconstructed separate
%from the fornix bundle. In this case I'll be working with the genu and
%splenium of the corpus callosum.
%
%



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
        [ hdr_GENU_tmp{ii},sstr_GENU_tmp{ii} ] = rotrk_read(cell2char(TRKS_GENU{ii}.filename),cell2char(TRKS_GENU{ii}.id),REF_VOL);
      
        %Trimming will occur in the plane the ROIs were creates and assumes left
        %and right ROIs were created in the same plane
        for jj=1:numel(ROI_GENU_L)
            if strcmp(ROI_GENU_L{jj}.id, hdr_GENU_tmp{ii}.id )
                disp([ 'trimming streamlines for ID: ' hdr_GENU_tmp{ii}.id  ' index: ' num2str(ii)] )
                %trimming...
                [ hdr_GENU2{ii}, sstr_GENU2{ii} ] = rotrk_trimmedbyROI(hdr_GENU_tmp{ii},sstr_GENU_tmp{ii},ROI_GENU_R{jj}, 'genu',ROI_GENU_L{jj});
                
                %Setting starting point closer to the L_ROI...
                sstr_GENU2{ii}=rotrk_flip(hdr_GENU2{ii}, sstr_GENU2{ii},[ rotrk_ROImean(ROI_GENU_L{jj}.filename) ] );
                
                %Trimming streamlines that go beyond the ROI...
                [ hdr_GENU{ii}, sstr_GENU{ii} ] = rotrk_trimmedbyROI(hdr_GENU2{ii},sstr_GENU2{ii},ROI_GENU_L{jj}, 'withinROI',ROI_GENU_R{jj});
                
                %Applying the centerline strategy
                %!!! ASSUMING NQA and NRD have the same length and same id
                %values!!!
                for kk=1:numel(NRD)
                    if strcmp( hdr_GENU_tmp{ii}.id, NRD{kk}.id)
                        [ hdr_GENUc{ii}, sstr_GENUc{ii} ] =rotrk_centerline(hdr_GENU{ii},sstr_GENU{ii},28,'high_sc', [ NRD{kk} NQA0{kk} NMD{kk} NRD{kk}] );
                        %%Adding diffmetrics to hdr_GENU
                        [ hdr_GENU{ii}, sstr_GENU{ii} ] = rotrk_add_sc(hdr_GENU{ii},sstr_GENU{ii},NRD{kk},'NRD');
                        [ hdr_GENU{ii}, sstr_GENU{ii} ] = rotrk_add_sc(hdr_GENU{ii},sstr_GENU{ii},NQA0{kk},'NQA0');
                        [ hdr_GENU{ii}, sstr_GENU{ii} ] = rotrk_add_sc(hdr_GENU{ii},sstr_GENU{ii},NMD{kk},'NMD');
                        [ hdr_GENU{ii}, sstr_GENU{ii} ] = rotrk_add_sc(hdr_GENU{ii},sstr_GENU{ii},NRD{kk},'NRD');
                    end
                end
                
                
                
                
                %SAVING NISS and TRKS
                for to_save=1:1
                    %                 %Saving TRKs...
                    %                 system('mkdir -p ./trks/genu_trimmed');
                    %                 rotrk_write(hdr_GENU{ii},sstr_GENU{ii},[ './trks/genu_trimmed/genu_trimmed_' hdr_GENU{ii}.id '.trk']);
                    %
                    %                 %Saving TRKS to ROIs...
                    %                 system('mkdir -p ./niis/genu_trimmed');
                    %                 rotrk_trk2roi(hdr_GENU{ii},sstr_GENU{ii},REF_VOL, ['./niis/genu_trimmed/' hdr_GENU{ii}.id '_genu_trimmed.nii']);
                    %                 %Saving centerline TRKs...
                    %                 system('mkdir -p ./trks/genu_centerline');
                    %                 rotrk_write(hdr_GENUc{ii},sstr_GENUc{ii},[ './trks/genu_centerline/genu_centerline_' hdr_GENU{ii}.id '.trk']);
                    %
                    %                 %Saving centerline TRKS to ROIs...
                    %                 system('mkdir -p ./niis/genu_centerline');
                    %                 rotrk_trk2roi(hdr_GENUc{ii},sstr_GENUc{ii},REF_VOL, ['./niis/genu_centerline/' hdr_GENU{ii}.id '_genu_centerline.nii']);
                end
            end
        end
    end
    %Adding data values:
    hdr_GENU = rotrk_add_xls(xls_DATA,hdr_GENU);
    hdr_GENUc = rotrk_add_xls(xls_DATA,hdr_GENUc);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                             DONE WITH THE GENU                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                              STARTING THE SPLENIUM                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Reading ROIs...
ROI_SPL_L=rotrk_list('../../ROIs/ROIs_splenium_bt/','TER_splenium_L_','.nii');
ROI_SPL_R=rotrk_list('../../ROIs/ROIs_splenium_bt/','TER_splenium_R_','.nii');

%Reading TRKS...
TRKS_SPL=rotrk_list('../../TRKS/TRKS_splenium/','trk_ROISspleniumLR_10k_','.trk');
REF_VOL=ROI_SPL_L{1}; %Reference volume for image dimensions (the scripts assumes all the volumes have the same dimensions


%Reading TRKS and trimming in the same loop:
for ii=1:numel(TRKS_DOT)
    [ hdr_SPL_tmp{ii},sstr_SPL_tmp{ii} ] = rotrk_read(cell2char(TRKS_SPL{ii}.filename),cell2char(TRKS_SPL{ii}.id),REF_VOL);
    %Trimming will occur in the plane the ROIs were creates and assumes left
    %and right ROIs were created in the same plane
    for jj=1:numel(ROI_SPL_L)
        if strcmp(hdr_SPL_tmp{ii}.id, ROI_SPL_L{jj}.id)
            disp([ 'trimming streamlines for ID: ' hdr_SPL_tmp{ii}.id  ' index: ' num2str(ii)] )
            
            %trimming strealines beyond the splenium
            [ hdr_SPL2{ii}, sstr_SPL2{ii} ] = rotrk_trimmedbyROI(hdr_SPL_tmp{ii},sstr_SPL_tmp{ii},ROI_SPL_R{jj}, 'splenium',ROI_SPL_L{jj});
            
            %Setting starting point closer to the L_ROI...
            sstr_SPL2{ii}=rotrk_flip(hdr_SPL2{ii}, sstr_SPL2{ii},[ rotrk_ROImean(ROI_SPL_L{jj}.filename) ] );
            
            %Trimming streamlines that go beyond the ROI...
            [ hdr_SPL{ii}, sstr_SPL{ii} ] = rotrk_trimmedbyROI(hdr_SPL2{ii},sstr_SPL2{ii},ROI_SPL_L{jj}, 'withinROI',ROI_SPL_R{jj});

            %Applying the centerline strategy
            %!!! ASSUMING NQA and NRD have the same length and same id
            %values!!!
            for kk=1:numel(NRD)
                if strcmp( hdr_SPL_tmp{ii}.id, NRD{kk}.id)
                    [ hdr_SPLc{ii}, sstr_SPLc{ii} ] =rotrk_centerline(hdr_SPL{ii},sstr_SPL{ii},23,'high_sc', [ NRD{kk} NQA0{kk} NMD{kk} NRD{kk}] );
                    %%Adding diffmetrics to hdr_GENU
                    [ hdr_SPL{ii}, sstr_SPL{ii} ] = rotrk_add_sc(hdr_SPL{ii},sstr_SPL{ii},NRD{kk},'NRD');
                    [ hdr_SPL{ii}, sstr_SPL{ii} ] = rotrk_add_sc(hdr_SPL{ii},sstr_SPL{ii},NQA0{kk},'NQA0');
                    [ hdr_SPL{ii}, sstr_SPL{ii} ] = rotrk_add_sc(hdr_SPL{ii},sstr_SPL{ii},NRD{kk},'NMD');
                    [ hdr_SPL{ii}, sstr_SPL{ii} ] = rotrk_add_sc(hdr_SPL{ii},sstr_SPL{ii},NQA0{kk},'NRD');
                end

            end
            
            %SAVING NISS and TRKS
            for to_save=1:1
%                 %Saving TRKs...
%                 system('mkdir -p ./trks/splenium_trimmed');
%                 rotrk_write(hdr_SPL{ii},sstr_SPL{ii},[ './trks/splenium_trimmed/splenium_trimmed_' hdr_SPL{ii}.id '.trk']);
%                 
%                 %Saving TRKS to ROIs...
%                 system('mkdir -p ./niis/splenium_trimmed');
%                 rotrk_trk2roi(hdr_SPL{ii},sstr_SPL{ii},REF_VOL, ['./niis/splenium_trimmed/' hdr_SPL{ii}.id '_splenium_trimmed.nii']);
%                 %Saving centerline TRKs...
%                 system('mkdir -p ./trks/splenium_centerline');
%                 rotrk_write(hdr_SPLc{ii},sstr_SPLc{ii},[ './trks/splenium_centerline/splenium_centerline_' hdr_SPL{ii}.id '.trk']);
%                 
%                 %Saving centerline TRKS to ROIs...
%                 system('mkdir -p ./niis/splenium_centerline');
%                 rotrk_trk2roi(hdr_SPLc{ii},sstr_SPLc{ii},REF_VOL, ['./niis/splenium_centerline/' hdr_SPL{ii}.id '_splenium_centerline.nii']);
             end
        end
    end
end
%Adding data values:
hdr_SPL = rotrk_add_xls(xls_DATA,hdr_SPL);
hdr_SPLc = rotrk_add_xls(xls_DATA,hdr_SPLc);
