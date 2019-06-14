function dudth = Ds(u,T,filter)

% function dudth = Ds(u,T,filter)
% differentiates a periodic signal with spectral accuracy
%
% input parameters
%    u        : signal (multiple columns possible)
%    T        : period (optional; default: 2*pi)
%    filter   : filter (optional; default: 'none')
%             :     'none'     : no filter applied
%             :     M          : all harmonics with order >= M are discarded
%
% output parameters
%    dudth    : differentiated signal
%
% see also Is
% remark 1 : construct a differentiation operator as :   DD = Ds(eye(N));
% remark 2 : Ds(eye(N))*Is(eye(N)) is not the unit matrix (because of the constant component filtered out)

%% A. Test
if 0
  % Test 1
  N = 100;
  th = 2*pi/N*[ 0:N-1 ]';
  u = [ cos(th) sin(2*th) ];
  dudth = Ds(u,[],'none');
  figure(1); clf; plot(th,[ u dudth ]); axis([ 0 2*pi -2.1 2.1 ]);
  xlabel('theta (rad)'); legend('cos(th)','sin(2*th)','-sin(th)','2*cos(2*th)');
  % Test 2
  N=101;
  Tx = 20;
  x = Tx/N*[ 0:N-1 ]';
  u = [ cos(2*pi/Tx*x) 0.5*sin(2*pi/Tx*3*x) ];
  dudx = Ds(u,Tx,'none');
  figure(2); clf; plot(x,[ u dudx ]); axis([ 0 Tx -2.1 2.1 ]);
  xlabel('x (m)'); legend('cos(2*pi/Tx*x)','0.5*sin(2*pi/Tx*3*x)','-2*pi/Tx*sin(2*pi/Tx*x)','2*pi/Tx*1.5*cos(2*pi/Tx*3*x)');
end

%% B. Parameter check
if ~exist('T','var'),      T = 2*pi;        end
if isempty(T),             T = 2*pi;        end
if ~exist('filter','var'), filter = 'none'; end

%% C. Differentiation
N = size(u,1);
Lambda = [ 0:floor(N/2) -ceil(N/2)+1:-1 ]';
ucff = fft(u,[],1);
ucff(find(Lambda==N/2),:) = 0;
if ~strcmp(filter,'none')
  ucff(find(abs(Lambda)>=filter),:) = 0;
end
dudth = ifft(1i*spdiags(Lambda,0,N,N)*ucff,[],1)*2*pi/T;
if isreal(u)
  dudth = real(dudth);
end
