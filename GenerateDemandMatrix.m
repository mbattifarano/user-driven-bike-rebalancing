close all
clear
clc

% Set which bicyle sharing system to import data from
System = 'London'; % options: 'Minneapolis', 'Denver', 'London'

% Set timing parameters - make sure averageLength is a multiple of timeInterval
timeInterval = minutes(5); % possible formats: minutes(x), hours(x), days(x)
averageLength = days(1); % possible formats: minutes(x), hours(x), days(x)

% Set starting and ending dates to average the demand over
if strcmp(System,'Minneapolis')
    startingDate = datetime(2016,4,4,0,0,0);
    endingDate = datetime(2016,11,6,23,59,59);
elseif strcmp(System,'Denver')
    startingDate = datetime(2016,1,1,0,0,0);
    endingDate = datetime(2016,12,31,23,59,59);
elseif strcmp(System,'London')
    startingDate = datetime(2017,9,1,0,0,0);
    endingDate = datetime(2017,9,30,23,59,59);
end

% Initialization and data import
if strcmp(System,'Minneapolis')
    [Startdate,~,Startstationnumber,Enddate,~,Endstationnumber,~,~] = ImportMinneapolisData('Nice_ride_trip_history_2016_season.csv');
    StartDate = Startdate;
    EndDate = Enddate;
    StartStationId = Startstationnumber;
    EndStationId = Endstationnumber;
elseif strcmp(System,'Denver')
    [~,~,~,~,CheckoutDate,CheckoutTime,CheckoutKiosk,ReturnDate,ReturnTime,ReturnKiosk,~] = ImportDenverData('2016denverbcycletripdata_public.csv');
    CheckoutDate.Format = 'MM/dd/yyyy HH:mm';
    StartDate = CheckoutDate + timeofday(CheckoutTime);
    ReturnDate.Format = 'MM/dd/yyyy HH:mm';
    EndDate = ReturnDate + timeofday(ReturnTime);
    StartStationId = CheckoutKiosk;
    EndStationId = ReturnKiosk;
elseif strcmp(System,'London')
    filename{1} = '73JourneyDataExtract30Aug2017-05Sep2017.csv';
    filename{2} = '74JourneyDataExtract06Sep2017-12Sep2017.csv';
    filename{3} = '75JourneyDataExtract13Sep2017-19Sep2017.csv';
    filename{4} = '76JourneyDataExtract20Sep2017-26Sep2017.csv';
    filename{5} = '77JourneyDataExtract27Sep2017-03Oct2017.csv';
    StartDate = [];
    EndDate = [];
    StartStationId = [];
    EndStationId = [];
    for k = 1:length(filename)
        [~,~,~,TempEndDate,TempEndStationId,~,TempStartDate,TempStartStationId,~] = ImportLondonData(filename{k});
        StartDate = [StartDate; TempStartDate];
        EndDate = [EndDate; TempEndDate];
        StartStationId = [StartStationId; TempStartStationId];
        EndStationId = [EndStationId; TempEndStationId];
    end
end

% Sort stations by ID number
StationIds = unique([StartStationId;EndStationId]);

% Create start station demand matrix
[SortedStartDate,I] = sort(StartDate);
SortedStartStationId = StartStationId(I);
SortedEndStationId = EndStationId(I);
StartDemand = zeros(length(StationIds),length(StationIds),averageLength/timeInterval);
initialDate = startingDate;
initial_Date = startingDate;
i = 1;
k = 1;
regularization = 1;
while (i <= length(SortedStartDate)) && (SortedStartDate(i) <= endingDate)
    while (i <= length(SortedStartDate)) && (SortedStartDate(i) < initialDate + timeInterval)
        StartDemand(SortedStartStationId(i)==StationIds,SortedEndStationId(i)==StationIds,k) = StartDemand(SortedStartStationId(i)==StationIds,SortedEndStationId(i)==StationIds,k) + 1;
        i = i + 1;
    end
    initialDate = initialDate + timeInterval;
    if i <= length(SortedStartDate)
        if initialDate < initial_Date + averageLength
            k = k + 1;
        else
            k = 1;
            initial_Date = initial_Date + averageLength;
            regularization = regularization + 1;
        end
    end
end
StartDemand = StartDemand/regularization;

% Create end station demand matrix
[SortedEndDate,I2] = sort(EndDate);
SortedStartStationId2 = StartStationId(I2);
SortedEndStationId2 = EndStationId(I2);
EndDemand = zeros(length(StationIds),length(StationIds),averageLength/timeInterval);
initialDate2 = startingDate;
initial_Date2 = startingDate;
i = 1;
k = 1;
regularization2 = 1;
while (i <= length(SortedEndDate)) && (SortedEndDate(i) <= endingDate)
    while (i <= length(SortedEndDate)) && (SortedEndDate(i) < initialDate2 + timeInterval)
        EndDemand(SortedStartStationId2(i)==StationIds,SortedEndStationId2(i)==StationIds,k) = EndDemand(SortedStartStationId2(i)==StationIds,SortedEndStationId2(i)==StationIds,k) + 1;
        i = i + 1;
    end
    initialDate2 = initialDate2 + timeInterval;
    if i <= length(SortedEndDate)
        if initialDate2 < initial_Date2 + averageLength
            k = k + 1;
        else
            k = 1;
            initial_Date2 = initial_Date2 + averageLength;
            regularization2 = regularization2 + 1;
        end
    end
end
EndDemand = EndDemand/regularization2;

% Save start and end station demand matrices
save([System '_' char(timeInterval) '.mat'],'StartDemand','EndDemand');