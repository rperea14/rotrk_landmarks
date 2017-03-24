function [ mhd ] = rotrk_get_distance_HDorff( A, B )
%
%   Ouputs the modified Hausdorff distance that shows best results  
%   for object matcheing based on their edge points:
%   
%   Input:
%       A --> n-dimensional matrix points
%       B --> n-dimnesional matrix points
%       *A and B should be the same size
%   Output: 
%       mhd --> Modified disntace 
% % M. P. Dubuisson and A. K. Jain. A Modified Hausdorff distance for object 
% % matching. In ICPR94, pages A:566-568, Jerusalem, Israel, 1994.
% % http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=576361


% % Compute the sizes of the input point sets
Asize = size(A);
Bsize = size(B);

% Check if the points have the same dimensions
if Asize(2) ~= Bsize(2)
    error('The dimensions of points in the two sets are not equal');
end

%Calculating the Euclidean distances:
D=pdist2(A,B);
%D(D==0)=-nan


% Calculating the forward HD 
mins = min(D, [], 2); 
fhd = sum(mins) / Asize(1);

% Calculating the reverse HD 
mins = min(D, [], 1); 
rhd = sum(mins) / Bsize(1);


mhd = max(rhd,fhd);
%ModHausdorffDist(A,B);
