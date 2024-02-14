function qrs = qrs_detection_AF2(ecg_data)

    %inputs:
    % ecg_data - data from the selected lead

    l = height(ecg_data);
    qrs = zeros(l,1); %create a vector to save all the r piks
    
    a_ths = 0.4 * max(ecg_data); %Amplituse thershold
    
    % fill y0 with only positive values
    y0 = abs(ecg_data); %hold all the values as positive floats
     
    % change values before the thershold to the threshold value
    y1 = max(y0, a_ths); % hold all the values that are above thershold

    
    y2 = zeros(l,1); % first derivative

    % calculate first derivative
    for i = 2:l-1
        y2(i) = y1(i+1) - y1(i-1);
    end
    
    % chack for the QRS condition
    max_d = 0.3 * max(y2);
    for i = 2:l-1
        if y2(i-1) < y2(i) && ...
            y2(i) > y2(i+1) && ...
            y2(i) > max_d

            qrs(i) = 1;
            i = i +65;
        end
    end
    
    % Shift by 6 from the filtering shift
    for i = length(qrs):-1:1
        if qrs(i) == 1
            qrs(i+6) = 1;
            qrs(i) = 0;
        end
    end
   
end
