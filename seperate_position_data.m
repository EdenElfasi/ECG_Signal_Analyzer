function [position_data,position_time_vector] = seperate_position_data(start_time, end_time, original_data, original_time_vector, fs)
    
    if start_time == 0
        start_index = 1;
    else
        start_index = (fs * start_time) + 1;
    end
    end_index = fs * end_time;
    
    % Seperate recording data of position from the data
    position_data = original_data(start_index:end_index);
    position_time_vector = original_time_vector(start_index:end_index);
end