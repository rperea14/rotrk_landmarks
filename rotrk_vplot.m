function rotrk_plot(TRKS_IN, plot_color)
%function rotrk_plot(header,tracts, volume, sortedby,limit_to, header2, tracts2, header3, tracts3 )
% This will plot the *.vox_coord values 
%   Created by Rodrigo D. Perea (rpereacamargo@mgh.harvard.edu) 
% Inputs:
%   TRKS_IN:
%       TRKS_IN.header          -> struct/cell file header (*make sure this is larger
%       TRKDS_IN.tracts         -> struct/cell file strlines
%
%   plot_color      --> color of the plot (e.g. 'rainbow' 'r' 'rr' 'r.' 'b' 'bb' 'c' 'cc' 'g' 'k' 'kk' 'kline'  )
%                       *will replace TRKS_IN.plot_params.color!!
% OUTPUT:
%    The plot :P~~~!


if nargin <2 ; plot_color=''; end

n_plots=numel(TRKS_IN);
n_subplots=ceil(n_plots/9); %e.g. for 23 values, we need at least 3 subplots (9x9x5)
%~~~end of checking # of plots needed.

%STARTING THE PLOT IMPLEMENTATION
% number of subplots needed
plot_counter=1;
plot_idx=1;
if numel(TRKS_IN)==1
    disp(['In: ' TRKS_IN.id '... '])
    local_rotrk_goplot(TRKS_IN.id,TRKS_IN, plot_color)
else
    for ii=1:n_subplots % 1 through 3
        figure, hold on
        %if in the last subplot, check how many plots using mod)
        if (ii==n_subplots), subplot_idx=mod(n_plots,9)-1;
        else %subplot 9 subplots per figure...
            subplot_idx=9;
        end
        for jj=1:subplot_idx
            subplot(3,3,jj)
            disp(['In: ' TRKS_IN{plot_idx}.id '...'])
            title([ '\color{red}' strrep(TRKS_IN{plot_idx}.id,'_','\_')], 'Interpreter', 'tex')
            local_rotrk_goplot(TRKS_IN{plot_idx}.id,TRKS_IN{plot_idx},plot_color,'1st',varargin)
            hold off
            plot_idx=plot_idx+1;
        end
    end
end

%END OF FILE ~~~


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%STARTING LOCAL FUNCTION
% Plot streamlines
function local_rotrk_goplot(subjid,single_TRKS_IN,plot_color)

%FIRST TAKING CARE OF THE COLOR!
%Setting up the values for the 1st plot only!
if nargin < 3
    what_plot='';
end

%COLOR INIT FOR STREAMLINE FIRST:
color=plot_color;
%CHECKING COLOR PARAMETER
if isfield(single_TRKS_IN,'plot_params')
    %COLOR
    if strcmp(plot_color,'')
        if isfield(single_TRKS_IN.plot_params, 'color')
            color=single_TRKS_IN.plot_params.color;
        else
            color='r';
        end
    end
end
if strcmp(color,''); color='k'; end
%%END OF COLOR INIT



%FOR LOOP TO ITERATE BETWEEN STREAMLINES WITHIN A TRACT
for numtrks = 1:size(single_TRKS_IN.sstr,2)
    %READING THE MATRIX:
    vox_coord = single_TRKS_IN.sstr(numtrks).vox_coord;
    
    %Check if single_TRKS_IN.plotparams exists (if not go with defaults...)
    hold on
    switch color
        case 'rainbow'
            [maxpts, maxidx ]  = max(arrayfun(@(x) size(x.vox_coord, 1), single_TRKS_IN.sstr));
            cline(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3), (0:(size(vox_coord, 1)-1))/(maxpts))
        case 'myrainbow_4'
            if size(vox_coord,2) < 4
                error([ 'Error: diffusion metric not found.' ...
                    ' Make sure your data has at least a 4th column. Exiting...']);
            else
                cline(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3), vox_coord(:,4))
            end
        case 'r'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'r')
        case '.'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'.')
        case 'r.'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'r-')
            plot3(vox_coord(1,1), vox_coord(1,2), vox_coord(1,3), 'b.','markersize',20)
        case 'b'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'b')
          %  plot3(vox_coord(1,1), vox_coord(1,2), vox_coord(1,3), 'r.','markersize',30)
        case 'b.'        
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'b-')
            plot3(vox_coord(1,1), vox_coord(1,2), vox_coord(1,3), 'r.','markersize',20)
        case 'c'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'c')
            plot3(vox_coord(1,1), vox_coord(1,2), vox_coord(1,3), 'c.')
        case 'cc'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'c')
        case 'g'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'g')
            %    plot3(vox_coord(1,1), vox_coord(1,2), vox_coord(1,3), 'b.')
        case 'g.'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'g-')
            plot3(vox_coord(1,1), vox_coord(1,2), vox_coord(1,3), 'k.','markersize',20)
        case 'gg'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'g')
        case 'k'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'k')
         %   plot3(vox_coord(1,1), vox_coord(1,2), vox_coord(1,3), 'k.')
        case 'kk'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'k')
        case 'kline'
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'k.','markersize',30)
          %  plot3(vox_coord(1,1), vox_coord(1,2), vox_coord(1,3), 'r.')
        otherwise
            plot3(vox_coord(:,1), vox_coord(:,2), vox_coord(:,3),'b-')
            plot3(vox_coord(1,1), vox_coord(1,2), vox_coord(1,3), 'r.','markersize',20)
            hold on
    end
end