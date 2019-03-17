#include <math.h>
#include "mex.h"
#include "stdio.h"
#include "stdlib.h"
#include "matrix.h"

//---------------------------------------------------------------------------
// 定义输入参数
#define X prhs[0]           // 时间序列（向量）
#define T prhs[1]           // 时间延迟
#define M prhs[2]           // 嵌入维数 (可能为向量)
#define R prhs[3]           // 给定正数 (可能为向量)
#define P prhs[4]           // 限制短暂分离,默认为1

// 定义输出参数
#define Cr plhs[0]

// 声明 C 运算函数 (该函数名不能和本文件名重名)
double GUANLIAN_JIFEN();

//---------------------------------------------------------------------------
void 
mexFunction (int nlhs, mxArray *plhs[],			// 输出参数个数，及输出参数数组
			 int nrhs, const mxArray *prhs[])	// 输入参数个数，及输入参数数组
{
    double *pX,*pR,*pCr,r,*pM,x_min,x_max,x_mean,x_width,tmp1;
    int n,len_m,len_r,tau,p,m,m_max,i,j;
        
   
    
    //---------------------------------------------------------------
    // 取得输入参数
    pX = mxGetPr(X);                    // 时间序列（列向量）
    n = max(mxGetM(X),mxGetN(X));       // 序列长度
        
    tau = (int) mxGetScalar(T);           // 时间延迟      
    
    pM = mxGetPr(M);
    len_m = max(mxGetM(M),mxGetN(M));
    
    pR = mxGetPr(R);
    len_r = max(mxGetM(R),mxGetN(R));

    p = (int) mxGetScalar(P);           // 限制短暂分离,默认为1   
    
    // 为输出变量分配内存空间
	Cr = mxCreateDoubleMatrix(len_m,len_r,mxREAL); 
	
	// 取得输出参数指针
	pCr = mxGetPr(Cr);
	
    // 调用 C 运算函数 (该函数名不能和本文件名重名)
    x_min = x_max = 0;
    tmp1 = 0;
    for (i=0;i<n;i++)
    {
        if (pX[i]>x_max)
            x_max = pX[i];
        if (pX[i]<x_min)
            x_min = pX[i];
        tmp1 = tmp1+pX[i];            
    }
    x_mean = tmp1/n;
    x_width = x_max-x_min;
    for (i=0;i<n;i++)
        pX[i] = (pX[i]-x_mean)/x_width;    
    
    for (i=0;i<len_m;i++)
        for (j=0;j<len_r;j++)
        {
            m = (int) pM[i];
            r = pR[j];
            pCr[j*len_m+i] = GUANLIAN_JIFEN(pX,n,tau,m,r,p);
        }
     return;
}

//-------------------------------------------------------------------------------

double GUANLIAN_JIFEN(double *pX,       // 时间序列（列向量）
                          int lX,       // 序列长度
                          int t,        // 时间延迟 
                          int m,        // 嵌入维数 
                          double r,     // 给定正数r 
                          int p)        // 限制短暂分离,默认为1
{
    double c,tmp1,tmp2;
    int i,j1,j2,cXn;

    cXn = lX-(m-1)*t;                                // 重构矩阵 xn 列数
    
    tmp1 = 0;
    for (j1=0; j1<cXn; j1++)
    {   for (j2=j1+p; j2<cXn; j2++)
        {   for (i=0;i<m;i++)
            {
                tmp2 = fabs(pX[i*t+j1] - pX[i*t+j2]);    // 第i行,第j1列与j2列对应元素相减
                if (tmp2>r)
                {
                    tmp1 = tmp1 + 1;
                    break;
                }                
            }
        }
    }
    
    if (cXn<=1)
        c = 0;
    else
    {
        c = (double) 2/((cXn-p)*(cXn-p+1))*tmp1;
        c = 1 - c;
    }
    return c;
}

