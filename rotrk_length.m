function [ LENGHT_VAL ] = rotrk_length(streamlines)
% function [ length_val ] = rotrk_length(streamlines)
% Goal: Given a N x 3 coordinate for a given streamline, we calculate the
% length of the streamline using a one-to-one point base eucledian
% distances 

if ~isnumeric(streamlines)
    error('Invalid streamlines aguments. Make sure you pass single streamliens')
end


if size(streamlines,2) == 3
    display('Streamline class and size is ok..getting the length now');
elseif size(streamlines,2) >3 
   warning('streamlines arguments has more than 3 colums. Assuming xyz coordiantes in the first three columsn and omitting the others')
else
    error('Incorrect number of streamlines. You need at least 3 columns for a streamlines of size N x 3');
end

cur_len=0;
for jj=1:size(streamlines,1)-1
    cur_len=cur_len+pdist2(streamlines(jj,:),streamlines(jj+1,:));
end

LENGHT_VAL = cur_len;

