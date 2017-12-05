close all
clear
clc

% Files to use for data averaging
filename{1} = '73JourneyDataExtract30Aug2017-05Sep2017.csv';
filename{2} = '74JourneyDataExtract06Sep2017-12Sep2017.csv';
filename{3} = '75JourneyDataExtract13Sep2017-19Sep2017.csv';
filename{4} = '76JourneyDataExtract20Sep2017-26Sep2017.csv';
filename{5} = '77JourneyDataExtract27Sep2017-03Oct2017.csv';

% Initialization
RentalId = [];
Duration_Seconds = [];
BikeId = [];
EndDate = [];
EndStationId = [];
EndStationName = [];
StartDate = [];
StartStationId = [];
StartStationName = [];

% Import data from files
for k = 1:length(filename)
    [TempRentalId,TempDuration_Seconds,TempBikeId,TempEndDate,TempEndStationId,TempEndStationName,TempStartDate,TempStartStationId,TempStartStationName] = ImportLondonData(filename{k});
    RentalId = [RentalId; TempRentalId];
    Duration_Seconds = [Duration_Seconds; TempDuration_Seconds];
    BikeId = [BikeId; TempBikeId];
    EndDate = [EndDate; TempEndDate];
    EndStationId = [EndStationId; TempEndStationId];
    EndStationName = [EndStationName; TempEndStationName];
    StartDate = [StartDate; TempStartDate];
    StartStationId = [StartStationId; TempStartStationId];
    StartStationName = [StartStationName; TempStartStationName];
end

% Set timing parameters - make sure averageLength is a multiple of timeInterval
timeInterval = minutes(5); % possible formats: minutes(x), hours(x), days(x)
averageLength = days(1); % possible formats: minutes(x), hours(x), days(x)

% Set starting and ending dates to average the demand over
startingDate = datetime(2017,8,30,0,0,0);
endingDate = datetime(2017,10,3,23,59,59);

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