%% load the data
ecg_data = readtable("ECG_A.txt");

% Create time vector
fs = 500;
time_length_ecg = height(ecg_data);

start_value = 0;
end_value = time_length_ecg / fs;

time_vector = linspace(start_value, end_value, time_length_ecg);

% Extract all leads from the data
lead_1 = ecg_data.LI;
lead_2 = ecg_data.LII_Calc__;
lead_3 = ecg_data.LIII;

%% Plots of Raw Data

% Put all leads in 1 vector to match the plot function
leads ={lead_1, lead_2, lead_3};

title_text_unfil = "Lead %i of ECG Unfiltered";

figure;
for sub_num=1:3
    plot_ecg_data( ...
        leads, time_vector, title_text_unfil, ...
        sub_num, 'Time [sec]', 'Amplitude [mV]', 1)
    xlim([0 60]);
end

%% Filter the data

% Design the bandpass filter
% filter order = 100
% Low and high cutoff frequencies that match the ecg signal
bpf = fir1(100, [8/(fs/2) 50/(fs/2)]);

% Put the signals in the filter
lead_1_filter=filter(bpf,1,lead_1);
lead_2_filter=filter(bpf,1,lead_2);
lead_3_filter=filter(bpf,1,lead_3);

% Plot the filtered signals
% Create x-axis
t_f = (0:length(time_vector)-1) / fs; 

% Put all data in 1 vector to match the plot function
leads_filtered = {lead_1_filter, lead_2_filter, lead_3_filter};

title_text_filtered = "Lead %i of ECG Filtered";

figure;
for sub_num=1:3
    plot_ecg_data( ...
        leads_filtered, t_f, title_text_filtered, sub_num, ...
        'Time [sec]', 'Amplitude [mV]', 1)
end

%% The signals in the frequency axis

% Compute the FFT of the original and filtered signals
fft_lead1 = fft(lead_1);
fft_lead2 = fft(lead_2);
fft_lead3 = fft(lead_3);

fft_filtered_lead1 = fft(lead_1_filter);
fft_filtered_lead2 = fft(lead_2_filter);
fft_filtered_lead3 = fft(lead_3_filter);

% Create frequency axis
n = height(ecg_data);
frequencies = fs/n * ((-(n-1)/2):((n-1)/2));

% Put all data in 1 vector to match the plot function
fft_leads = {...
    abs(fftshift(fft_lead1)),...
    abs(fftshift(fft_lead2)),...
    abs(fftshift(fft_lead3))};

fft_filtered_leads = {...
    abs(fftshift(fft_filtered_lead1)),...
    abs(fftshift(fft_filtered_lead2)),...
    abs(fftshift(fft_filtered_lead3))};

title_text_fft_unfilterd = "Lead %i of ECG Unfiltered in the Frequency axis";
% Plot Unfiltered
figure;
for sub_num=1:3
    plot_ecg_data( ...
        fft_leads, frequencies, title_text_fft_unfilterd, sub_num, ...
        'Frequency [Hz]', 'Amplitude [mV]', 1)
end

% Plot filtered
figure
title_text_fft_filtered = "Lead %i of ECG Filtered in the Frequency axis";
for sub_num=1:3
    plot_ecg_data( ...
        fft_filtered_leads, frequencies, title_text_fft_filtered, sub_num, ...
        'Frequency [Hz]', 'Amplitude [mV]', 1)
end

%% QRS Detection - All calculation are based on lead_2 - AF2 Algorithm

% Separate the measurement to the different parts of recordings

%% Seating
% Find the index when seating ends 
% Seating recording was 30 sec, fs = 500 Hz
[seating_data, seating_time_vector]  = seperate_position_data( ...
    0, 30, lead_2_filter, time_vector, fs);

% Find R waves for the seating duration
qrs_seating = qrs_detection_AF2(seating_data);
qrs_seating = qrs_seating .* seating_data;

%% Standing
% Standing recording was 20 sec (30 sec - 50 sec)
% Seperate recording data of standing
[standing_data, standing_time_vector]  = seperate_position_data( ...
    30, 50, lead_2_filter, time_vector, fs);

% Find R waves for the standing duration
qrs_standing = qrs_detection_AF2(standing_data);
qrs_standing = qrs_standing .* standing_data;

%% Standing with heavy breathing
% Standing with heavy breathing recording was 10 sec (50 sec - 60 sec)

[standing_heavy_breath_data, standing_heavy_breath_time_vector]  = ...
seperate_position_data( ...
50, time_vector(end), lead_2_filter, time_vector, fs);

% Find R waves for the standing with heavy breathing duration
qrs_standing_heavy_breath = qrs_detection_AF2(standing_heavy_breath_data);
qrs_standing_heavy_breath =... 
    qrs_standing_heavy_breath .* standing_heavy_breath_data;

%% Plot the QRS Detection

titles = {'Detected R Waves for Lead 2 in Seating Postion', ...
    'Detected R Waves for Lead 2 in Satnding Postion', ...
    'Detected R Waves for Lead 2 in Satnding Postion With Heavy Breating'};

qrs = {qrs_seating, qrs_standing, qrs_standing_heavy_breath};

ecg = {seating_data, standing_data, standing_heavy_breath_data};

x_axis = {seating_time_vector, standing_time_vector,...
    standing_heavy_breath_time_vector};

figure;
for sub_num = 1:3
    plot_R_waves( ...
        ecg, qrs, x_axis, ...
        titles, sub_num)
end
%% Heart Rate Calculation % Mean HR Calculation

seating_hr = hr_calc(qrs_seating, fs);
standing_hr = hr_calc(qrs_standing, fs);
standing_heavy_breathing_hr = hr_calc(qrs_standing_heavy_breath, fs);

seating_mean_hr = mean(seating_hr);
standing_mean_hr = mean(standing_hr);
standing_heavy_breathing_mean_hr = mean(standing_heavy_breathing_hr);

seating_std = std(seating_hr);
standing_std = std(standing_hr);
standing_heavy_breathing_std = std(standing_heavy_breathing_hr);

%% t-test for Standing Part

standing_hr = reshape(standing_hr,[],1);
standing_heavy_breathing_hr = reshape(standing_heavy_breathing_hr,[],1);

num_beat_cycles = length(find(qrs_standing_heavy_breath > 0));

[h,p] = ttest(standing_hr(1:length(standing_heavy_breathing_hr)), ...
    standing_heavy_breathing_hr);
