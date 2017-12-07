function LondonStationTable = importlondonkiosk(file)
% Should use bikepoint.json
station_file = jsondecode(fileread(file));
% Each station's entry is a JSON object, so we need to extract from each
rawtable = arrayfun(@(a) extractentry(a),station_file);
% Sort table by ascending station ID
LondonStationTable = unique(struct2table(rawtable));
end

function s = extractentry(station)
    s.id = str2double(station.additionalProperties(1).value);
    s.name = station.commonName;
    s.lat = station.lat;
    s.lon = station.lon;
    s.nbdocks = str2double(station.additionalProperties(9).value); 
end