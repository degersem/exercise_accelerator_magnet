function save_femmdata(femmdata,foutfilename)

% function SAVE_FEMMDATE(femmdata,foutfilename)
% saves a FE-prb structure into a FEMM-formatted .ans file
%
% input parameters
%     femmdata       : FEMM data
%     foutfilename   : file name or file pointer
%
% output parameters
%
% see also READ_FEMMDATA
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Parameter control
if ischar(foutfilename)
  fout=fopen(foutfilename,'w');
else
  fout=foutfilename;
end

% B. Write everything
fld=fieldnames(femmdata);
for q=1:length(fld)
  switch fld{q}
    case {'Format','Frequency','Precision','MinAngle','LengthUnits','ProblemType','Coordinates','ACSolver','Comment'}
      fprintf(fout,'[%s] = %s\n',fld{q},femmdata.(fld{q}));
    case 'Depth'                 % single double number
      fprintf(fout,'[%s] = %13.6e\n',fld{q},femmdata.(fld{q}));
    case {'BdryProps','BlockProps','CircuitProps','PointProps'}
      fprintf(fout,'[%s] = %d\n',fld{q},length(femmdata.(fld{q})));
      name=fld{q}(1:end-5);
      for p=1:length(femmdata.(fld{q}))
        fprintf(fout,'  <Begin%s>\n',name);
        subfld=fieldnames(femmdata.(fld{q}));
        for r=1:length(subfld)
          fprintf(fout,'    <%s> = %s\n',subfld{r},femmdata.(fld{q})(p).(subfld{r}));
        end
        fprintf(fout,'  <End%s>\n',name);
      end
    case 'points'
      fprintf(fout,'[NumPoints] = %d\n',size(femmdata.points,1));
      fprintf(fout,'%13.6e %13.6e %d %d\n',transpose(femmdata.points(:,1:4)));
    case 'segments'
      fprintf(fout,'[NumSegments] = %d\n',size(femmdata.segments,1));
      fprintf(fout,'%d %d %d %d %d %d\n',transpose(femmdata.segments(:,1:6)));
    case 'arcsegments'
      fprintf(fout,'[NumArcSegments] = %d\n',size(femmdata.arcsegments,1));
      fprintf(fout,'%d %d %13.6e %d %d %d %d\n',transpose(femmdata.arcsegments(:,1:7)));
    case 'holes'
      fprintf(fout,'[NumHoles] = %d\n',size(femmdata.holes,1));
      fprintf(fout,'%13.6e %13.6e %13.6e\n',transpose(femmdata.holes(:,1:3)));
    case 'blocklabels'
      fprintf(fout,'[NumBlockLabels] = %d\n',size(femmdata.blocklabels,1));
      fprintf(fout,'%d %d %d %d %d %d %d %d %d\n',transpose(femmdata.blocklabels(:,1:9)));
      % in the case of electric problems, the number of columns is different, then use the code below
      % numcol=size(femmdata.blocklabels,2);
      % fprintf(fout,[repmat('%d ',1,numcol) '\n'],transpose(femmdata.blocklabels(:,1:numcol)));
    case 'node'
      fprintf(fout,'[Solution]\n');
      fprintf(fout,'%d\n',size(femmdata.node,1));
      %if sscanf(femmdata.Frequency,'%13.6e')==0               % static case
      if norm(imag(femmdata.node(:,3)))<1e-14*norm(real(femmdata.node(:,3)))
        tmp=[femmdata.node(:,1:2) real(femmdata.node(:,3))];
        fprintf(fout,'%13.6e %13.6e %e\n',transpose(tmp));
      else                                                % time-harmonic case
        tmp=[femmdata.node(:,1:2) real(femmdata.node(:,3)) imag(femmdata.node(:,3))];
        fprintf(fout,'%13.6e %13.6e %e %e\n',transpose(tmp));
      end
    case 'elem'
      fprintf(fout,'%d\n',size(femmdata.elem,1));
      fprintf(fout,'%d %d %d %d\n',transpose(femmdata.elem(:,1:4)));
    case 'whatisthis'
      fprintf(fout,'%d\n',size(femmdata.whatisthis,1));
      if sscanf(femmdata.Frequency,'%f')==0          % static case
        tmp=[femmdata.whatisthis(:,1) real(femmdata.whatisthis(:,2))];
        fprintf(fout,'%d %e\n',transpose(tmp));
      else                                           % time-harmonic case
        tmp=[femmdata.whatisthis(:,1) real(femmdata.whatisthis(:,2)) imag(femmdata.whatisthis(:,2))];
        fprintf(fout,'%d %e %e\n',transpose(tmp));
      end
    otherwise
      % do nothing, HDG added some fields in the structure
      %13.6eprintf(fout,'[%s] = %s\n',fld{q},femmdata.(fld{q}));
  end
end

% C. Finish
if ischar(foutfilename)
  fclose(fout);
end

