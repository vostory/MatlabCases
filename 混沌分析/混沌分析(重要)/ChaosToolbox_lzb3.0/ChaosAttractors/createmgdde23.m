function MGS = createmgdde23(LEN, TAU, INITDUMMY)
% create Mackey-GLass time series
% LEN   - sequence length
% TAU   - time lag
% INITDUMMY - initial steps to supress

% set default values
if nargin < 1, LEN = 10000; end;
if nargin < 2, TAU = 17; end;
if nargin < 3, INITDUMMY = 1000; end;

MG = dde23(@dde_mg, TAU, 0, [1 INITDUMMY+LEN], ddeset('AbsTol',1e-16,'MaxStep',1,'InitialY',1));
MGS = MG.y(end-LEN+1:end);

function f = dde_mg(t,y,z)
% ALPHA = 0.2;
% BETA = 10; 
% GAMA = 0.1;

f = 0.2*z/(1+z^10) - 0.1*y;

