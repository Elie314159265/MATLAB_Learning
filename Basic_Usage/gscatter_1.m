ds = readmatrix('Jap-Math.xlsx');
gscatter(ds(:,3),ds(:,5),ds(:,4),'br','.',20,'off','Number','Score'); hold on
gscatter(ds(:,3),ds(:,7),ds(:,4),'br','x',10,'off'); hold off
legend('Japanese 1','Japanese 2', 'Mathematics 1', 'Mathematics 2','Location','southeast')
