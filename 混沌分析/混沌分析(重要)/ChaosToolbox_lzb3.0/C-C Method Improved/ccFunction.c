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

// 定义输出参数
#define S plhs[0]

// 声明 C 运算函数 (该函数名不能和本文件名重名)
double CC_FUNCTION();
double GUANLIAN_JIFEN();

//---------------------------------------------------------------------------
void 
mexFunction (int nlhs, mxArray *plhs[],			// 输出参数个数，及输出参数数组
			 int nrhs, const mxArray *prhs[])	// 输入参数个数，及输入参数数组
{
    double *px,r,*ps;
    int m,t,N;
    
    // 取得输入参数
    m = (int) mxGetScalar(M);   // 嵌入维数       
    px = mxGetPr(X);            // 时间序列（列向量）
    N = mxGetM(X);              // 序列长度
    r = mxGetScalar(R);         // 给定正数r                
	t = (int) mxGetScalar(T);   // 时间延迟      
	
    // 为输出变量分配内存空间
	S = mxCreateDoubleMatrix(1,1,mxREAL); 
	
	// 取得输出参数指针
	ps = mxGetPr(S);

    // 调用 C 运算函数 (该函数名不能和本文件名重名)
    *ps = CC_FUNCTION(m,px,N,r,t);    
	return;
}

//---------------------------------------------------------------------------
// 定义 C 运算函数
double CC_FUNCTION( int m,          // 嵌入维数       
                    double *px,     // 时间序列（列向量）
                    int N,          // 序列长度
                    double r,       // 给定正数r
                    int t )         // 时间延迟
{
    int Xt_cols,i,j;
    double *pxi,c1,c2,tmp,s_mean;

    Xt_cols = N/t;
    pxi = mxMalloc(Xt_cols*sizeof(double));       // 声明一个长度为 xn_cols 的 double 型数组
        
    tmp = 0;
    for (i=0; i<t; i++)
    {   for (j=0; j<Xt_cols; j++)
        {
            pxi[j] = px[j*t+i];                 // pxi 为 px 的第 i 行，0<=i<=t
        }
        c1 = GUANLIAN_JIFEN(pxi,Xt_cols,1,m,r);
        c2 = GUANLIAN_JIFEN(pxi,Xt_cols,1,1,r);
        tmp = tmp + (c1-pow(c2,m));
    }
    mxFree(pxi);
    
    s_mean = (double) tmp/t;
    return s_mean; 
}

//-------------------------------------------------------------------------------
//      计算关联积分。特别注意：这里输入参数为,时间序列(列向量)，距离采用无穷范数
//-------------------------------------------------------------------------------
double GUANLIAN_JIFEN( double *px, // 时间序列（列向量）
                       int N,      // 序列长度
                       int t,      // 时间延迟                       
                       int m,      // 嵌入维数       
                       double r)   // 给定正数r
{
    double c,tmp1,d;
    int i,j1,j2,xn_cols;

    xn_cols = N-(m-1)*t;                                // 重构矩阵 xn 列数
    
    tmp1 = 0;
    for (j1=0; j1<xn_cols; j1++)
    {   for (j2=j1+1; j2<xn_cols; j2++)
        {   for (i=0;i<m;i++)
            {
                d = fabs(px[i*t+j1] - px[i*t+j2]);    // 第i行,第j1列与j2列对应元素相减
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
        c = (double) 2/((xn_cols)*(xn_cols-1))*tmp1;
        c = 1 - c;
    }
    return c;
}

