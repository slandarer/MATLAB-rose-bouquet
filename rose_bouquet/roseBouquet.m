function roseBouquet(varargin)
% roseBouquet - Create a 3D rose bouquet visualization (创建 3D 玫瑰花束)
%   roseBouquet() creates a rose bouquet with default colormap in the current axes.
%   在当前坐标区使用默认配色创建玫瑰花束。
%
%   roseBouquet(ax) creates a rose bouquet in the specified axes with default colormap.
%   在指定坐标区使用默认配色创建玫瑰花束。
%
%   roseBouquet(CList) creates a rose bouquet in the current axes using the
%   specified colormap matrix CList.
%   在当前坐标区使用指定的配色矩阵 CList 创建玫瑰花束。
%
%   roseBouquet(ax, CList) creates a rose bouquet in the specified axes using
%   the given colormap matrix.
%   在指定坐标区使用给定的配色矩阵创建玫瑰花束。
%
% Input:
%   ax    - axes handle (optional) (坐标轴句柄，可选)
%   CList - N×3 RGB matrix with values in [0, 1], specifying the custom
%           colormap for the rose bouquet. If not provided, a default colormap
%           is used. (N×3 RGB 矩阵，数值在 [0,1] 之间，指定玫瑰花束的自定义配色。
%           若未提供，则使用默认配色。)


% Zhaoxu Liu / slandarer (2026). rose bouquet 
% (https://www.mathworks.com/matlabcentral/fileexchange/154496-rose-bouquet), 
% MATLAB Central File Exchange. Retrieved April 15, 2026.
ax = gca; CList = [.02 .04 .39; .02 .06 .69; .01 .26 .99; .17 .69 1];
if nargin >= 1 && isa(varargin{1}, 'matlab.graphics.axis.Axes')
    ax = varargin{1};
    if nargin >= 2
        CList = varargin{2};
    end
elseif nargin >= 1
    CList = varargin{1};
    if nargin >= 2
        ax = varargin{2};
    end
end
hold(ax, 'on'); view(-87.5, 42); axis equal off
% Basic surface for rose
[xr, tr] = meshgrid((0:24)./24, (0:0.5:575)./575.*20.*pi + 4*pi);
pr = (pi/2)*exp(- tr./(8*pi));
cr = sin(15*tr)/150;
ur = 1 - (1 - mod(3.6*tr,2*pi)./pi).^4./2 + cr;
yr = 2*(xr.^2 - xr).^2.*sin(pr);
rr = ur.*(xr.*sin(pr) + yr.*cos(pr));
hr = ur.*(xr.*cos(pr) - yr.*sin(pr)) + .35;
xr = rr.*cos(tr);
yr = rr.*sin(tr);
% Basic surface for lily
rl = 0:.01:1;
tl = linspace(0, 2, 151);
wl = rl'*((abs((1 - mod(tl*5, 2))))/2 + .3);
xl = wl.*cospi(tl)./2.5;
yl = wl.*sinpi(tl)./2.5; 
hl = ((- cospi(wl*1.2) + 1).^.2)./2.5 + .32;

% Rotation matrix
Rx = @(rx) [1, 0, 0; 0, cos(rx), -sin(rx); 0, sin(rx), cos(rx)];
Rz = @(yz) [cos(yz), - sin(yz), 0; sin(yz), cos(yz), 0; 0, 0, 1];
Rz1 = Rz(pi/5); Rz2 = Rz(2*pi/5); Rz3 = Rz(2*pi/15);
Rx1 = Rx(pi/8); Rx2 = Rx(pi/9);

propr = {'EdgeAlpha',0.05, 'EdgeColor',[0 0 0], 'FaceColor','interp', 'CData',H2C(hr,CList)};
propl = {'EdgeColor','none', 'FaceColor','interp', 'CData',H2C(hl,CList.*.4 + .6)};

% Draw rose
surface(xr, yr, hr, propr{:})
[U, V, W] = matRotate(xr, yr, hr, Rx1);
V = V - .4; W = W - .1;
for k = 1:5
    [U, V, W] = matRotate(U, V, W, Rz2);
    surface(ax, U, V, W, propr{:})
    drawStraw(ax, U, V, W)
end

% Draw lily
[U, V, W] = matRotate(xl, yl, hl, Rx2);
Us{1} = U; Vs{1} = V - 1.35; Ws{1} = W;
[U, V, W] = matRotate(U, V - 1.15, W, Rz1);
Us{2} = U; Vs{2} = V; Ws{2} = W;
[U, V, W] = matRotate(xl, yl, hl, Rx2);
[U, V, W] = matRotate(U, V - 1.25, W, Rz3);
Us{3} = U; Vs{3} = V; Ws{3} = W;
[U, V, W] = matRotate(U, V, W, Rz3);
Us{4} = U; Vs{4} = V; Ws{4} = W;
for s = 1:4
    for k = 1:5
        [Us{s}, Vs{s}, Ws{s}] = matRotate(Us{s}, Vs{s}, Ws{s}, Rz2);
        surface(ax, Us{s}, Vs{s}, Ws{s}, propl{:})
        drawStraw(ax, Us{s}, Vs{s}, Ws{s})
    end
end

% Basic functions
    function C = H2C(H, CL)
        X = rescale(H, 0, 1);
        C = interp1(rescale(1:size(CL, 1), 0, 1), CL, X);
    end
    function [U, V, W] = matRotate(X, Y, Z, R)
        U = X; V = Y; W = Z;
        for i = 1:numel(X)
            v = [X(i); Y(i); Z(i)];
            n = R*v; U(i) = n(1); V(i) = n(2); W(i) = n(3);
        end
    end
    function pnts = bezierCurve(pnts, N)
        t = linspace(0, 1, N);
        p = size(pnts, 1) - 1;
        coe1 = factorial(p)./factorial(0:p)./factorial(p:-1:0);
        coe2 = ((t).^((0:p)')).*((1 - t).^((p:-1:0)'));
        pnts = (pnts'*(coe1'.*coe2))';
    end
    function drawStraw(ax, X, Y, Z)
        [m, n] = find(Z == min(min(Z)));
        m = m(1); n = n(1);
        x1 = X(m, n); y1 = Y(m, n); z1 = Z(m, n) + .03;
        xx = [x1, 0, (x1.*cos(pi/3) - y1.*sin(pi/3))./3].';
        yy = [y1, 0, (y1.*cos(pi/3) + x1.*sin(pi/3))./3].';
        zz = [z1, -.7, -1.5].';
        strawPnts = bezierCurve([xx, yy, zz], 50);
        plot3(ax, strawPnts(:,1), strawPnts(:,2), strawPnts(:,3),...
            'Color',[88,130,126]./255, 'LineWidth',2)
    end
end