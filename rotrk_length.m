function [ length_val ] = rotrk_length(streamlines)
% function [ length_val ] = rotrk_length(streamlines)
% Goal: Given a N x 3 coordinate for a given streamline, we calculate the
% length of the streamline using a one-to-one point base eucledian
% distances 

if ~isnum(streamlines)
    error('Invalid streamlines aguments. Make sure you pass single streamliens')
end


if size(streamlines,2) == 3
    dsiplay('Streamline class and size is ok');
elseif size(streamlines,2) >3 
   warning('streamlines arguments has more than 3 colums. Assuming xyz coordiantes in the first three columsn and omitting the others')
else
    error('Incorrect number of streamlines. You need at least 3 columns for a streamlines of size N x 3');
end



