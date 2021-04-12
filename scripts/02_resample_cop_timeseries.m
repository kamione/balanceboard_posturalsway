% Set path
coppath = '/home/tywong/OneDrive/03_Projects/HKU_PosturalSway/data/processed';

% Set new sampling rate
newFs = 50; % resample to this sample rate, in Hz

files = dir([coppath, '/P*COPTimeSeries*']);
filesA = {files.name};

% Read in COP timeseries data file
for ith_file = 1:length(filesA)
    % read in but skip header row and first 3 columns (subject_id, task,
    % TimeStamp)
    disp(ith_file)
    COPorig = readtable(fullfile(coppath, filesA{ith_file}));
    
    if length(find(strcmp('NA', COPorig{:, 5}))) ~= 0 | ...
            length(find(strcmp('NA', COPorig{:, 6}))) ~= 0
        continue;
    end
    
    % http://www.mathworks.com/help/signal/examples/resampling-nonuniformly-sampled-signals.html
    % Create new COP data matrix with resampled data
    [COPresamp(:, 2), COPresamp(:, 1)] = ...
        resample(table2array(COPorig(:, 5)), ...
        table2array(COPorig(:, 4)), newFs);
    [COPresamp(:, 3), COPresamp(:, 1)] = ...
        resample(table2array(COPorig(:, 6)), ...
        table2array(COPorig(:, 4)), newFs);
    
    T = array2table(COPresamp, 'VariableNames', {'time','COPml','COPap'});
    
    writetable(T, fullfile(coppath, ...
        sprintf('resampled50Hz_%s', filesA{ith_file})))
    
    clear COPorig COPresamp T
    
end

% Visualization
% plot(COPorig(:,1),COPorig(:,2),'o-', COPresamp(:,1),COPresamp(:,2),'x-')
% legend('Original','Resampled')
