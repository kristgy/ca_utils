function ch = modulo_checkdigit(ocr)

ocr=str2double(regexp(num2str(ocr),'\d','match'));

% tests
%ocr = [7 8 0 3 1 7 9 2 9 5 0 0 0 1 8 7]; % checkdigit 6
%ocr = [9 7 1 7 2 1 7 7]; % checkdigit 4
%ocr = [1 2 3 4 5 6 8]; % checkdigit 2
%ocr = [2 8 7 6 8 0 0] % checkdigit 0
%ocr = [2 8 0 0 0]; % checkdigit 8

weigths = repmat([1 2],1,13);

pr = ocr.*weigths(end-length(ocr)+1:end);

pr(pr>9) = pr(pr>9) - 9;

ch = mod(10 - mod(sum(pr),10),10);

