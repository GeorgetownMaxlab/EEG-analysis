%
% dat2xyz(filename_without_extension')
%
% create xyz electrode position file from dat and res files
%
% SPE 10/7/15
% Modified ETA
function dat2xyz_ETA(filebase)

% .dat file cades that we want to convey

incodes = [69,76,78,82]; % electrode,Left,Nasion,Right, respectively 
ref_incode = 88; % code for REF channed in dat file, but use pos from .res
rtn = 0;

datfile = [filebase,'.DAT'];
resfile = [filebase,'.res'];
outfile = [filebase,'.xyz'];
if exist(datfile,'file') == 0
    fprintf('error: can''t find %s\n',datfile);
    return;
end
if exist(resfile,'file') == 0
    fprintf('error: can''t find %s\n',resfile);
    return;
end

dt = fopen(datfile,'r');
if dt == -1
    fprintf('error: can''t open %s\n',datfile);
    return;
end
    
rs = fopen(resfile,'r');
if rs == -1
    fprintf('error: can''t open %s\n',resfile);
    return;
end

of = fopen(outfile,'w');
if of == -1
    fprintf('error: can''t create %s\n',outfile);
    return;
end

% get REF. locations from .res file
refvalsValid = 0;
while 1
    % get next line, break out of loop if end of file
    line = fgetl(rs);
    if ~ischar(line)
        break;
    end
    ln = getElements(line);
    if strcmp('REF.',ln{6}) == 1
        refvalsValid = 1;
        break;
    end
end
if refvalsValid == 0
    fprintf('error: could not find REF. locations in file %s\n',resfile);
    return;
end
% modify the position numbers
refX = str2double(ln{2}) * -0.1;
refY = str2double(ln{3}) * -0.1;
refZ = str2double(ln{4}) * 0.1;

% now process .dat file values as needed to create output
linenum = 1; % for numbering output lines
while 1
    % get next line, break out of loop if end of file
    line = fgetl(dt);
    if ~ischar(line)
        break;
    end
    ln = getElements(line);
    if numel(ln) < 5
        continue; % omit scalp points
    end
    code = str2double(ln{2});
    % look for REF substitution
    if code == ref_incode
        line2 = sprintf('%d%c%6.4f%c%6.4f%c%6.4f%cREF',linenum,char(9),refX,...
            char(9),refY,char(9),refZ,char(9));
        fwrite(of,[line2,13,10]);
        linenum = linenum + 1;
    else
        % is this a line to put in output?
        if sum(incodes == code) == 1
            % reformat as needed to get output
            line2 = sprintf('%d%c%s%c%s%c%s%c%s',linenum,char(9),ln{3},...
                char(9),ln{4},char(9),ln{5},char(9),ln{1});
            fwrite(of,[line2,13,10]);
            linenum = linenum + 1;
        end
    end
end % while 1
fclose(dt);
fclose(rs);
fclose(of);
fprintf('Created file %s with %d lines\n',outfile,linenum-1);
end % function