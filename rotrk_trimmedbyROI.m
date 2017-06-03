function [ TRKS_OUT ] = rotrk_trimmedbyROI(TRKS_IN, theROI, whatflag, theROI2)
%   function [ new_header, new_tracts ] = rotrk_trimmedbyROI(header, tracts, theROI, whatflag)
%   IN ->
%           TRKS_IN.tracts      : stream to be splitted (eg. *.matrix)
%           TRKS_IN.header      : midpoint where split occurs (e.g. '78')
%           theROI      : the ROI used for references
%           whatflag    : (e.g. 'above' --> move coordinates above the minimun eucledian distance
%                       : 'below' -> move coordinated above)
%   OUTPUT:
%               TRKS_OUT
  
%%%%%%%%SPLITTING THTE TRACTS_STRUCT FORM INTO TRACTS AND HEADER
tracts=TRKS_IN.sstr;
header=TRKS_IN.header;
TRKS_OUT.id=TRKS_IN.id;
TRKS_OUT.filename=['trimmed from ~~> ' TRKS_IN.filename];
TRKS_OUT.filename=strrep(TRKS_IN.filename,'trimmed from ~~>  trimmed from ~~> ','trimmedx2 from ~~> ');
%~~~
  
if strcmp(whatflag,'above_dot') || ( strcmp(whatflag,'below') || strcmp(whatflag,'above_dotfimbria')) 
    xyz_flag=rotrk_ROImean(theROI.filename);
else
    ROIxyz=rotrk_ROIxyz(theROI);
    xyz_flag=round(median(ROIxyz.trk_coord)); %/header.voxel_size(2));
    if nargin > 4
        ROIxyz2=rotrk_ROIxyz(theROI2);
        xyz_flag2=round(median(ROIxyz2.trk_coord)); %/header.voxel_size(2));
    end
