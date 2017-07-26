% process string or string cell and return individual elements in cell
%
% If separator given, use JUST that one! Or if list, try each one
%
% SPE 1/2/14
function rtn = getElements(line, separators, noData)
    rtn = {};

    if numel(line) == 0
        return;
    end
    
    % if string in a cell, take first element in cell
    if iscell(line)==1
        line = line{1};
        if iscell(line) == 1
            fprintf('getElements error: illegal input\n');
            return;
        end
    end
    
    % how many chars in line?
    len = numel(line);
    cidx = 1;
    arr = 0;    % allow processing arrays
    
    % if separator(s) not specified, use default list
    if exist('separators','var') == 0
        separators = [' ',',',':',';','#',9];
    end
    
    if exist('noData','var') == 0
        noData = '9999';
    end
    
    % remove separators at end of line (program hangs otherwise)
    while len > 0
        if sum(separators == line(end)) > 0
            len = len-1;
            line = line(1:len);
        else
            break;
        end
    end
    
    commaIsSeparator = 0; % process comma differently
    if sum(separators == ',') > 0
        commaIsSeparator = 1;
    end
    
    % process a token. BUT if two commas in a row, and comma is separator,
    % put noData
    lastWasComma = 0;
    while cidx <= len
        % eliminate all beginning spacing characters, except commas!
 
        while cidx < len   
            c = line(cidx);
            % eliminate all initial separator characters
            if sum(c == separators) == 0
                lastWasComma = 0;
                break;
            elseif lastWasComma == 1 && commaIsSeparator == 1
                rtn = [rtn,noData];
            end
            cidx = cidx + 1;
            if c == ',' 
                % process empty string, add no-data string                
                lastWasComma = 1;
            else
                lastWasComma = 0;
            end
        end
        % get string token        
        startidx = cidx;
        while cidx <= len
            c = line(cidx);
            if c == '['
                arr = 1;
            end
            if c == ']'
                arr=0;
            end
            
            if arr == 0 && sum(c == separators) > 0
                break;  % got next text token
            end
            cidx = cidx + 1;
        end            
        endidx = cidx - 1;
        % register string
        rtn = [rtn, line(startidx:endidx)];
     end
end

