%
%RECORDING NIIS
%for each of 2landmarks variables (centerlines and
%trimmed volumes)

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
    %Recording bilaterally and unilateral splits
    for tohide=1:1
        vol_input=GFA{1};
        %DUE TO PROBLEM WITH MISALIGMENT, OUR NEWER WAy OF DOING THIS IS ( instead of 'splix')
        %IS BY   masking out dilated WM_L/R masks coming from FreeSurfer previously aligned to dwi space
        system('mkdir -p ./niis/niis_fx_dot_bil_untrimmed/');
        system('mkdir -p ./niis/niis_fx_dot_unilat_untrimmed');
        
        for ii=1:numel(TRKS_FX_DOT_trimmed)
            disp (['In ' TRKS_FX_DOT_trimmed{ii}.id ] )
            %$Filenames to be outputted
            BIL_OUT=['./niis/niis_fx_dot_bil_untrimmed/' TRKS_FX_DOT_trimmed{ii}.id '_fx_dot_bil_untrimmed.nii' ];
            L_OUT=['./niis/niis_fx_dot_unilat_untrimmed/' TRKS_FX_DOT_trimmed{ii}.id '_fx_dot_unilat_L_untrimmed.nii.gz' ];
            R_OUT=['./niis/niis_fx_dot_unilat_untrimmed/' TRKS_FX_DOT_trimmed{ii}.id '_fx_dot_unilat_R_untrimmed.nii.gz' ];
            %FreeSurfer left and right location parcellations (~Keep in mind CSF will be on both unilats).
            L_WM_DIL=['../../destrieux/' TRKS_FX_DOT_trimmed{ii}.id '_destrieux/dwi_Left-side_DIL.nii.gz' ];
            R_WM_DIL=['../../destrieux/' TRKS_FX_DOT_trimmed{ii}.id '_destrieux/dwi_Right-side_DIL.nii.gz' ];
            try
                %Bilateral niis...
                rotrk_trk2roi(TRKS_FX_DOT_trimmed{ii}.header,TRKS_FX_DOT_trimmed{ii}.sstr, ...
                    vol_input,  BIL_OUT )
            catch
                error(['Could create split values for(bilateral): ' TRKS_FX_DOT_trimmed{ii}.id ]);
            end
            
            %Right side...
            try
                %getting rid of left side and...
                system([ '/usr/local/fsl/bin/fslmaths ' BIL_OUT ' -mas ' R_WM_DIL ' ' R_OUT ]);
            catch
                error(['Could not create split values for(right): ' TRKS_FX_DOT_trimmed{ii}.id ]);
            end
            %Left side...
            
            try
                %getting rid of left side and...
                system([ '/usr/local/fsl/bin/fslmaths ' BIL_OUT ' -mas ' L_WM_DIL ' ' L_OUT ]);
            catch
                error(['Could not create split values for(left): ' TRKS_FX_DOT_trimmed{ii}.id ]);
            end
            
            clear BIL_OUT L_OUT R_OUT R_WM_DIL L_WM_DIL
        end
    end

%%
% %RECORDING FIMBRIAS FORNIXES
% for tohide=1:1
%     %FimbriaL
%     system('mkdir -p ./niis/niis_fx_fimbriaL/');
%      vol_input=GFA{1};
%     for ii=1:numel(TRKS_FX_FIMBRIA_L)
%         rotrk_trk2roi(TRKS_FX_FIMBRIA_L{ii}.header,TRKS_FX_FIMBRIA_L{ii}.sstr ...
%             ,vol_input,['./niis/niis_fx_fimbriaL/' ...
%             TRKS_FX_FIMBRIA_L{ii}.id '_fx_fimbriaL.nii']);
%     end
%     
%     %FimbriaR
%     system('mkdir -p ./niis/niis_fx_fimbriaR/');
%     for ii=1:numel(TRKS_FX_FIMBRIA_R)
%         rotrk_trk2roi(TRKS_FX_FIMBRIA_R{ii}.header,TRKS_FX_FIMBRIA_R{ii}.sstr ...
%             ,vol_input,['./niis/niis_fx_fimbriaR/' ...
%             TRKS_FX_FIMBRIA_R{ii}.id '_fx_fimbriaR.nii']);
%     end
%     
% disp('Gzipping left...');
% system( 'gzip ./niis/niis_fx_fimbriaL/*.nii');
% 
% disp('Gzipping right side...');
% system( 'gzip ./niis/niis_fx_fimbriaR/*.nii');
% end