end
  
  
newii=1;
success=0;
for ii=1:numel(tracts)
    clear tmp_distance
    %If a ith streamlines is found, increase newii
    if success
        newii=newii+1;
        success=0;
    end
      
    if  strcmp(whatflag,'above_dot') || ( strcmp(whatflag,'below') || strcmp(whatflag,'above_dotfimbria'))
        %Rounded median value of the xyz ROI dividing by the # of voxels
        %for compatibility with DSI_Studio
        %For each value within streamline
        for ij=1:size(tracts(ii).matrix,1)
            %Computing the eucledian distance
            tmp_distance(ij)=sqrt( (xyz_flag(1)-tracts(ii).matrix(ij,1))^2 + (xyz_flag(2)-tracts(ii).matrix(ij,2))^2  + (xyz_flag(3)-tracts(ii).matrix(ij,3))^2);
        end
        %What coordinate of the streamline is closer to the ROI (min_distance)? 
        [minvalue minidx ] = min(tmp_distance);
    end
    %If flag is 'dot' then move all the values coordinates above the
    %eucledian distance..
    if strcmp(whatflag,'above_dot')
        %Dealing with shorter streamline coming from the opposite
        %direction (default to body of fx always below the midpoint coordinate so...:
        clear tmp flag_tmp
        tmp=tracts(ii).matrix(minidx:end,3);
        flag_tmp=tmp(round(size(tmp,1)/2));
        if flag_tmp > xyz_flag(3)
            try
                new_tracts(newii).matrix=tracts(ii).matrix(minidx:end,:);
                new_tracts(newii).vox_coord=tracts(ii).vox_coord(minidx:end,:);
                success=1;
                new_tracts(newii).nPoints=size(new_tracts(newii).matrix,1);
                
            catch
                sucess=0
            end
        end
        
    elseif strcmp(whatflag,'above_dotfimbria')
            %Dealing with shorter streamline coming from the opposite
            %direction (default to body of fx always below the midpoint coordinate so...:
            try
                new_tracts(newii).matrix=tracts(ii).matrix(minidx:end,:);
                new_tracts(newii).vox_coord=tracts(ii).vox_coord(minidx:end,:);
                success=1;
                new_tracts(newii).nPoints=size(new_tracts(newii).matrix,1);
                
            catch
                sucess=0
            end
    
        %If flag is 'fimbria' (and since values start next to dot fornix
        %then move all the values coordinates below the eucledian distance
    elseif strcmp(whatflag,'below')
        counter=1;
        if minidx > 2
            try
                new_tracts(newii).matrix=tracts(ii).matrix(1:minidx,:);
                new_tracts(newii).vox_coord=tracts(ii).vox_coord(1:minidx,:);
                success=1;
                new_tracts(newii).nPoints=size(new_tracts(newii).matrix,1);
                
            catch
                sucess=0
            end
        end
        
%             for ik=1:minidx
%                 %disp( ['ii is:' num2str(ii) ' and ik is:' num2str(ik) ' minidx:' num2str(minidx)] )
%                 new_tracts(newii).matrix(counter,:)=tracts(ii).matrix(ik,:);
%                 new_tracts(newii).vox_coord(counter,:)=tracts(ii).vox_coord(ik,:);
%                 counter=counter+1;
%                 success=1;
%             end
%             new_tracts(newii).nPoints=counter-1;
          
        %Here we will be trimming based on what we did with the genu and splenium
        %Within streamlin
    elseif strcmp(whatflag,'genu') %Same will apply for the splenium but logical expression signs will be flipped!
        counter=1; %for the new_tracts
        flaggy_first_reach=0; %This flag will be changed to 1 when we reached the plane of interest
        cur_streamline=round(tracts(ii).matrix);
        %Now check all the values that go beyond the plane of interest
        %(in this case the y-plane so using index 2
          
        %Within each coordinate in the streamline
        for ik=1:size(cur_streamline,1)
            if flaggy_first_reach == 0 %wanting to reach the first plane and remove the others...
                if cur_streamline(ik,2) > xyz_flag(2)
                    flaggy_first_reach=1;
                    new_tracts(newii).matrix(counter,:)=tracts(ii).matrix(ik,:);
                    new_tracts(newii).vox_coord(counter,:)=tracts(ii).vox_coord(ik,:);
                    counter=counter+1;
                      
                end
            elseif flaggy_first_reach == 1
                new_tracts(newii).matrix(counter,:)=tracts(ii).matrix(ik,:);
                new_tracts(newii).vox_coord(counter,:)=tracts(ii).vox_coord(ik,:);
                counter=counter+1;
                  
                if cur_streamline(ik,2) < xyz_flag(2) && counter > 5
                    flaggy_first_reach=3;
                end
            end
        end
         
        if flaggy_first_reach ~= 0
            new_tracts(newii).nPoints=size(new_tracts(newii).matrix,1);
            newii=1+newii;
        end
         
         
            
    %Same will apply for the splenium but logical expression signs will be flipped!    
    elseif strcmp(whatflag,'splenium') 
        %%IMPLEMENT SIMILAR TO GENU
    elseif strcmp(whatflag,'withinROI')
       AA='to_implement_yet';
    end
     
end
  
  
% %REMOVING TRACTS THAT ARE VERY SMALL (< 10 units in distance)
% for ii=1:size(new_tracts,2)
%     %Computing the eucledian distance for each streamline
%     tmp_distance2(ii)=sqrt( (new_tracts(ii).matrix(1,1)-new_tracts(ii).matrix(end,1))^2 ...
%         + (new_tracts(ii).matrix(1,2)-new_tracts(ii).matrix(end,2))^2  ...
%         + (new_tracts(ii).matrix(1,3)-new_tracts(ii).matrix(end,3))^2 );
%     %Checking the distance to the end and first point (this will help
%     %us remove those streamlines that have inital coordinates away from
%     %the ROI
%     tmp_beg(ii)=sqrt( (xyz_flag(1)-new_tracts(ii).vox_coord(1,1))^2 ....
%         + (xyz_flag(2)-new_tracts(ii).vox_coord(1,2))^2  ...
%         + (xyz_flag(3)-new_tracts(ii).vox_coord(1,3))^2);
%     
%     tmp_end(ii)=sqrt( (xyz_flag(1)-new_tracts(ii).vox_coord(end,1))^2 ...
%         + (xyz_flag(2)-new_tracts(ii).vox_coord(end,2))^2 ...
%         + (xyz_flag(3)-new_tracts(ii).vox_coord(end,3))^2);
%     
% end
% 
% 
%DENOTING NEWER STREAMLINES
new_cc=1;
%this will apply only if there are more than 5 streamlines....
if size(tracts,1) > 5
    for ii=1:size(new_tracts,2)
        if tmp_distance2(ii) > mean(tmp_distance2) - 2*std(tmp_distance2)
                new_tracts2(new_cc).matrix=new_tracts(ii).matrix;
                new_tracts2(new_cc).vox_coord=new_tracts(ii).vox_coord;
                new_tracts2(new_cc).nPoints=new_tracts(ii).nPoints;
                new_cc=1+new_cc;
        end
    end
else
    new_tracts2=new_tracts;
end
 
 
 
%Check if a tract has size 1, if so then remove it (so parfor in the
%interpolation method does not fail!).
  
TRKS_OUT.sstr=new_tracts2;
TRKS_OUT.header=TRKS_IN.header;
TRKS_OUT.header.n_count=size(new_tracts2,2);
TRKS_OUT.header.specific_name=strcat(TRKS_IN.header.specific_name,'_trimmed'); %and adding it againg
%Removing naming convetion if trimmed was applied twice
TRKS_OUT.header.specific_name=strrep(TRKS_OUT.header.specific_name,'_trimmed_trimmed','_trimmedx2');


%ADDING UNIQUE VOXELS!
all_vox=TRKS_OUT.sstr(1).vox_coord ;        %initializing vox_coord
for ii=2:size(TRKS_OUT.sstr,2)
    all_vox=vertcat(all_vox,TRKS_OUT.sstr(ii).vox_coord);
end

TRKS_OUT.unique_voxels=unique(all_vox,'rows');
TRKS_OUT.num_uvox=size(TRKS_OUT.unique_voxels,1); 
