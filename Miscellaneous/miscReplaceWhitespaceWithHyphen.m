function text = miscReplaceWhitespaceWithHyphen(text)

%{
Gets a string and replaces all the whitespaces with hyphen '-'
%}

for i=1:size(text, 2)
    if(text(i) == ' ')
        text(i) = '-';
    end
end

end