%Reading tracts now...

% %Tracts from the dotfornix only:
% for ii=1:numel(TRKS_DOT)
%     [ hdr_DOT{ii}, sstr_DOT{ii} ] = trk_read(cell2char(TRKS_DOT{ii}.filename));
% end

%For orientation purposes... (all ROIs should be in the same orientation e.g. LPS)


%%
REF_VOL=ROI_FX_DOT{1};
%Dotfornix only
fprintf('\nReading TRKS_DOT...') ;
for ii=1:numel(TRKS_FX_DOT)
    [ TRKS_FX_DOT{ii}] = rotrk_read(TRKS_FX_DOT{ii}.filename,TRKS_FX_DOT{ii}.id,REF_VOL,'trk_fx_DOT');
end
fprintf('completed \n');

%%
%Fimbrias only
fprintf('\nReading TRKS_FX_FIMBRIA_L...') ;
for ii=1:numel(TRKS_FX_FIMBRIA_L)
    [ TRKS_FX_FIMBRIA_L{ii} ] = rotrk_read(TRKS_FX_FIMBRIA_L{ii}.filename,TRKS_FX_FIMBRIA_L{ii}.id,REF_VOL,'trk_fx_fimbria_L');
end
fprintf('completed \n');

fprintf('Reading TRKS_FX_FIMBRIA_R...') ;
for ii=1:numel(TRKS_FX_FIMBRIA_R)
    [ TRKS_FX_FIMBRIA_R{ii} ] = rotrk_read(TRKS_FX_FIMBRIA_R{ii}.filename,TRKS_FX_FIMBRIA_R{ii}.id,REF_VOL, 'trk_fx_fimbria_R');
end
fprintf('completed \n');

%%
fprintf('\nReading TRKS_FX_DOTFIMBRIA_L...') ;
for ii=1:numel(TRKS_FX_DOTFIMBRIA_L)
    [ TRKS_FX_DOTFIMBRIA_L{ii} ] = rotrk_read(TRKS_FX_DOTFIMBRIA_L{ii}.filename,TRKS_FX_DOTFIMBRIA_L{ii}.id,REF_VOL,'trk_fx_dotfimbriaL');
end
fprintf('completed \n');

%%
fprintf('Reading TRKS_FX_DOTFIMBRIA_R...') ;
%Tracts from the dotfimbriaR:
for ii=1:numel(TRKS_FX_DOTFIMBRIA_R)
    [ TRKS_FX_DOTFIMBRIA_R{ii} ] = rotrk_read(TRKS_FX_DOTFIMBRIA_R{ii}.filename,TRKS_FX_DOTFIMBRIA_R{ii}.id,REF_VOL,'trk_fx_dotfimbriaR');
    %disp(['In file:' TRKS_FX_DOTFIMBRIA_R{ii}.id ' ' hdr_DOTFIMBRIAR{ii}.voxel_order  ' with index: ' ii]);
end
fprintf('completed \n');