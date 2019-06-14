function wrs = wire_initialise_from_femmdata(femmdata)
% function wrs = wire_initialise_from_femmdata(femmdata)
%   initialises the wire data structure from FEMM data
%
% Inputs
%    femmdata            : FEMM data
%
% Outputs
%    wrs                 : wire data structure
%
% Author
%   Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if isfield(femmdata,'Frequency') & (sscanf(femmdata.Frequency,'%f')~=0)
  warning('all currents and voltages are divided by sqrt(2) (FEMM uses peak values, we use rms values)\n');
end
%prb.idxwire=];                                                            % [@]    : indices of the nodes at wire cross-sections
wrs=repmat(struct('label',[],'type',[],'NtI',[],'k',[]),0,0);              % []     : wire data structure
%prb.Qwire=sparse(0,0);                                                    % []     : wire connection matrix
if isfield(femmdata,'CircuitProps')
  idxelem2circ=femmdata.blocklabels(femmdata.elem(:,4),5);                 % []     : indices of the circuits
  %idxwire=zeros(0,1);                                                     % []     : indices of nodes at wire cross-sections
  %Qwirelist=zeros(0,3);
  for wr=1:length(femmdata.CircuitProps)
    wrs(wr).label=femmdata.CircuitProps(wr).CircuitName(2:end-1);
    wrs(wr).type=sscanf(femmdata.CircuitProps(wr).CircuitType,'%d');
    % following line: division by sqrt(2) because FEMM works with peak values instead of rms values (preferred)
    wrs(wr).NtI=(sscanf(femmdata.CircuitProps(wr).TotalAmps_re,'%f')+sqrt(-1)*sscanf(femmdata.CircuitProps(wr).TotalAmps_im,'%f'));
    if sscanf(femmdata.ACSolver,'%d')~=0
      wrs(wr).NtI=wrs(wr).NtI/sqrt(2);
    end
    wrs(wr).k=find(idxelem2circ==wr);                                      % []     : indices of the elements of the wire
    %wrs(wr).i=unique(prb.elem(wire(wr).k,1:3));                           % []     : indices of the nodes at the wire cross-section
    %idxwire=[idxwire; wire(wr).i];                                        % []     : indices of nodes at wire cross-sections
    %numnid=length(wire(wr).i);
    %E=ones(numnid,1);
    %Qwirelist=[Qwirelist; wire(wr).i wr*E E];
    %Xprm(wr)=sscanf(wire(wr).label,'W%d');
  end
  %prb.idxwire=idxwire;
  %prb.idxins=setdiff(prb.idxdof,idxwire);
  %prb.Qwire=sparse(Qwirelist(:,1),Qwirelist(:,2),Qwirelist(:,3),prb.numnode,prb.numwire); % []     : wire connection matrix
  %prb.Xstr=sparse(1:prb.numwire,Xprm,ones(prb.numwire,1));                % []     : connection matrix
  %prb.Pstr=current_Pstr(prb,Xstr);                                        % []     : stranded-conductor coupling block
end
