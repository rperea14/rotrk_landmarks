function TRK_OUT = rotrk_coord2ref(CUR_TRK,REF_TRK)
%function curTRK = rotrk_coord2ref(CUR_TRK,REF_TRK)
%This function will position FA values from a centerline in CUR_TRK to a specific
%voxel space using the REF_TRK.

%It will change TRK_OUT.sstr.matrix  TRK_OUT.sstr.vox_coord and 
%REMOVE  TRK_OUT.unique_voxels as it's not useful when doing this.
%
%*As forn now, it is imperative to have only
%on streamline for this to work (e.g. centerline). If not, you can 1)
%improve implementation or 2) stick with a centerline



%Checking if values are of the same size
if size(REF_TRK.sstr.matrix,1) ~= size(CUR_TRK.sstr.matrix,1)
    error('Cannot proceed as the size of *.sstr.matrx in REF_TRK ~= CUR_TRK. Did you interpolate?')
end

if size(REF_TRK.sstr.vox_coord,1) ~= size(CUR_TRK.sstr.vox_coord,1)
    error('Cannot proceed as the size of *.sstr.vox_coord in REF_TRK ~= CUR_TRK. Did you interpolate?')
end

%Keeping similar struct variables
TRK_OUT.id = CUR_TRK.id;
TRK_OUT.trk_name = strcat('voxchanged_' , CUR_TRK.trk_name);
TRK_OUT.header = CUR_TRK.header;


%Changing the variables needed
TRK_OUT.sstr.matrix(:,1:3) = REF_TRK.sstr.matrix(:,1:3);
TRK_OUT.sstr.vox_coord = CUR_TRK.sstr.vox_coord;
TRK_OUT.sstr.vox_coord(:,1:3) = REF_TRK.sstr.vox_coord(:,1:3);
TRK_OUT.sstr.nPoints=REF_TRK.sstr.nPoints;