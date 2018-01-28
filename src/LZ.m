% Important note: the input mast contain numbers only.

rng default; % For reproducibility

% Import the data:
[~, ~, raw] = xlsread('C:\Users\bm\Desktop\matlab\table1text.xlsx','������1','A2:E11');
 
% Replace non-numeric cells with 0.0:
R = cellfun(@(x) (~isnumeric(x) && ~islogical(x)) || isnan(x),raw); % Find non-numeric cells
raw(R) = {0.0}; % Replace non-numeric cells

% Create output variable:
dataAsNums = reshape([raw{:}],size(raw));

% Find out data size:
[rows, columns] = size(dataAsNums);

% Quantization level -
% Convert our data to string:
dataAsStr = '';
for i = 1:rows
    for j = 2:columns
        ascii = 65 + dataAsNums(i,j) / 10;
        if ascii < 65 % === if dataAsNums(i,j) < 0
            ascii = 65;
        elseif ascii > 90
            ascii = 90;
        end
        dataAsStr = strcat(dataAsStr,char(ascii));
    end
end
disp(dataAsStr);
%----------------------------
% alfabeto = ['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'W' 'Z' ];
% stringa = dataAsStr;
% [~,~,d] = lempelZiv(alfabeto, stringa);
% disp(d);
%----------------------------

% Variables for LZ78 Algorithm:
[~, dataLength] = size(dataAsStr);
dict = cell(1,dataLength); % Dictionary
fatherLocation = zeros(1,dataLength);
currentString = '';
currentDictIndex = 1;

% Build the dictionary:
for i = 1:dataLength
    currentString = strcat(currentString,dataAsStr(i));
    index = isFound(currentString, dict, currentDictIndex);
    if index == 0 % If currentString isn't in the dictionary
        dict(currentDictIndex) = {currentString};
        currentDictIndex = currentDictIndex + 1;
        currentString = '';
    else
        fatherLocation(currentDictIndex) = index;
    end
end

% Finall dictionary, without empty cells ('dict' contains empty cells for efficiency):
dataLength = currentDictIndex - 1;
finallDict = cell(1,dataLength);
for i = 1:currentDictIndex-1
    finallDict(i) = dict(i);
end

% Build & draw the tree:
nodes = zeros(1,dataLength);
for i = 1:dataLength
    nodes(i+1) = fatherLocation(i) + 1;
%     figure;
%     hold on
%     treeplot(nodes);
%     hold off
end

c = 1;
organize = zeros(1,max(nodes));
for i = 1:dataLength
    if organize(nodes(i+1)) == 0
        organize(nodes(i+1)) = c;
        c = c + 1;
    end
end

% lzTree = {};
% for i = 1:dataLength
%     loc = nodes(i+1);
%     value = char(finallDict(i));
%     lzTree(loc) = {value};
% end

counterSons = zeros(1,max(nodes));
for i = 1:dataLength
    counterSons(nodes(i+1)) = counterSons(nodes(i+1)) + 1;
end

binArr = zeros(1,max(nodes));
copyCounterSons = zeros(1,max(nodes));
for i = 1:dataLength
    copyCounterSons(i) = 0;
end

lzTree = {};
for i = 1:dataLength
    loc = 1;
    value = char(finallDict(i));
    len = nodes(i+1);
    for k = 1:max(nodes)
        if organize(k) ~= 0 && organize(k) < organize(len) && binArr(organize(k)) == 0
            loc = loc + counterSons(k);
            binArr(organize(k)) = 1;
            disp("len = " + len + ", loc = " + loc);
        end
    end
    binArr = zeros(1,max(nodes));
    loc = loc + copyCounterSons(len);
    disp("len = " + len + ", finLoc = " + loc);
    %disp(loc);
    %loc = findLocation(len, counterSons);
    lzTree(loc) = {value};
    copyCounterSons(len) = copyCounterSons(len) + 1;
    %counterSons(len) = counterSons(len) - 1;
end

% disp(counterSons);
%disp(finallDict);
%disp(nodes);
% view(lzTree);
%treeplot(nodes);
% disp(lzTree);

% -------------------------------------------------------------------------
% Function that get string, array of strings and the size of the array
% and check if the string appears inside the array or not.
% If so, return the index. Otherwise, return zero.
function fatherIndex = isFound(currentString, dict, currentDictIndex)
    for i = 1:currentDictIndex
        if strcmp(currentString,dict(i))
            fatherIndex = i;
            return
        end
    end
    fatherIndex = 0;
end
%--------------------------------------------------------------------------
% TODO - not our code...
% y will return true or false , x is the string to be searched to be entered with function call, the search is bfs (bruth first search)
function y = searchStr(x , tree) 
remain_search = length(x);
while remain_search~=0 % keep working until all input search string is checked
   if remain_search>5 % for search string longer then max dictionary object length
       str5 = x(1:5); % set the 5 first chars to temp variable
       t = tree(32:62); % get indexes for length 5 in lz tree
       temp_tree= t(~cellfun('isempty',t)); % erase empty cells to allow ismember function 
       if ismember(str5 ,  temp_tree)  %check if first 5 digits are in the tree          
            x = x(6:remain_search); % if true, check the rest of search string
            remain_search = length(x);
       else % first 5 digits not exist in lz tree, the search string is not in our bin
            y = 'did not find match';
           remain_search = 0;
       end
   else % get the tree location for next length. 
       low = 2.^remain_search;
       high = 2.^(remain_search+1)- 1;
       if high>62
           high = 62;
       end
       p =  tree(low:high);
       new_temp_tree= p(~cellfun('isempty',p));
       if ismember(x , new_temp_tree)
            y = 'match was found';
       else
            y = 'did not find match';
       end
       remain_search = 0;
    end
end
end