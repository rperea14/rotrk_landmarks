function TRKS_OUT  =  rotrk_vox2vox_projind(TRKS_IN,TRKS_REF, DIFF_METRIC, DIFF_NAME, TRKS_OUT_fname)
%[ TRKS_OUT ] = function rotrk_vox2vox_projind(TRKS_IN, TRKS_REF, DIFF_METRIC, DIFF_NAME, TRKS_OUT_fname)
%
%Goal: To create (e.g. TRKS_OUT) and write (optional if TRKS_OUT_fname is passed)
%based on the TRKS_REF xyz-coordinates and n_interp of interpolation. Values
%extracted at these coordinates will come from DIFF_METRIC that must have
%the same string title as DIFF_NAME.

%
%Created by Rodrigo Perea

if nargin < 4
    TRKS_OUT_fname = '';
end

%Check if trks have the same number:
if size(TRKS_IN.sstr.vox_coord,1) ~= size(TRKS_REF.sstr.vox_coord,1) 
    if isfield(TRKS_IN,'id')
        error(['Quitting because, size(TRK_REF.sstr.vox_coord,1) ~= size(TRKS_IN.sstr.vox_coord,1) in: ' TRKS_IN.id ]);
    else
        error(['Quitting because, size(TRK_REF.sstr.vox_coord,1) ~= size(TRKS_IN.sstr.vox_coord,1) in: NO_NAME trk' ]);
    end
else
    trks_out=TRKS_IN;
end


%Adding ref_coords to trks_out:
trks_out= rotrk_coord2ref(TRKS_IN,TRKS_REF);


%Adding scalars in interpolated data:
if ~any(strcmp(trks_out.header.scalar_IDs,DIFF_NAME))
    if strcmp(DIFF_NAME,'proj1FA') || strcmp(DIFF_NAME,'proj1NQA0')
        %Here, projections of max FA or NQA0 values will be added!
        trks_out = rotrk_add_sc(trks_out,DIFF_METRIC,DIFF_NAME,1);
    else
        trks_out = rotrk_add_sc(trks_out,DIFF_METRIC,DIFF_NAME);
    end
end


%Is it Gzip? If so...
if exist(TRKS_OUT_fname,'file') || exist([TRKS_OUT_fname  '.gz' ],'file') %either *.nii or *.nii.gz ...
    warning([TRKS_OUT_fname ' exists. Not writing... to:' TRKS_OUT_fname ' )']);
elseif isempty(TRKS_OUT_fname)
    warning([TRKS_OUT_fname ' not included. Skip writing...']);
else
    rotrk_trk2nii(trks_out, DIFF_METRIC , TRKS_OUT_fname ,DIFF_NAME);
    system(['gzip -f  ' TRKS_OUT_fname ]);
end

TRKS_OUT=trks_out;
