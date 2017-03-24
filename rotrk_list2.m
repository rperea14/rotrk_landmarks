function [ rotrk_format ] = rotrk_list2(DIR, PREFIX, SUFFIX, EXT)
%function [ ROIformat ] = rotrk_list2(DIR, PREFIX, SUFFIX, EXT)
%To be used as:
%In bash for: "ls <DIR>/<PREFIX>*<SUFFIX>"
%
%And EXT to be remove  before using strsplit occurs
%(by the "_" chracter)


roiLIST=dir_wfp2( [DIR filesep PREFIX '*' SUFFIX EXT] );
for ii=1:numel(roiLIST)
    rotrk_format{ii}.filename=roiLIST(ii);
    FILENAME=strrep(roiLIST(ii), [DIR filesep PREFIX  ],'');
    FILENAME=strrep(FILENAME, [ EXT  ],'');
    FILENAME=cell2char(FILENAME);
    STRSPLIT=strsplit(FILENAME,'_');
    rotrk_format{ii}.id=[ cell2char(STRSPLIT(2)) '_' cell2char(STRSPLIT(3))];
    rotrk_format{ii}.trk_name=cell2char(STRSPLIT(4));
    rotrk_format{ii}.method=cell2char(STRSPLIT(1));
    %Removing filename extensions to get "only" the subject name...
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%TO REMOVE:
%   DIR     ---> extension used for ls <DIRECTORY>*<SUFFIX>
%   MOD     ---> modality (e.g. trk_ or roi_ or t1_ ...)
%   TECHN   ---> tecnique used (e.g. (trk)_<TRACULA>_...)
%   ID      ---> id of the following participant (e.g.
%                (trk_TRACULA)_114420_4343AD0001_...)
%   SUFFIX  ---> extension used for ls <DIRECTORY>*<SUFFIX>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