%RECORDING TRKS....
%%
%%TRIMMED DOT FORNIXES
for ii=1:numel(TRKS_FX_DOT_trimmed)
    system('mkdir -p ./trks/fx_dot_trimmed/');
    rotrk_write(TRKS_FX_DOT_trimmed{ii}.header,TRKS_FX_DOT_trimmed{ii}.sstr ...
        ,['./trks/fx_dot_trimmed/' ...
        TRKS_FX_DOT_trimmed{ii}.id '_fx_dot_trimmed.trk']);
    disp( [ 'TRKS_FX_trimeed_DOT_' TRKS_FX_DOT_trimmed{ii}.id ' generated.'] )
end
system( 'gzip ./trks/fx_dot_trimmed/*.trk');

%%
%%TRIMMED DOTFIMBRIA_L FORNIXES
dir_name='./trks/fx_dotfimL_trimmed/';
disp([ 'IN =====> ' dir_name ] );
for ii=1:numel(TRKS_FX_trimmed_L)
    dir_name='./trks/fx_dotfimL_trimmed/';
    system([ 'mkdir -p ' dir_name ]);
    rotrk_write(TRKS_FX_trimmed_L{ii}.header,TRKS_FX_trimmed_L{ii}.sstr ...
        ,[ dir_name  TRKS_FX_trimmed_L{ii}.id '_fx_dotfimL_trimmed.trk']);
    
end
system( [ 'gzip ' dir_name '*.trk' ]);
disp([ '=====< DONE ' dir_name ] );

%%
%%TRIMMED DOTFIMBRIA_R FORNIXES
dir_name='./trks/fx_dotfimR_trimmed/';
disp([ 'IN =====> ' dir_name ] );
for ii=1:numel(TRKS_FX_trimmed_R)
    dir_name='./trks/fx_dotfimR_trimmed/';
    system([ 'mkdir -p ' dir_name ]);
    rotrk_write(TRKS_FX_trimmed_R{ii}.header,TRKS_FX_trimmed_R{ii}.sstr ...
        ,[ dir_name  TRKS_FX_trimmed_R{ii}.id '_fx_dotfimL_trimmed.trk']);
    
end
system( [ 'gzip ' dir_name '*.trk' ]);
disp([ '=====< DONE ' dir_name ] );


%%
%%CENTERLINE DOTFIMBRIA_L FORNIXES
dir_name='./trks/fx_dotfimL_centerline/';
disp([ 'IN =====> ' dir_name ] );
for ii=1:numel(TRKS_FX_centerline_L)
    dir_name='./trks/fx_dotfimL_centerline/';
    system([ 'mkdir -p ' dir_name ]);
    rotrk_write(TRKS_FX_centerline_L{ii}.header,TRKS_FX_centerline_L{ii}.sstr ...
        ,[ dir_name  TRKS_FX_centerline_L{ii}.id '_fx_dotfimL_trimmed.trk']);
    
end
system( [ 'gzip ' dir_name '*.trk' ]);
disp([ '=====< DONE ' dir_name ] );

%%
%%TRIMMED DOTFIMBRIA_R FORNIXES
dir_name='./trks/fx_dotfimR_centerline/';
disp([ 'IN =====> ' dir_name ] );
for ii=1:numel(TRKS_FX_centerline_R)
    dir_name='./trks/fx_dotfimR_centerline/';
    system([ 'mkdir -p ' dir_name ]);
    rotrk_write(TRKS_FX_centerline_R{ii}.header,TRKS_FX_centerline_R{ii}.sstr ...
        ,[ dir_name  TRKS_FX_centerline_R{ii}.id '_fx_dotfimL_trimmed.trk']);
    
end
system( [ 'gzip ' dir_name '*.trk' ]);
disp([ '=====< DONE ' dir_name ] );
