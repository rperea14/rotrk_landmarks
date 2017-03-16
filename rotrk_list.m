function [ ROIformat ] = rotrk_list(DIRECTORY, FILE_PREFIX, FILE_SUFFIX,opt1,IDENTIFIER)
%function [ ROIformat ] = rotrk_list(DIRECTORY, FILE_PREFIX, FILE_SUFFIX,IDENTIFIER,opt1
%if opt1==1, then treat it as a single variable
if nargin < 4
    opt1='';
    IDENTIFIER='';
end
if opt1==1
    ROIformat{1}.id='noID';
    ROIformat{1}.filename=DIRECTORY;
    if nargin > 4
        ROIformat{1}.identifier=IDENTIFIER;
    end
else
    
    
    roiLIST=dir_wfp2( [DIRECTORY filesep FILE_PREFIX '*' FILE_SUFFIX] );
    
    for ii=1:numel(roiLIST)
        %Removing filename extensions to get "only" the subject name...
        SUBJID=strrep(roiLIST(ii), [DIRECTORY filesep FILE_PREFIX  ],'');
        SUBJID=strrep(SUBJID, FILE_SUFFIX ,'');
        %assign it in a variable
        ROIformat{ii}.filename=roiLIST(ii);
        ROIformat{ii}.id=SUBJID;
        
        if nargin > 4
            ROIformat{ii}.identifier=IDENTIFIER;
        end
    end
end
