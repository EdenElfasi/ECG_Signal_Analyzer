function heart_rate = hr_calc(qrs, fs)

    qrs_locs = find(qrs > 0);

    % Calculate the differences between consecutive non-zero indices
    r_r_interval = qrs_locs(2:end) - qrs_locs(1:end-1);
    r_r_interval = r_r_interval ./ fs;

    %calculate the heart reate for each r-r interval
    heart_rate = 60 ./ r_r_interval;
end