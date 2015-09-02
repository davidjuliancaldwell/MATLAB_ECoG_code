0%%
function B = swap_ends(A)
if size(A,2) == 1
    B = A;
else
    B = A;
    B(:,1) = A(:,end);
    B(:,end) = A(:,1);
end
end
%%
function y = pizza(z,a)
y = pi*z*z*a;
end
%%
function tf = mono_increase(x)
sorted = sort(x);
if length(unique(sorted)) == length(x)
    if sorted == x
        tf = true;
    else
        tf = false;
    end
else
    tf = false;
end
end
%%
function f = fib(n)
if n == 0
    f = 0;
elseif n == 1
    f = 1;
else
    f = fib(n-1)+fib(n-2);
end
end
%%
function m = timestables(n)
m = ones(n);
for i = 1:n
    for j = 1:n
        m(i,j) = i*j;
    end
end
end
%%
function b = isItSquared(a)
square = a.^2;
if sum(ismember(a,square))>0
    b = true;
else
    b = false;
end
end
%%
function B = remove_nan_rows(A)
B = A;
count = 0;
for i = 1:size(A,1)
    if (ismember(1,isnan(A(i,:))))
        B(i-count,:) = [];
        count = count + 1;
    end
end
end
%%
function B = remove_nan_rows(A)
B = A;
B(any(isnan(B),2),:)=[];
end
%%
function out = meanOfPrimes(in)

out = mean(in(isprime(in)));

end

%%
function r = fullest_row(a)

b = a~=0;
sum_b = sum(b,2);
[~,r] = max(sum_b);

end
%%
function b = back_and_forth(n)

b = ones(n);
nums = [1:n.^2];
nums_counter = 1;

counter_row = 1;

while counter_row <= n
    
    if mod(counter_row,2) > 0
        counter_column = 1;
        while counter_column <= n
            b(counter_row,counter_column) = nums(nums_counter);
            counter_column = counter_column + 1;
            nums_counter = nums_counter + 1;
        end
        
    else
        counter_column = n;
        while counter_column > 0
            b(counter_row,counter_column) = nums(nums_counter);
            counter_column = counter_column - 1;
            nums_counter = nums_counter + 1;
        end
    end
    
    counter_row = counter_row + 1;
    
end
end

%better
function b = back_and_forth(n)

nums = [1:n.^2];
a = reshape(nums,n,n)';
b = a;
for i = 1:n
    if mod(i,2) == 0
        b(i,:) = fliplr(b(i,:));
    end
end

end
%%
function c = collatz(n)
c = [n];

while n~=1
    if mod(n,2) == 0
        n = n/2;
        c = [c, n];
    else
        n = 3*n + 1;
        c = [c, n];
        
    end
end
end
%%
function b = most_change(a)

money_val = [0.25 0.05 0.1 0.01];
person_val = bsxfun(@times,a,money_val);
summed = sum(person_val,2);
[~,b] = max(summed);

end
%%
function b = sumDigits(n)

squared = 2^n;
b = 0;
while squared~=0
    digit = mod(squared,10);
    squared = floor(squared/10);
    b = b + digit;
end

end

%%
function zSorted = complexSort(z)
absz = abs(z);
zSorted = sort(z,'descend');
end
%%
function s2 = refcn(s1)

expression = '[aeiouAEIOU]';
replace = '';
s2 = regexprep(s1,expression,replace);

end
%%
%pick first and last numbers in the prime_subtracted
function [p1,p2] = goldbach(n)

p = primes(n);
subtracted = bsxfun(@minus,n,p);
prime_subtracted = subtracted(isprime(subtracted));
p1 = prime_subtracted(1);
p2 = prime_subtracted(end);

end
%%
function y = threeTimes(x)

y = [];
[bincounts,ind] = histc(x,[min(x):max(x)]);
bin_3 = find(bincounts == 3);
for n = bin_3
    y = [y x(find(ind == n))];
end
y = sort(unique(y));

end

%different way
function y = threeTimes(x)

[bincounts,ind] = histc(x,unique(x));
bin_3 = find(bincounts == 3);
index = find(ismember(ind,bin_3));
y = sort(unique(x(index)));

end

%%
function b = targetSort(a,t)

[temp,i] = sort(abs(a-t),'descend');
b = a(i);

end
%%
function y = nearZero(x)

% find indices where x==0
zero_ind = find(x==0);

% pad matrix on right so if zero at end can search right
right_pad = [x 0];
% find values on right side of zero
max_right = right_pad(zero_ind+1);

%pad left
left_pad = [0 x 0];
max_left = left_pad(zero_ind);

