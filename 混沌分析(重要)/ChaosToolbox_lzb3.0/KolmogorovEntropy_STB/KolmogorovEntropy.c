#include <math.h>
#include "mex.h"
#include "stdio.h"
#include "stdlib.h"
#include "matrix.h"

//---------------------------------------------------------------------------
// 定义输入参数
#define X    prhs[0]           // 时间序列（向量）
#define FS   prhs[1]           // 采样频率
#define T    prhs[2]           // 时延
#define M    prhs[3]           // 嵌入维数（向量）
#define BMAX prhs[4]           // 最大离散步进值
#define P    prhs[5]           // 限制短暂分离,默认为1

// 定义输出参数
#define KE plhs[0]

// 声明 C 运算函数 (该函数名不能和本文件名重名)
double Kolmogorov();

//---------------------------------------------------------------------------
void 
mexFunction (int nlhs, mxArray *plhs[],			// 输出参数个数，及输出参数数组
			 int nrhs, const mxArray *prhs[])	// 输入参数个数，及输入参数数组
{
    double *pX1,*pX2,*pKE,*pM;                  // 数组一定要声明成double类型
    int i,j,lx1,lx2,lm,m,p,fs,bmax,t;
    
    //----------------------------------------------
          
    
    if (nrhs<6)
        p = 1;
    else
        p = (int) mxGetScalar(P);           // 限制短暂分离,默认为1   
        
    //---------------------------------------------------------------
    // 取得输入参数
    pX1 = mxGetPr(X);                   // 时间序列（列向量）
    lx1 = max(mxGetM(X),mxGetN(X));     // 序列长度              

    fs = (int) mxGetScalar(FS);         // 采样频率     
    t = (int) mxGetScalar(T);           // 时延
    
    pM = mxGetPr(M);
    lm = max(mxGetM(M),mxGetN(M));    
    
    bmax = (int) mxGetScalar(BMAX);     // 最大离散步进值   
    
    // 为输出变量分配内存空间
	KE = mxCreateDoubleMatrix(1,lm,mxREAL); 
   
	// 取得输出参数指针
	pKE = mxGetPr(KE);
	
    // 调用 C 运算函数 (该函数名不能和本文件名重名)
    lx2 = lx1/t;
    pX2 = (double*) mxCalloc(lx2,sizeof(double));
    for (i=0;i<lx2;i++)
    {
        pX2[i] = pX1[i*t];                // 按时延重采样
    }
    
    for (i=0;i<lm;i++)
    {
        m = (int) pM[i];
        pKE[i] = Kolmogorov(pX2,lx2,fs,t,m,bmax,p);
    }    
    mxFree(pX2);
    return;
}

//-------------------------------------------------------------------------------

double Kolmogorov(double *pX,   // 时间序列（列向量）
                  int n,        // 序列长度
                  int fs,       // 采样频率
                  int t,        // 时延
                  int m,        // 嵌入维数 
                  int bmax,     // 最大离散步进值   
                  int p)        // 限制短暂分离,默认为1
{
    int i,j,M,*pB,u,v,b;
    double tmp1,tmp2,r0,k_e,B_mean,d;

    tmp1 = 0;
    for (i=0;i<n;i++)
        tmp1 = tmp1+pX[i];
    tmp1 = tmp1/n;            // 序列均值
    
    tmp2 = 0;
    for (i=0;i<n;i++)
        tmp2 = tmp2+fabs(pX[i]-tmp1);
    r0 = tmp2/n;                // 门限值
    
    M = n-(m-1);                // 重构点数   
    
    //mexPrintf("M = %d\n",M);	  
    
    pB = (int*) mxCalloc(M,sizeof(int));
    
    for (i=0;i<M-bmax;i++)
    {   for (j=i+p;j<M-bmax;j++)
        {
            v = 0;
            for (u=0;u<m;u++)
            {   
                if (fabs(pX[i+u]-pX[j+u])>r0)
                {
                    v = 1;
                    break;
                }
            }
        
            if (v==1)
                continue;  
            
            b = 0;
            d = 0;
            while (d<=r0)
            {    
                b = b+1;
    
                if (i+m-1+b>n-1 || j+m-1+b>n-1)
                    mexErrMsgTxt("\n错误: bmax 取值太小!\n");

                d = fabs(pX[i+m-1+b]-pX[j+m-1+b]);
            }
            
            if (b>0)  
                pB[b-1] = pB[b-1]+1;
        }
    }
    
    tmp1 = 0;
    tmp2 = 0;
    for (i=0;i<M;i++)
    {
        tmp1 = tmp1 + pB[i]*(i+1);
        tmp2 = tmp2 + pB[i];
    }
    B_mean = tmp1/tmp2;
    
    k_e = -log(1-1/B_mean)*fs/t;    
    
    mxFree(pB);
    
    // mexPrintf("k = %d\n",k);	      

    return k_e;
}


