#include <math.h>
#include "mex.h"
#include "stdio.h"
#include "stdlib.h"
#include "matrix.h"

//---------------------------------------------------------------------------
// 定义输入参数
#define M prhs[0]           // 嵌入维数
#define X prhs[1]           // 时间序列（列向量）
#define R prhs[2]           // 给定正数r
#define T prhs[3]           // 时间延迟
#define BLCOK prhs[4]       // 分块数

// 定义输出参数
#define S plhs[0]

// 声明 C 运算函数 (该函数名不能和本文件名重名)
double GUANLIAN_JIFEN_BLOCK_RUN();
double GUANLIAN_JIFEN_BLOCK();
double GUANLIAN_JIFEN();

//---------------------------------------------------------------------------
void 
mexFunction (int nlhs, mxArray *plhs[],			// 输出参数个数，及输出参数数组
			 int nrhs, const mxArray *prhs[])	// 输入参数个数，及输入参数数组
{
    double *px,r,*ps;
    int m,t,N,block;

    // 取得输入参数
    m = (int) mxGetScalar(M);           // 嵌入维数       
    px = mxGetPr(X);                    // 时间序列（列向量）
    N = mxGetM(X);                      // 序列长度
    r = mxGetScalar(R);                 // 给定正数r                
	t = (int) mxGetScalar(T);           // 时间延迟      
	block = (int) mxGetScalar(BLCOK);   // 分块数
	
    // 为输出变量分配内存空间
	S = mxCreateDoubleMatrix(1,1,mxREAL); 
	
	// 取得输出参数指针
	ps = mxGetPr(S);

    // 调用 C 运算函数 (该函数名不能和本文件名重名)
    *ps = GUANLIAN_JIFEN_BLOCK_RUN(px,N,t,m,r,block);    
	return;
}

//-------------------------------------------------------------------------------
double GUANLIAN_JIFEN_BLOCK_RUN(double *px,     // 重构矩阵,每一列为一个点
                                int N,          // 序列长度
                                int t,          // 时间延迟 
                                int m,          // 嵌入维数 
                                double r,       // 给定正数r
                                int block)      // 分块数
{
    double *pxn,c,c1,c2;
    int xn_cols,i,j,p=1;

    xn_cols = N-(m-1)*t;                        // 重构矩阵 xn 列数
    pxn = mxMalloc(m*xn_cols*sizeof(double));
     for (i=0; i<m; i++)
         for (j=0; j<xn_cols; j++)
             pxn[j*m+i] = px[i*t+j];
             
    c1 = GUANLIAN_JIFEN_BLOCK(pxn,m,xn_cols,r,p,block);
    c2 = GUANLIAN_JIFEN_BLOCK(px,1,N,r,p,block);
    c = c1 - pow(c2,m);   
    
    mxFree(pxn);    
    return c;
}

//-------------------------------------------------------------------------------
double GUANLIAN_JIFEN_BLOCK(double *pxn,     // 重构矩阵,每一列为一个点
                            int m,           // 嵌入维数,重构矩阵 xn 行数       
                            int xn_cols,     // 重构点数,重构矩阵 xn 列数
                            double r,        // 给定正数r
                            int p,           // 限制短暂分离,默认为1
                            int block)       // 分块数
{
    double c,*pxn_block,tmp;
    int i,j,k,xn_cols_block;    

    if (block == 1)
    {
        c = GUANLIAN_JIFEN(pxn,m,xn_cols,r,p);    
    }
    else
    {
        xn_cols_block = xn_cols/block;
        pxn_block = mxMalloc(m*xn_cols_block*sizeof(double));
        tmp = 0;
        for (k=0; k<block; k++)
        {
            for (i=0; i<m; i++)
                for (j=0; j<xn_cols_block; j++)
                    pxn_block[j*m+i] = pxn[(j*block+k)*m+i];
            tmp = tmp + GUANLIAN_JIFEN(pxn_block,m,xn_cols_block,r,p);                        
        }
        c = (double) tmp/block;
        mxFree(pxn_block);
    }
    return c;
}

//-------------------------------------------------------------------------------
//      计算关联积分。特别注意：这里输入参数为,时间序列(列向量)，距离采用无穷范数
//-------------------------------------------------------------------------------
double GUANLIAN_JIFEN( double *pxn,     // 重构矩阵,每一列为一个点
                       int m,           // 嵌入维数,重构矩阵 xn 行数       
                       int xn_cols,     // 重构点数,重构矩阵 xn 列数
                       double r,        // 给定正数r
                       int p)
{
    double c,d_ij,tmp1,d;
    int i,j1,j2;
    
    tmp1 = 0;
    for (j1=0; j1<xn_cols; j1++)
    {   for (j2=j1+p; j2<xn_cols; j2++)
        {   for (i=0;i<m;i++)
            {
                d = fabs(pxn[j1*m+i] - pxn[j2*m+i]);    // 第i行,第j1列与j2列对应元素相减
                if (d>r)
                {
                    tmp1 = tmp1 + 1;
                    break;
                }
            }
        }
    }
    
    if (xn_cols<=1)
        c = 0;
    else
    {
        c = (double) 2/((xn_cols-p)*(xn_cols-p+1))*tmp1;
        c = 1 - c;
    }
    
    return c;
}