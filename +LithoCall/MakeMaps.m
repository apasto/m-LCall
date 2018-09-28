function [Lat,Lon,DepthMap,RhoMap,VpMap,VsMap] = MakeMaps(LatRange,LonRange,step)
%LithoCall.MakeMaps extract layer depth and density from Litho1.0
%                   (Pasyanos et. al 2014, doi: 10.1002/2013JB010626)
%                   using a system call to "access_litho" binary
%                   "profile mode" (-p lat lon) is called on a regular grid
%
% Usage: [Lat,Lon,DepthMap,RhoMap,VpMap,VsMap] = LithoCall(LatRange,LonRange,step)
%
% Input: LatRange : latitude range, as [lat min, lat max]
%                       degrees [-90,90] increasing
%        LonRange : longiture range, as [lon min, lon max]
%                       degrees [-180,180] increasing
%        step     : step between nodes, degrees
%
%        (note: 1 point only and Lon-only/Lat-only profiles are fine)
%
% Output: Lat, Lon : Lat, Lon vectors
%         DepthMap : (Lon,Lat,Layer) array of depths in metres (positive downwards)
%         RhoMap   : (Lon,Lat,Layer) array of densities in kg/m3
%         VpMap    : (Lon,Lat,Layer) array of Vp, in m/s
%         VsMap    : (Lon,Lat,Layer) array of Vs, in m/s
%
% 2018, Alberto Pastorutti

narginchk(3,3)
nargoutchk(6,6)
NLAYERS = 10; % LID CRUST3 CRUST2 CRUST1 SEDS3 SEDS2 SEDS1 ICE WATER AIR

%% check and manage input
assert(all(size(LatRange)==[1 2]),'LatRange must be given as [lat1 lat2]');
assert(all(size(LonRange)==[1 2]),'LonRange must be given as [lon1 lon2]');
assert(isscalar(step),'step must be given as a scalar');

% access_litho.exe has NO protection against illegal arguments
% e.g. -p 0 0 (correct) and -p 0 360 result in extremely different outputs
% without throwing a error (exit status remains 0)
if any(LatRange)<-90 || any(LatRange)>90
    error('LatRange outside [-90,90] bounds');
end
if any(LonRange)<-180 || any(LonRange)>180
    error('LonRange outside [-180,180] bounds');
end

% check for ascending order in ranges (or 1 element only)
% this implies that the range is non-empty
assert(LatRange(1)<=LatRange(2),'LatRange must be given in increasing order');
assert(LonRange(1)<=LonRange(2),'LonRange must be given in increasing order');

%% turn input range and step in lat, lon vectors
Lat = LatRange(1):step:LatRange(2); nLat = length(Lat);
Lon = LonRange(1):step:LonRange(2); nLon = length(Lon);

%% preallocate maps
DepthMap = NaN(nLon,nLat,NLAYERS);
RhoMap = DepthMap; VpMap = DepthMap; VsMap = DepthMap;

%% perform calls
for u=1:nLon
    for v=1:nLat
        try
            [DepthMap(u,v,:),RhoMap(u,v,:),VpMap(u,v,:),VsMap(u,v,:)] = ...
                LithoCall.GetProfile(Lat(v),Lon(u));
        catch
            fprintf(['Empty profile caught at lon ',num2str(Lon(u),'%03.3f'),...
                                            ' lat ',num2str(Lat(v),'%03.3f'),...
                                            ' \n']); % to do: this as warning
        end
    end
end

end

