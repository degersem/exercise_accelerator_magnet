function exchange_solution(finfilename,foutfilename,u)

% function exchange_solution(finfilename,foutfilename,u)
% copy one FEMM solution file into another one while exchanging the solution
%
% input parameters
%    finfilename      : input file name or file pointer
%    foutfilename     : output file name of file pointer
%    u                : solution (IMPORTANT: WILL BE WRITTEN IN THE FILE "AS-IS", IN CASE OF VECTOR POTENTIALS, YOU SHOULD SCALE YOURSELF)

% A. Parameter check
if ischar(finfilename)
  fin = fopen(finfilename,'r');
else
  fin = finfilename;
end
if ischar(foutfilename)
    fout=fopen(foutfilename,'w');
else
    fout=foutfilename;
end

% B. Read, exchange and write
% B.1. Read and copy until the solution section
ln = '';
while ~feof(fin) & ~strcmp(ln,'[Solution]')
    ln = fgetl(fin);
    fprintf(fout,'%s\n',ln);
end
if feof(fin)
    error('Unexpected end-of-file found\n');
end
% B.2. Check the size of the solution vector
ln = fgetl(fin);                      % read the number of mesh nodes
numnode = str2num(ln);
if numnode~=length(u)
    error('Length of the solution vector does not match the number of mesh nodes\n');
end
fprintf(fout,'%d\n',numnode);
% B.3. Read and exchange the solution
ln = fgetl(fin);                      % read the first line to check whether a real-valued or a complex-valued solution is given
[values,num] = sscanf(ln,'%f');
values = [values'; fscanf(fin,'%f',[num numnode-1])'];
switch num
    case 3
        node = [ values(:,1:2) real(u) ];
        fprintf(fout,'%13.6e %13.6e %e\n',transpose(node));
    case 4
        node = [ values(:,1:2) real(u) imag(u) ];
        fprintf(fout,'%13.6e %13.6e %e %e\n',transpose(node));
    otherwise
        error('format problem encountered in exchange_solution.m');
end
% B.4. Copy the remainder of the file
ln = fgetl(fin);                      % discard the line termination
while ~feof(fin)
    ln = fgetl(fin);
    fprintf(fout,'%s\n',ln);
end

% C. Finish
if ischar(finfilename)
    fclose(fin);
end
if ischar(foutfilename)
    fclose(fout);
end


