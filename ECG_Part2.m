%% load that data
ecg_data = readtable("ECG_A.txt");


lead_2 = ecg_data.LII_Calc__;

fs = 500; % Define the sampling frequency

% Create time vector
time_length_ecg = height(ecg_data);

start_value = 0;
end_value = time_length_ecg / fs;

time_vector = linspace(start_value, end_value, time_length_ecg);
%% Filter the data

% Design the bandpass filter
bpf = fir1(100, [8/(fs/2) 50/(fs/2)]);

leadd_2_filter=filter(bpf,1,lead_2);


%% QRS Detection for HR calculation

qrs = qrs_detection_AF2(leadd_2_filter);

qrs = qrs .* leadd_2_filter;

%% Heart Rate Calculation & Mean HR Calculation

hr = hr_calc(qrs, fs);
mean_hr = mean(hr);

std_hr = std(hr);

%% 15 beats graph

selected_beats = hr(8:22);
x_axis = 8:1:22;
ymin = mean_hr-std_hr;
ymax = mean_hr+std_hr;

figure;
plot(x_axis, selected_beats, '*', 'LineWidth',3,'Color', 'b')
title('15 Beats Herat Rate with Mean and STD information');
xlabel('Beat Number');
ylabel('BPM');
yline(mean_hr, '-','Mean Heart Rate');
ylim([60 80]);
xlim([7 23]);
yline([ymin ymax],'--',{'Mean Heart Rate - STD','Mean Heart Rate + STD'})

%% Seperate all beats

qrs_locs = find(qrs > 0);
beats = {};

for r = 1:length(qrs_locs)
    beat_start = qrs_locs(r) - 0.2*fs;
    beat_end = qrs_locs(r) + 0.3*fs;
    if beat_end < 0
        beat_start = 0;
    elseif beat_end > length(leadd_2_filter)
        beat_end = leadd_2_filter;
    else
        beats{end+1} = leadd_2_filter(beat_start:beat_end);
    end
end

num_of_beats = length(qrs_locs);
sum_beats = zeros(251, 1);

% Calculate the mean for each element across the cells
for i = 1:length(beats)
    sum_beats = sum_beats + beats{i};
end

mean_beats = sum_beats / length(beats);


%% First and Last Beat
bl = length(mean_beats);
first_beat_beg = qrs_locs(1) - 0.2*fs;
first_beat_end = qrs_locs(1) + 0.3*fs;
last_beat_beg = qrs_locs(end) - 0.2*fs;
last_beat_end = qrs_locs(end) + 0.3*fs;
bl = length(mean_beats);
time_first_beat = linspace(first_beat_beg,first_beat_end,bl);
time_last_beat = linspace(last_beat_beg,last_beat_end,bl);

first_beat = leadd_2_filter(time_first_beat);
last_beat = leadd_2_filter(time_last_beat);
%% Plot Mean beats

figure;
data_beats = {mean_beats,first_beat,last_beat};
time_single_beat = time_vector(1:length(mean_beats));

times = {time_single_beat, time_single_beat, time_single_beat};
titles ={'The Avarge of Beats Over Time', 'First Beat Over Time', 'Last Beat Over Time'};

for sub_num = 1:3
    plot_ecg_data(data_beats, times{sub_num}, titles, sub_num, 'Time [sec]', 'Amplitude[mV]', 0)
    ylim([-0.2 0.2]);
end

%% SNR calculations

% Isoelectric line of the mean heart beat
isoelc_data_mean= mean_beats((0.3*fs):(0.4*fs));

% Find mean and STD
mean_voltage_isoelc = mean(isoelc_data_mean);
std_isoelec_mean = std(isoelc_data_mean);

% Isoelectric line of the first beat - mean and STD
isoelc_data_first= first_beat((0.3*fs):(0.4*fs));

% Find mean and STD
first_mean_voltage_isoelc = mean(isoelc_data_first);
std_isoelec_first = std(isoelc_data_first);

% Isoelectric line of the last beat - mean and STD
isoelc_data_last= last_beat((0.3*fs):(0.4*fs));

% Find mean and STD
last_mean_voltage_isoelc = mean(isoelc_data_last);
std_isoelec_last = std(isoelc_data_last);

%% Mean Value VS. First Beat - only peak

snr_mean_beat_peak = max(mean_beats) / std_isoelec_mean;

snr_first_beat_peak = max(first_beat) / std_isoelec_first;

%% SNR Mean Beat

snr_mean_beat = mean_beats .* std_isoelec_mean;
snr_first_beat = first_beat .* std_isoelec_first;


figure;
plot(time_single_beat, snr_mean_beat, 'LineWidth',2,'Color', 'b')
title('SNR of First and Mean Beat');
xlabel('Time [sec]');
ylabel('Amplitude [mV]');
hold on
plot(time_single_beat, snr_first_beat, 'LineWidth',2,'Color', 'r')
hold off
legend('SNR Mean Beat', 'SNR First Beat')
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 10;

%% SNR diff

snr_improv = abs(snr_first_beat - snr_mean_beat);

figure;
plot(time_single_beat, snr_improv);
title('SNR Improvement');
xlabel('Time [sec]');
ylabel('SNR diff');
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 10;
