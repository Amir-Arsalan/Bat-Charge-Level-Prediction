function userData = procCalcChargeRate(userData, mode)
%{
This function calculates charge/discharge rate for each record in the user
data set

Inputs:

userData: An N by 8 matrix where N is the number of data records and 8 is the number
of attributes for each record
mode: If 1 returns the userData augmented with an additional column of
charge/discharge rate. If 0, returns only the charge/discharge column
%}

userData = [userData, zeros(size(userData, 1), 1)];

for i=2:size(userData, 1)
    userData(i, end) = userData(i - 1, 6) - userData(i, 6);
end

if(mode == 0)
    userData = userData(:, end);
end

end