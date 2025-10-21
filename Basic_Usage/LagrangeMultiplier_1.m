%% ラグランジュの未定乗数法による制約付き最適化
% 目的: f(x,y) = (x+y)^2 を制約条件 g(x,y) = x^2 + y^2 - 1 = 0 の下で最適化

clear; clc;

%% 1. シンボリック変数の定義
syms x y lambda

%% 2. 目的関数と制約条件の定義
% 目的関数: f(x,y) = (x+y)^2
f(x, y) = (x + y)^2;

% 制約条件: g(x,y) = x^2 + y^2 - 1 = 0 (単位円上)
g(x, y) = x^2 + y^2 - 1;

%% 3. ラグランジュ関数の構築
% L(x, y, λ) = f(x,y) - λ·g(x,y)
L(x, y, lambda) = f - lambda * g;

fprintf('ラグランジュ関数:\n');
disp(L);

%% 4. 最適化条件（KKT条件）の設定
% ∂L/∂x = 0, ∂L/∂y = 0, ∂L/∂λ = 0
eqn1 = diff(L, x) == 0;      % x に関する偏微分 = 0
eqn2 = diff(L, y) == 0;      % y に関する偏微分 = 0
eqn3 = diff(L, lambda) == 0; % λ に関する偏微分 = 0 (制約条件)

fprintf('\n最適化条件:\n');
fprintf('∂L/∂x = 0: '); disp(eqn1);
fprintf('∂L/∂y = 0: '); disp(eqn2);
fprintf('∂L/∂λ = 0: '); disp(eqn3);

%% 5. 連立方程式を解く
ss = solve([eqn1, eqn2, eqn3], [x, y, lambda]);

% 解の抽出
Ans_x = ss.x;
Ans_y = ss.y;
Ans_lambda = ss.lambda;
Ans_f = f(ss.x, ss.y); % 各解での目的関数値

%% 6. 結果の表示
fprintf('\n=== 解の一覧 ===\n');
disp('x座標:'); disp(Ans_x);
disp('y座標:'); disp(Ans_y);
disp('ラグランジュ乗数 λ:'); disp(Ans_lambda);
disp('目的関数値 f(x,y):'); disp(Ans_f);

%% 7. 結果を表形式で整理
T = table(double(Ans_x), double(Ans_y), double(Ans_lambda), double(Ans_f), ...
    'VariableNames', {'x', 'y', 'lambda', 'f_value'});

fprintf('\n=== 数値解の表 ===\n');
disp(T);

%% 8. 最大値・最小値の判定
[f_max, idx_max] = max(double(Ans_f));
[f_min, idx_min] = min(double(Ans_f));

fprintf('\n=== 最適解 ===\n');
fprintf('最大値: f = %.6f at (x, y) = (%.6f, %.6f)\n', ...
    f_max, double(Ans_x(idx_max)), double(Ans_y(idx_max)));
fprintf('最小値: f = %.6f at (x, y) = (%.6f, %.6f)\n', ...
    f_min, double(Ans_x(idx_min)), double(Ans_y(idx_min)));

%% 9. 視覚化（オプション）
figure('Name', 'ラグランジュの未定乗数法');

% 等高線プロット
theta = linspace(0, 2*pi, 100);
x_circle = cos(theta);
y_circle = sin(theta);

[X, Y] = meshgrid(-1.5:0.05:1.5, -1.5:0.05:1.5);
F = (X + Y).^2;

contourf(X, Y, F, 20, 'LineWidth', 0.5);
colorbar;
hold on;

% 制約条件（単位円）
plot(x_circle, y_circle, 'r-', 'LineWidth', 2, 'DisplayName', '制約条件: x^2+y^2=1');

% 最適解をプロット
plot(double(Ans_x), double(Ans_y), 'ko', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'yellow', 'LineWidth', 2, 'DisplayName', '最適解');

% 最大値と最小値を強調
plot(double(Ans_x(idx_max)), double(Ans_y(idx_max)), 'r^', ...
    'MarkerSize', 15, 'MarkerFaceColor', 'red', 'LineWidth', 2, 'DisplayName', '最大値');
plot(double(Ans_x(idx_min)), double(Ans_y(idx_min)), 'bv', ...
    'MarkerSize', 15, 'MarkerFaceColor', 'blue', 'LineWidth', 2, 'DisplayName', '最小値');

xlabel('x');
ylabel('y');
title('目的関数 f(x,y) = (x+y)^2 の等高線と制約条件');
legend('Location', 'best');
grid on;
axis equal;
hold off;