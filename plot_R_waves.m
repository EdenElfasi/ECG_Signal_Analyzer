function plot_R_waves(data, r_waves, x_axis, title_text, sub_num)
    % Inputs:
    % data - Vector; The data of the ecg lead that you want to plot
    % r_waves - Vector; Holds the locations for the qrs detection
    % x_axis - Vector; Has the values for the x-axis
    % title_text - String; 
    % sub_num - the location you want your plot to be in the subplots

    subplot(3, 1, sub_num);
    plot(x_axis{sub_num}, data{sub_num}, 'LineWidth',0.2,'Color', 'black')
    hold on
    plot(x_axis{sub_num}(r_waves{sub_num} > 0), r_waves{sub_num}(r_waves{sub_num} > 0), 'r*');
    title(title_text{sub_num});
    xlabel('Time[s]');
    ylabel('Amplitude[mV]');
    legend('ecg data lead 2', 'R Waves detection')
    ax = gca;
    ax.TitleFontSizeMultiplier = 1.5;
    ax.FontSize = 8;
end