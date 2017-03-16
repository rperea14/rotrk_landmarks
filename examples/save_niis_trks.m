%
RECORDING NIIS
for each of 2landmarks variables (centerlines and
trimmed volumes)
for tohide=1:1
%     
%     %Recording untrimmed volumes
    for tohide=1:1
        vol_input=GFA{1};
        %FimbriaL
        system('mkdir -p ./niis/niis_fx_dotfimbriaL_untrimmed/');
        for ii=1:numel(TRKS_FX_DOTFIMBRIA_L)
            rotrk_trk2roi(TRKS_FX_DOTFIMBRIA_L{ii}.header,TRKS_FX_DOTFIMBRIA_L{ii}.sstr ... 
                ,vol_input, ['./niis/niis_fx_dotfimbriaL_untrimmed/' ...
                TRKS_FX_DOTFIMBRIA_L{ii}.id '_fx_dotfimbriaL_untrimmed.nii']);
        end
        vol_input=GFA{1};
        %FimbriaR
        system('mkdir -p ./niis/niis_fx_dotfimbriaR_untrimmed/');
        for ii=1:numel(TRKS_FX_DOTFIMBRIA_R)
            rotrk_trk2roi(TRKS_FX_DOTFIMBRIA_R{ii}.header,TRKS_FX_DOTFIMBRIA_R{ii}.sstr, ... 
                vol_input, ['./niis/niis_fx_dotfimbriaR_untrimmed/' ...
                TRKS_FX_DOTFIMBRIA_R{ii}.id '_fx_dotfimbriaR_untrimmed.nii']);
        end
    end
    disp('Gzipping left side...');
    system( 'gzip ./niis/niis_fx_dotfimbriaL_untrimmed/*.nii');
    disp('Gzipping right side...');
    system( 'gzip ./niis/niis_fx_dotfimbriaR_untrimmed/*.nii');

    %%
    %Recording trimmed volumes
    for tohide=1:1
        vol_input=GFA{1};
        %FimbriaL
        system('mkdir -p ./niis/niis_fx_dotfimbriaL_trimmed/');
        for ii=1:numel(TRKS_FX_trimmed_nointerp_L)
            rotrk_trk2roi(TRKS_FX_trimmed_nointerp_L{ii}.header,TRKS_FX_trimmed_nointerp_L{ii}.sstr ...
                ,vol_input, ['./niis/niis_fx_dotfimbriaL_trimmed/' ...
                TRKS_FX_trimmed_nointerp_L{ii}.id '_fx_dotfimbriaL_trimmed.nii']);
        end
        vol_input=GFA{1};
        %FimbriaR
        system('mkdir -p ./niis/niis_fx_dotfimbriaR_trimmed/');
        for ii=1:numel(TRKS_FX_trimmed_nointerp_R)
            rotrk_trk2roi(TRKS_FX_trimmed_nointerp_R{ii}.header,TRKS_FX_trimmed_nointerp_R{ii}.sstr, ...
                vol_input, ['./niis/niis_fx_dotfimbriaR_trimmed/' ...
                TRKS_FX_trimmed_nointerp_R{ii}.id '_fx_dotfimbriaR_trimmed.nii']);
        end
    end
    disp('Gzipping left...');
    system( 'gzip ./niis/niis_fx_dotfimbriaL_trimmed/*.nii');
    disp('Gzipping right...');
    system( 'gzip ./niis/niis_fx_dotfimbriaR_trimmed/*.nii');
    
    %%
    %Recording centerline volumes
    for tohide=1:1
        vol_input=GFA{1};
        %FimbriaL
        system('mkdir -p ./niis/niis_fx_centerline_L/');
        for ii=1:numel(TRKS_FX_centerline_L)
            rotrk_trk2roi(TRKS_FX_centerline_L{ii}.header,TRKS_FX_centerline_L{ii}.sstr ...
                ,vol_input, ['./niis/niis_fx_centerline_L/' ...
                TRKS_FX_centerline_L{ii}.id '_fx_centerline_L.nii']);
        end
        vol_input=GFA{1};
        %FimbriaR
        system('mkdir -p ./niis/niis_fx_centerline_R/');
        for ii=1:numel(TRKS_FX_centerline_R)
            rotrk_trk2roi(TRKS_FX_centerline_R{ii}.header,TRKS_FX_centerline_R{ii}.sstr, ...
                vol_input, ['./niis/niis_fx_centerline_R/' ...
                TRKS_FX_centerline_R{ii}.id '_fx_centerline_R.nii']);
        end
    end
    disp('Gzipping left...');
    system( 'gzip ./niis/niis_fx_centerline_L/*.nii');
    disp('Gzipping right...');
    system( 'gzip ./niis/niis_fx_centerline_R/*.nii');
    
    
    %%
    %Recording dotfornixes (bilaterally)
    for tohide=1:1
        vol_input=GFA{1};
        %DotFornix (split in Left and right)
        system('mkdir -p ./niis/niis_fx_dot_bil')
        for ii=1:numel(TRKS_FX_DOT)
            rotrk_trk2roi(TRKS_FX_DOT{ii}.header,TRKS_FX_DOT{ii}.sstr, ...
                vol_input, ['./niis/niis_fx_dot_bil/' TRKS_FX_DOT{ii}.id '_fx_dot_bil.nii'], '');
        end
    end
    system( 'gzip ./niis/niis_fx_dot_bil/*.nii')
   
    %%
    %Recording dotfornixes (unilateral, split by x)
    for tohide=1:1
        vol_input=GFA{1};
        %DotFornix (split in Left and right)
        system('mkdir -p ./niis/niis_fx_dot_unilat')
        for ii=1:numel(TRKS_FX_DOT)
            for jj=1:numel(TRKS_FX_DOT)
                if strcmp(TRKS_FX_DOT{ii}.id,ROI_FX_DOT{jj}.id)
                    rotrk_trk2roi(TRKS_FX_DOT{ii}.header,TRKS_FX_DOT{ii}.sstr, ...
                        vol_input, ['./niis/niis_fx_dot_unilat/' TRKS_FX_DOT{ii}.id '_fx_uni.nii'], 'splitx',ROI_FX_DOT{jj});
                end
        end
    end
    system( 'gzip ./niis/niis_fx_dot_unilat/*.nii')

    
