function [ TRKS_OUT ] = rotrk_xls(xls_struct, TRKS_IN)
%function [ TRKS_OUT ] = rotrk_xls(xls_struct, TRKS_IN)
%Objective: Add data in xls_struct to a header structure file containing some
%           tract information
%   To generate the xls_strcut, run rotrk_xls.m !
% xls_struc should have the following cells:
% xls_DATA.id --> 'MRI Session_ID' (mandatory to make the comparison
%
% Added values:
% xls_DATA.dx --> 'Dx'
% xls_DATA.age --> 'Age'
% xls_DATA.sex --> 'Gender'
% xls_DATA.diffmotion --> 'Diffmotion'


%Check number of arguments
if nargin < 2
    error('Incorrect number of arguments. Please add the header and xls_struct.')
end
if ~isstruct(xls_struct)
    error('The second argument (xls_strcut) is not in struct form. Please check help!')
end
if ~(isfield(xls_struct,'id'))
    error('No <xls_struct>.id field exists. No way to do comparison. Please check your data!')
end


%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Now accesing the code and adding the necessary variables
TRKS_OUT=TRKS_IN;
%Doing the for loop...
for ii=1:numel(TRKS_OUT)
    for jj=1:numel(xls_struct.id)
        if strcmp(TRKS_OUT{ii}.header.id,xls_struct.id{jj})
            fn=fieldnames(xls_struct);
            for fnidx = 1:  size(fn)
                TRKS_OUT{ii}.header.data.(fn{fnidx})=xls_struct.(fn{fnidx}){jj};
            end
        end
    end
end