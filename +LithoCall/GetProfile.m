function [Depths,Rhos,Vp,Vs,varargout] = GetProfile(lat,lon,LithoPath)
%LithoCall.GetProfile do a system call to "access_litho" binary and extract profile
% from Litho1.0 (Pasyanos et. al 2014, doi: 10.1002/2013JB010626)
%
% Usage: [Depths,Rhos,Vp,Vs,(Names)] = LithoProfile(lat,lon,(SystemFlag))
%            Depths, Rhos, Names are complete to a 10-layer model
%            suitable to obtain a depth- and Rho-map for each layer
%            including missing (=zero-thickness) ones
%
% Input: lat       : scalar, latitude (deg)
%        lon       : scalar, longitude (deg)
%        LithoPath : string, path to access_litho, including trailing (back)slash
%
% Output: Depths  : depth in metres for each layer, positive downwards
%         Rhos    : density in kg/m3 for each layer, AIR rho set to 0
%         Vp      : Vp in m/s for each layer, AIR Vp set to 0
%         Vs      : Vs in m/s for each layer, AIR Vs set to 0
%         (names) : optional, name of each layer
%
% 2018, Alberto Pastorutti

narginchk(3,3)
nargoutchk(4,5)

%% parse access_litho output
CallString = [LithoPath,'access_litho.exe -p ',num2str(lat),' ',num2str(lon)];
% [depth density Vp Vs Qkappa Qmu Vp2 Vs2 eta layername]
[CallStatus,Profile] = system(CallString);

assert(CallStatus==0,'access_litho exited with nonzero status!')
% scan text output of profile
ProfileFormat = '%f %f %f %f %f %f %f %f %f %s';
ParsedProfile = textscan(Profile,ProfileFormat,...
                         'Delimiter',' ',...
                         'MultipleDelimsAsOne',1);
Depths  = ParsedProfile{1}(1:2:end)';
Rhos    = [ParsedProfile{2}(2:2:end)',0]; % add RHO of "AIR" layer
Vp      = [ParsedProfile{3}(2:2:end)',0]; % add Vp of "AIR" layer
Vs      = [ParsedProfile{4}(2:2:end)',0]; % add Vs of "AIR" layer
Names   = ParsedProfile{10}(2:2:end)';
% remove "-BOTTOM" from layer names
for j=1:length(Names)
    Names{j} = Names{j}(1:end-7);
end
% concatenate "AIR" layer
Names = [Names, 'AIR'];

%% take account of the missing layers in each profile
% using the "Names" output as reference
FullNames = {'LID' ...
             'CRUST3' 'CRUST2' 'CRUST1' ...
             'SEDS3' 'SEDS2' 'SEDS1' ...
             'ICE' 'WATER' 'AIR'};
% find missing layers in profile
DiffNames = setdiff(FullNames,Names,'stable');
% DiffNames are ordered starting from the last in FullNames
% the same order is kept when taking account of missing layers
% since we refer to the depth of the layer above (=zero thickness)
% note: "AIR" layer is never missing, neither does "LID" (bottom-most)
for i=1:length(DiffNames) % empty DiffNames means the for is skipped
    MissingIndex = find(strcmp(FullNames,DiffNames{i}));
    MissingIndexRev = length(Names) - MissingIndex;
    % MissingIndexRev: where the missing layer is COUNTING FROM end
    % example: 10 layers, last is AIR, second last is WATER
    % if water is missing, MissingIndexRev = 10 - 9 = 1
    Depths = [Depths(1:(end-MissingIndexRev-1)), ... % below
              Depths(end-MissingIndexRev), ... % depth of layer above
              Depths((end-MissingIndexRev):end)]; % above
    Rhos   = [Rhos(1:(end-MissingIndexRev-1)), ... % below
              0, ... % rho set to zero (does not matter, actually)
              Rhos((end-MissingIndexRev):end)]; % above
    Vp     = [Vp(1:(end-MissingIndexRev-1)), ... % below
              0, ... % Vp set to zero (does not matter, actually)
              Vp((end-MissingIndexRev):end)]; % above
    Vs     = [Vs(1:(end-MissingIndexRev-1)), ... % below
              0, ... % Vs set to zero (does not matter, actually)
              Vs((end-MissingIndexRev):end)]; % above
    Names  = [Names(1:(end-MissingIndexRev-1)), ... % below
              FullNames(MissingIndex), ... % name of missing layer
              Names((end-MissingIndexRev):end)]; % above
end

%% output names if asked to
if nargout==5
    varargout{1} = Names;
end

end
