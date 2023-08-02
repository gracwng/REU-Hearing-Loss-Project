%> @file matsqueeze3d2d.m
%> @brief Squeezes a <time>-by-<features>-by-<trials> matrix into a <time * trials>-by-<features> matrix
%> @param xx input matrix of size (time x features x trials)
%> @retval yy output matrix



function yy = matsqueeze3d2d(xx)

yy = reshape(permute(xx,[1 3 2]),size(xx,1)*size(xx,3),size(xx,2));

end