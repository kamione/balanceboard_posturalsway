
% Set path
coppath = '~/projects/Balance_Board/data/';
% Find subject IDs
files = dir(coppath);
subid = [];
for j=1:length(files)
    if length(files(j).name) == 5
        subid = [subid; files(j).name];
    end
end
% Create subIDs
subIDs = cell(size(subid,1),1);
for j=1:length(subIDs)
    subIDs{j} = subid(j,:);
end
save([coppath, 'Balance_Board_subIDs.mat'], 'subIDs');

% Set new sampling rate
newFs = 50; % resample to this sample rate, in Hz

% Read in COP timeseries data file
for i = 1:length(subIDs)
    filesA = dir([coppath, subIDs{i}, '/*COPTimeSeries*']); %Find only COPTimeSeries data files
    
    for j = 1:length(filesA)
        disp(['Resampling file ', num2str(j), ' of ', num2str(length(filesA)), ' for subject ', num2str(i), ' of ', num2str(length(subIDs))])
        COPorig = csvread([coppath, subIDs{i}, '/', filesA(j).name],1,3); % ...,1,3) = skip header row and first 3 columns (sub id, task, timestamp)
        % http://www.mathworks.com/help/signal/examples/resampling-nonuniformly-sampled-signals.html
        % Create new COP data matrix with resampled data
        [COPresamp(:,2), COPresamp(:,1)] = resample(COPorig(:,2),COPorig(:,1),newFs); %resampled COPml data
        [COPresamp(:,3), COPresamp(:,1)] = resample(COPorig(:,3),COPorig(:,1),newFs); %resampled COPap data
        
        % Write out resampled COP data file (convert to table so csv file
        % will have a header with variable names) 
        T = array2table(COPresamp, 'VariableNames', {'time','COPml','COPap'});
        writetable(T, [coppath, subIDs{i}, '/', filesA(j).name(1:end-14), 'resampled50Hz_', filesA(j).name(end-13:end)])
        
        clear COPorig COPresamp T
    end
end

% plot(COPorig(:,1),COPorig(:,2),'o-', COPresamp(:,1),COPresamp(:,2),'x-')
% legend('Original','Resampled')
