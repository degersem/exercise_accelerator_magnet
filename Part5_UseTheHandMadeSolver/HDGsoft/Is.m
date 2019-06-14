function intudth = Is(u,T,filter)

% function intudth = Is(u,T,filter)
% integrates a periodic signal with spectral accuracy
%
% input parameters
%    u        : signal (multiple columns possible)
%    T        : period (optional; default: 2*pi)
%    filter   : filter (optional; default: 'none')
%             :     'none'     : no filter applied
%             :     M          : all harmonics with order >= M are discarded
%
% output parameters
%    intudth  : integrated signal
%
% see also Ds
% remark 1 : construct a differentiation operator as :   DD = Ds(eye(N));
% remark 2 : Ds(eye(N))*Is(eye(N)) is not the unit matrix (because of the constant component filtered out)

%% A. Test
if 0
  % Test 1
  N = 100;
  th = 2*pi/N*[ 0:N-1 ]';
  u = [ cos(th) sin(2*th) ];
  intudth = Is(u,[],'none');
  figure(1); clf; plot(th,[ u intudth ]); axis([ 0 2*pi -2.1 2.1 ]);
  xlabel('theta (rad)'); legend('cos(th)','sin(2*th)','sin(th)','-1/2*cos(2*th)');
  u2 = Ds(intudth); hold on; plot(th,u2,'x');
  % Test 2
  N=101;
  Tx = 20;
  x = Tx/N*[ 0:N-1 ]';
  u = [ cos(2*pi/Tx*x) 0.5*sin(2*pi/Tx*3*x) ];
  intudx = Is(u,Tx,'none');
  figure(2); clf; plot(x,[ u intudx ]); axis([ 0 Tx -3.5 3.5 ]);
  xlabel('x (m)'); legend('cos(2*pi/Tx*x)','0.5*sin(2*pi/Tx*3*x)','Tx/(2*pi)*sin(2*pi/Tx*x)','-Tx/(2*pi)*0.5/3*cos(2*pi/Tx*3*x)');
  u2 = Ds(intudx,Tx); hold on; plot(x,u2,'x');
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
intudth = ifft(-1i*spdiags(savedivide(ones(size(Lambda)),Lambda,0),0,N,N)*ucff,[],1)*T/(2*pi);
if isreal(u)
  intudth = real(intudth);
end
