function value = extractStringValue(str,label)

%\\ return the value from the input 'str' associated with the string in 'label'
% i1 = regexp(str,sprintf('"%s"',label)); % first index
i1 = strfind(str, label)-1; % the beginning index of the requested label
% i2 = regexp(str(i1:end),',|}','once'); % index of next field
i2 = strfind(str(i1(1):end), ','); % last index of the requested label
if(isempty(i2))
    i2 = strfind(str(i1(1):end), '|');
    if(isempty(i2))
       i2 = strfind(str(i1(1):end), '}'); 
    end
end
value = str(i1(1)+3+numel(label):i1(1)+i2(1)-2); % value
%% The following conditions are added in order to enable the functions logical(sscanf()) applicable
if(size(value, 2) == 5 || size(value, 2) == 4) 
   if(size(value, 2) == 5)
      value = '0';
   else
       value = '1';
   end
end

end