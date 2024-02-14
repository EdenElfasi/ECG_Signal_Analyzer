function plot_ecg_data(data, x_axis, title_text, sub_num, x_label, y_label, sprintf_format)
    % Inputs:
    % data - Vector; The data that you want to plot
    % x_axis - Vector; Has the values for the x-axis
    % title_text - String; The title you want with string 
    % interpolation with it in the correct location for numbering
    % sub_num - the location you want your plot to be in the subplots
    % x_label - String
    % y_label - string

    subplot(3, 1, sub_num);
    plot(x_axis, data{sub_num}, 'LineWidth', 0.5, 'Color', 'black');
    if sprintf_format == 1
        title(sprintf(title_text, sub_num));
    else
        title(title_text{sub_num})
    end
    xlabel(x_label);
    ylabel(y_label);
    grid on;
%     ax = gca;
%     ax.TitleFontSizeMultiplier = 1.5;
%     ax.FontSize = 10;
end