end

%
RECORDING TRKS CENTERLINES AND TRIMMED ONES
for tohide=1:1
    %FimbriaL
    system('mkdir -p ./trks/trks_fx_dotfimbriaL_trimmed/');
    system('mkdir -p ./trks/trks_fx_dotfimbriaL_centerline/');
    for ii=1:numel(TRKS_FX_trimmed_nointerp_L)
        rotrk_write(TRKS_FX_trimmed_nointerp_L{ii}.header,TRKS_FX_trimmed_nointerp_L{ii}.sstr ...
            ,['./trks/trks_fx_dotfimbriaL_trimmed/' ...
            TRKS_FX_trimmed_nointerp_L{ii}.id '_fx_dotfimbriaL_trimmed.trk']);
        rotrk_write(TRKS_FX_centerline_L{ii}.header,TRKS_FX_centerline_L{ii}.sstr ...
            ,['./trks/trks_fx_dotfimbriaL_centerline/' ...
            TRKS_FX_centerline_L{ii}.id '_fx_dotfimbriaL_centerline.trk']);
    end
    
    %FimbriaR
    system('mkdir -p ./trks/trks_fx_dotfimbriaR_trimmed/');
    system('mkdir -p ./trks/trks_fx_dotfimbriaR_centerline/');
    for ii=1:numel(TRKS_FX_trimmed_nointerp_R)
        rotrk_write(TRKS_FX_trimmed_nointerp_R{ii}.header,TRKS_FX_trimmed_nointerp_R{ii}.sstr ...
            ,['./trks/trks_fx_dotfimbriaR_trimmed/' ...
            TRKS_FX_trimmed_nointerp_R{ii}.id '_fx_dotfimbriaR_trimmed.trk']);
        rotrk_write(TRKS_FX_centerline_R{ii}.header,TRKS_FX_centerline_R{ii}.sstr ...
            ,['./trks/trks_fx_dotfimbriaR_centerline/' ...
            TRKS_FX_centerline_R{ii}.id '_fx_dotfimbriaR_centerline.trk']);
    end
    

disp('Gzipping left...');
system( 'gzip ./trks/trks_fx_dotfimbriaL_trimmed/*.trk');
system( 'gzip ./trks/trks_fx_dotfimbriaL_centerline/*.trk');

disp('Gzipping right side...');
system( 'gzip ./trks/trks_fx_dotfimbriaR_trimmed/*.trk');
system( 'gzip ./trks/trks_fx_dotfimbriaR_centerline/*.trk');
end
