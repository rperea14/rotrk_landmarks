%%
%INITIALIZE DIFFMETRICS TO BE PASSED
%% DEFINED IN STEP 1


%%
%FLIP ALL TARGETS SO COORDINATES START AT THE ROI
%AND ADDING SPECIFIC SCALARS
%TRKS_FX_DOT:
disp('Flipping and adding scalars to closest ROI for TRKS_FX_DOT...')
for ii=1:numel(TRKS_FX_DOT)
    %disp(['In ii: ' num2str(ii) ] );
    for jj=1:numel(ROI_FX_DOT)
        if strcmp(TRKS_FX_DOT{ii}.id,ROI_FX_DOT{jj}.id)
            TRKS_FX_DOT{ii}=rotrk_flip(TRKS_FX_DOT{ii}, [ rotrk_ROImean(ROI_FX_DOT{jj})] );
            TRKS_FX_DOT_trimmed{ii}  = rotrk_trimmedbyROI(TRKS_FX_DOT{ii},ROI_FX_DOT{jj}, 'above');
        end
    end
end


%%
%TRKS_FX_FIMBRIA_L:
% disp('Flipping and adding scalars to closest ROI for TRKS_FX_FIMBRIA_L...')
% for ii=1:numel(TRKS_FX_FIMBRIA_L)
%     %disp(['In ii: ' num2str(ii) ] );
%     for jj=1:numel(ROI_FX_FIMBRIA_L)
%         if strcmp(TRKS_FX_FIMBRIA_L{ii}.id,ROI_FX_FIMBRIA_L{jj}.id)
%             TRKS_FX_FIMBRIA_L{ii}=rotrk_flip(TRKS_FX_FIMBRIA_L{ii}, [ rotrk_ROImean(ROI_FX_FIMBRIA_L{jj})] );
%             TRKS_FX_trimmed_FIMBRIA_L{ii}  = rotrk_trimmedbyROI(TRKS_FX_FIMBRIA_L{ii},ROI_FX_FIMBRIA_L{jj}, 'below');
% 
%         end
%     end
% end

%%
%TRKS_FX_FIMBRIA_R:
% disp('Flipping and adding scalars to closest ROI for TRKS_FX_FIMBRIA_R...')
% for ii=1:numel(TRKS_FX_FIMBRIA_R)
%     %disp(['In ii: ' num2str(ii) ] );
%     for jj=1:numel(ROI_FX_FIMBRIA_R)
%         if strcmp(TRKS_FX_FIMBRIA_R{ii}.id,ROI_FX_FIMBRIA_R{jj}.id)
%             TRKS_FX_FIMBRIA_R{ii}=rotrk_flip(TRKS_FX_FIMBRIA_R{ii}, [ rotrk_ROImean(ROI_FX_FIMBRIA_R{jj})] );
%             TRKS_FX_trimmed_FIMBRIA_R{ii}  = rotrk_trimmedbyROI(TRKS_FX_FIMBRIA_R{ii},ROI_FX_FIMBRIA_R{jj}, 'below');
%         end
%     end
% end



%%
%Creating the 2landmarks for each TRKS...
%it will return the trimm1ed header and strlines and the centerline heade
%and strlines
%Left Fimbria
disp('Applying rotrk_2landmarks using high_sc to selected the centerline (Left side): ')
[TRKS_FX_trimmed_L, TRKS_FX_centerline_L, TRKS_FX_trimmed_nointerp_L ] = ... 
    rotrk_2landmarks(TRKS_FX_DOTFIMBRIA_L, ROI_FX_DOT, ROI_FX_FIMBRIA_L,40, ...
    'high_sc',DIFFMETRICS, 'GFA');
%%
disp('Applying rotrk_2landmarks using high_sc to selected the centerline (Right side): ')
%Right Fimbria
[TRKS_FX_trimmed_R, TRKS_FX_centerline_R, TRKS_FX_trimmed_nointerp_R ] = ...  
    rotrk_2landmarks(TRKS_FX_DOTFIMBRIA_R, ROI_FX_DOT, ROI_FX_FIMBRIA_R,40, ...
    'high_sc',DIFFMETRICS, 'GFA');