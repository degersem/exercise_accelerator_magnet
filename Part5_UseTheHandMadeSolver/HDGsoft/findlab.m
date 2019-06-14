function nr=findlab(dictionary,words)

% function nr=FINDLAB(dictionary,words)
% returns the numbers corresponding to the labels
% given in 'words' with respect to the list 'dictionary'
%
% input parameters
%     dictionary : list of labels
%     words      : list of labels to be transformed in numbers
%
% output parameters
%     nr        : list of corresponding numbers
%
% see also STRCMP
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~iscell(dictionary)
  hlpdictionary=dictionary; clear dictionary; dictionary{1}=hlpdictionary;
end
if ~iscell(words)
  hlpword=words; clear words; words{1}=hlpword;
end
numdict=length(dictionary);
numword=length(words);
nr=repmat(NaN,size(words));
for w=1:numword
  if ~isempty(words{w})
    d=0;
    b=0;
    while ~b & (d<numdict)
      d=d+1;
      b=strcmp(words{w},dictionary{d});
    end
    if b
      nr(w)=d;
    else
      fprintf(1,'Label %s not found in list, NaN returned\n',words{w});
      nr(w)=NaN;
    end
  end
end