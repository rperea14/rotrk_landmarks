function rotrk_sstrplot(SSTR_IN, COLOR_PARAMS)
%function [ TRKS_OUT ] = rotrk_sstrplot(SSTR_IN, COLOR_PARAMS)
%Simple function that will plot every sstr in SSTR_IN (avoiding empty ones) 
%in the color scheme given by COLOR_PARAMS
%Created by Rodrigo Perea

if isfield(SSTR_IN,'sstr')
    sstr = SSTR_IN.sstr;
else
    warning('Check data type if not working. THe one the works is if TRKS_IN  is TRKS_IN.sstr')
    sstr=SSTR_IN;
end

for ii=1:size(sstr,2)
    if ~isempty(sstr(ii).matrix)
        plot3(sstr(ii).matrix(:,1), sstr(ii).matrix(:,2), sstr(ii).matrix(:,3), COLOR_PARAMS);
    end
end
