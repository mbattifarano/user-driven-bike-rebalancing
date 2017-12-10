close all
clear
clc

% Set which bicyle sharing system to import data from
System = 'Denver'; % options: 'Minneapolis', 'Denver'

if strcmp(System,'Denver')
    october2016kioskinfo = unique(importdenverkiosk('october2016_kioskinfo.csv', 2, 90));
    dist = createdistancematrix(october2016kioskinfo.Latitude,october2016kioskinfo.Longitude);
    capacity = october2016kioskinfo.TotalDocks;
elseif strcmp(System,'Minneapolis')
    NiceRide2016StationLocations = unique(importminnkiosk('Nice_Ride_2016_Station_Locations.csv', 2, 203));
    dist = createdistancematrix(NiceRide2016StationLocations.Latitude,NiceRide2016StationLocations.Longitude);
    capacity = NiceRide2016StationLocations.NbDocks;
end

% construct incentive matrix
lambda = 0.5; % cooperativeness parameter
incentive = (1-exp(-lambda*dist))/lambda;

% Save start and end station demand matrices
save([System '_docks.mat'],'incentive','capacity');
    