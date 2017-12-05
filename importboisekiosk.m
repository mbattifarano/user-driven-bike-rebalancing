function BoiseStationTable = importboisekiosk()
station_status = jsondecode(fileread('station_status.json'));
station_information = jsondecode(fileread('station_information.json'));
station_table = rmfield(station_information.data.stations,{'region_id','rental_methods'});
[station_table(:).num_docks_available]=station_status.data.stations.num_docks_available;
BoiseStationTable = struct2table(station_table);