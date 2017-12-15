function p = Initialization()

% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.C = 100; % maximum daily budget for incentives
p.lambda = 0.1; % cost to rebalance a bike manually
p.alphaO = 0.75; % cooperativeness parameter for switching origins
p.alphaD = 0.75; % cooperativeness parameter for switching destinations
System = 'Minneapolis'; % bicycle sharing system (options: 'London', 'Denver', 'Minneapolis')
p.system = System;
TimeInterval = minutes(15); % time step size or interval (options: minutes(1), minutes(5), minutes(10), minutes(15))
incentive_method = 'exponential_utility'; % method to generate incentive costs (options: 'exponential_utility', 'isoelastic_utility', 'linear_utility', 'translog_utility')
init_distribution_method = 'Uniform'; % method to generate initial distribution of bikes (options: 'Uniform', 'Normal', 'Poisson', 'Exponential')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculated parameters
load([System ' ' char(TimeInterval) '.mat']);
p.N = size(StartDemand,1); % number of stations
p.T = size(StartDemand,3); % number of time steps
p.dO = StartDemand(:,:,1:p.T); % origin travel demand over time
p.dD = EndDemand(:,:,1:p.T); % destination travel demand over time
station_struct = stationdata(System,p.alphaO,p.alphaD,incentive_method);
if strcmp(System,'London')
    [station_structIDs,idx2,~] = unique(station_struct.capacity.id);
    b = station_struct.capacity.nbdocks(idx2);
elseif strcmp(System,'Denver')
    [station_structIDs,idx2,~] = unique(categorical(station_struct.capacity.KioskName));
    b = station_struct.capacity.TotalDocks(idx2);
elseif strcmp(System,'Minneapolis')
    [station_structIDs,idx2,~] = unique(station_struct.capacity.Terminal);
    b = station_struct.capacity.NbDocks(idx2);
end
cO = station_struct.origin_incentive;
cO = cO(idx2,:);
cO = cO(:,idx2);
cD = station_struct.destination_incentive;
cD = cD(idx2,:);
cD = cD(:,idx2);
NotInStationStruct = setdiff(StationIds,station_structIDs);
b(end+1:end+length(NotInStationStruct)) = round(mean(b)); % add capacities for stations found in trip data but not found in data file
avg_cO = mean(mean(cO));
cO(end+1:end+length(NotInStationStruct),:) = avg_cO; % add origin incentive cost rows for stations found in trip data but not found in data file
cO(:,end+1:end+length(NotInStationStruct)) = avg_cO; % add origin incentive cost columns for stations found in trip data but not found in data file
avg_cD = mean(mean(cD));
cD(end+1:end+length(NotInStationStruct),:) = avg_cD; % add destination incentive cost rows for stations found in trip data but not found in data file
cD(:,end+1:end+length(NotInStationStruct)) = avg_cD; % add destination incentive cost columns for stations found in trip data but not found in data file
[sortedIDs,idx] = sort([station_structIDs; NotInStationStruct]);
b = b(idx); % sort station capacities according to station ID number/name
cO = cO(idx,:); % sort origin incentive cost rows according to station ID number/name
cO = cO(:,idx); % sort origin incentive cost columns according to station ID number/name
cD = cD(idx,:); % sort destination incentive cost rows according to station ID number/name
cD = cD(:,idx); % sort destination incentive cost columns according to station ID number/name
NotInStationIds = setdiff(station_structIDs,StationIds);
for k = 1:length(NotInStationIds)
    b(sortedIDs==NotInStationIds(k)) = Inf;
    cO(sortedIDs==NotInStationIds(k),:) = Inf;
    cO(:,sortedIDs==NotInStationIds(k)) = Inf;
    cD(sortedIDs==NotInStationIds(k),:) = Inf;
    cD(:,sortedIDs==NotInStationIds(k)) = Inf;
    if isnan(NotInStationIds(k))
        b(isnan(sortedIDs)) = Inf;
        cO(isnan(sortedIDs),:) = Inf;
        cO(:,isnan(sortedIDs)) = Inf;
        cD(isnan(sortedIDs),:) = Inf;
        cD(:,isnan(sortedIDs)) = Inf;
    end
end
b(b==Inf) = []; % delete capacities of stations not found in trip data
cO(cO(:,1)==Inf,:) = []; % delete origin incentive cost rows associated with stations not found in trip data
cO(:,cO(1,:)==Inf) = []; % delete origin incentive cost columns associated with stations not found in trip data
cD(cD(:,1)==Inf,:) = []; % delete destination incentive cost rows associated with stations not found in trip data
cD(:,cD(1,:)==Inf) = []; % delete destination incentive cost columns associated with stations not found in trip data
p.b = b; % station capacities
p.s = GenerateInitialBikeDistribution(p.b,init_distribution_method); % initial number of bicycles at each station
p.cO = cO; % incentive required to switch origins
p.cD = cD; % incentive required to switch destinations

% These are also adjustable parameters, but we will always assume nobody has already accepted an incentive
p.dOinc = zeros(p.N, p.N, p.T); % origin travel demand that has already accepted an incentive
p.dDinc = zeros(p.N, p.N, p.T); % destination travel demand that has already accepted an incentive

end