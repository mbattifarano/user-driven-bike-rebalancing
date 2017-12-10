function station_struct = stationdata(system, origin_comp, dest_comp, incentive_method)



% Import and sort data from files
if strcmp(system,'Denver')
    october2016kioskinfo = unique(importdenverkiosk('october2016_kioskinfo.csv', 2, 90));
    dist = createdistancematrix(october2016kioskinfo.Latitude,october2016kioskinfo.Longitude);
    station_struct.capacity = october2016kioskinfo;
    station_struct.capacity.Latitude = [];
    station_struct.capacity.Longitude = [];
elseif strcmp(system,'Minneapolis')
    NiceRide2016StationLocations = unique(importminnkiosk('Nice_Ride_2016_Station_Locations.csv', 2, 203));
    dist = createdistancematrix(NiceRide2016StationLocations.Latitude,NiceRide2016StationLocations.Longitude);
    station_struct.capacity = NiceRide2016StationLocations;
    station_struct.capacity.Latitude = [];
    station_struct.capacity.Longitude = [];
elseif strcmp(system,'London')
    londonkiosks = importlondonkiosk('bikepoint.json');
    dist = createdistancematrix(londonkiosks.lat,londonkiosks.lon);
    station_struct.capacity = londonkiosks;
    station_struct.capacity.lat = [];
    station_struct.capacity.lon = [];
end

% construct incentive matrix
if strcmp(incentive_method,'exponential_utility')
station_struct.origin_incentive = (1-exp(-origin_comp*dist))/origin_comp;
station_struct.destination_incentive = (1-exp(-dest_comp*dist))/dest_comp;
elseif strcmp(incentive_method,'isoelastic_utility')
station_struct.origin_incentive = ((dist^origin_comp)-1)/origin_comp;
station_struct.destination_incentive = ((dist^dest_comp)-1)/dest_comp;
elseif strcmp(incentive_method,'linear_utility')
station_struct.origin_incentive = dist*origin_comp;
station_struct.destination_incentive = dist*dest_comp;
elseif strcmp(incentive_method,'translog_utility') % formula to be confirmed
station_struct.origin_incentive = log(dist)*origin_comp;
station_struct.destination_incentive = log(dist)*dest_comp;
end

end