%combine matrices
maximum = [max_right max_left];
% get rid of zero in case all possible ones are negative!
maximum_nozero = maximum(maximum~=0);

% set y to maximum of these values
y = max(maximum_nozero);

end
%%
function a = bullseye(n)

a = zeros(n);
center = (n+1)/2;
nums = [1:center];


i = center;
j = center;

a(i,j) = 1;
while i <=n
    
    
end

end
%%
function [index1,index2] = nearestNumbers(nums)

end

%%
function y = sum_int(x)

x2 = 2.^x;
y = sum([1:1:x2]);

end

%%
function y = sortok(x)
sorted_x = sort(x);

if sorted_x == x
    y = 1;
else
    y = 0;
end
end

%%
function salary = ComputeSalary(wage)

salary = wage*50*40;       % Modify to wage * ???

end

%%
function y = weighted_average(x,w)

y = (x*w')/length(x);

end

%%
function y = reverse(x)

y = flip(x);

end

%%
function area = CircleArea(radius)

area = pi*(radius.^2);   % Modify this. Use built-in math constant pi.

end


%%
function y = zaphod(x)

if x == 42
    y = 1;
else
    y =0;
end

end

%%
function posX = findPosition(x,y)

posX = 0;

for i = 1:length(x)
    if x(i) == y
        posX = i;
        break;
    end
end

end

%%
function C = F2C( F )

frac = 5/9;

C = frac*(F-32);   % Replace with two statements

end

%%
function y = your_fcn_name(x)

y = sum(abs(diff(x)));

end

%%
function count = CreateCountdown()

count = [9:-1:1];

end

%%


function [index1 index2] = nearestNumbers(A)

diffMat = zeros(length(A));

for i = 1:length(A)
    for j = 1:length(A)
        diffMat(i,j) = abs(A(i)-A(j));
        
        if (i ==1 && j == 1)
            i = 1;
            j = 2;
        end
        
        if (i == 1 && j == 2)
            distance = diffMat(i,j);
            index1=min(i,j);
            index2=max(i,j);
        end
        
        if (diffMat(i,j)<distance && (i~=j))
            distance = diffMat(i,j);
            index1 = min(i,j);
            index2 = max(i,j);
        end
        
        
    end
end

end

%%
function [x1,x2] = rollDice()
x1 = randi([1 6],1,1);
x2 = randi([1 6],1,1);
end

%%
function out_str = cellstr_joiner(in_cell, delim)

out_str = [in_cell{1} delim];

for i = 2:(length(in_cell)-1)
    
    out_str = [out_str in_cell{i} delim];
    
end

out_str = [out_str in_cell{end}];
end

%%

function y = pascalTri(n)

a = pascal(n+1);
b = rot90(a);
y = diag(b)';

end

%%
function A = binary_numbers(n)

A = zeros(2^n,n);

upperLim = 2^n-1;

for i = 0:upperLim
    
    binNum = dec2bin(i,n);
    
    for j = 1:n
        A(i+1,j) = str2num(binNum(j));
    end
end

end

%%

function y = replace_nans(x)

y = x;

if isnan(x(1))
    
    y(1) = 0;
    
end

for i = 2:length(x)
    
    if isnan(x(i))
        
        temp = y(i-1);
        
        y(i) = temp;
        
    end
end

end

%% balanced number

function tf = isBalanced(n)

tf = false;

end

%% reverse run length encoder

function y = RevCountSeq(x)

numEls = x(1:2:end);
onez = ones(length(numEls),1);
outputVecLength = numEls*onez;
y = [];

nums = x(2:2:end);

for i = 1:length(numEls)
    for j = 1:numEls(i)
        y_temp(j) = nums(i);
    end
    y = [y y_temp];
    y_temp = [];
    
end

end

%%  return a list sorted by number of occurences

function y = popularity(x)

sorted = sort(x);
[n,a] = hist(sorted,[min(sorted):1:max(sorted)]);

sizeOut = numel(n(n~=0));

y = zeros(1, sizeOut);

counts = n(n~=0);
vals = a(n~=0);

for i = 1:sizeOut
    
    [value, ind] = max(counts);
    y(i) = vals(ind);
    
    counts(ind) = 0;
    
end

end

%% de-dupe

function b = dedupe(a)

b = unique(a,'stable');

end

%% pattern matching

function b = matchPattern(a)

b = diff(a,1,2);
c = (abs(diff(a,1,2)));
b(isnan(b))=0;
c(isnan(c))=0;
directions = b./c;
directions(isnan(directions))=0;

sums = sum(abs(bsxfun(@minus,directions(1,:),directions((2:end),:))),2);
same = (sums == 0)';

b = find(same==1)+1;

end

