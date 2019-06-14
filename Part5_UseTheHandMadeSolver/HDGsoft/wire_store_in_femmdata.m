function CircuitProps = wire_store_in_femmdata(wrs,frm)
% function CircuitProps = wire_store_in_femmdata(wrs,frm)
%   stores the wire data structure into FEMM data
%
% Inputs
%    wrs                 : wire data structure
%    frm                 : formulation
%        frequency       : [Hz]  : frequency
%
% Outputs
%    CircuitProps        : FEMM data
%
% Author
%   Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

CircuitProps=repmat(struct('CircuitName','"C1"',...
  'TotalAmps_re','1','TotalAmps_im','0','CircuitType','1'),1,length(wrs));
for wr=1:length(wrs)
  CircuitProps(wr).CircuitName=['"' wrs(wr).label '"'];
  CircuitProps(wr).CircuitType=sprintf('%d',wrs(wr).type);
  if frm.frequency==0
    CircuitProps(wr).TotalAmps_re=sprintf('%f',real(wrs(wr).NtI));
    CircuitProps(wr).TotalAmps_im=sprintf('%f',imag(wrs(wr).NtI));
  else
    % following line: multiplication by sqrt(2) because FEMM works with peak values instead of rms values (preferred)
    CircuitProps(wr).TotalAmps_re=sprintf('%f',real(wrs(wr).NtI)*sqrt(2));
    CircuitProps(wr).TotalAmps_im=sprintf('%f',imag(wrs(wr).NtI)*sqrt(2));
  end
end

end
