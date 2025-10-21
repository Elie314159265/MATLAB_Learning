% 1. 大規模な疎行列 A を作成
n = 1000;

% numgridで内部グリッドポイントを取得
G = numgrid('S', n+2);  % n+2にすることで内部ノードがn x nになる
% または、delsqの出力サイズに合わせる
A_base = delsq(numgrid('S', n+1));
actual_size = size(A_base, 1);  % 実際のサイズを取得

% 非対称性を確保するため、対角成分にランダム値を追加
A = A_base + spdiags(rand(actual_size, 1)*0.1, 0, actual_size, actual_size);

% 2. 真の解 x_true を作成し、右辺ベクトル b を計算
x_true = ones(size(A, 1), 1);
b = A * x_true;

% 3. BiCGSTABで連立方程式を解く
% tol: 許容誤差 1e-6, maxit: 最大反復回数 500
tol = 1e-6;
maxit = 500;
tic;
[x, flag, relres, iter] = bicgstab(A, b, tol, maxit);
time_bicgstab = toc;

% 4. 結果の表示
fprintf('--- BiCGSTABの結果 ---\n');
fprintf('行列サイズ: %d x %d\n', size(A, 1), size(A, 2));
fprintf('収束フラグ (0=成功): %d\n', flag);
fprintf('相対残差: %e\n', relres);
fprintf('反復回数: %d\n', iter);
fprintf('計算時間: %.4f 秒\n', time_bicgstab);

% 5. 解の精度を確認
error_norm = norm(x - x_true) / norm(x_true);
fprintf('相対誤差ノルム: %e\n', error_norm);
