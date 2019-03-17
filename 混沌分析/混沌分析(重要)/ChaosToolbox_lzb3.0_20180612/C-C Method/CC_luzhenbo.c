#include <math.h>
#include "mex.h"
#include "stdio.h"
#include "stdlib.h"
#include "matrix.h"

//---------------------------------------------------------------------------
// 定义输入参数
#define X prhs[0]           // 时间序列（列向量）
#define MAXLAGS prhs[1]     // 最大时延

// 定义输出参数
#define S_MEAN plhs[0]
#define DELTA_S_MEAN plhs[1]
#define S_COR plhs[2]

// 声明 C 运算函数 (该函数名不能和本文件名重名)
void CC_LUZHENBO_FUN();
double CC_FUNCTION();
double GUANLIAN_JIFEN();
double MAX_VECTOR();
double MIN_VECTOR();
double STD();
void copyright();

//---------------------------------------------------------------------------
void 
mexFunction (int nlhs, mxArray *plhs[],			// 输出参数个数，及输出参数数组
			 int nrhs, const mxArray *prhs[])	// 输入参数个数，及输入参数数组
{
    double *px,*ps_mean,*pdelta_s_mean,*ps_cor;
    int maxlags,N;
    
   
    //-----------------------------------------------

    // 取得输入参数
    px = mxGetPr(X);                        // 时间序列（列向量）
    N = mxGetM(X);                          // 序列长度
	maxlags = (int) mxGetScalar(MAXLAGS);   // 时间延迟      
	
    // 为输出变量分配内存空间
    S_MEAN = mxCreateDoubleMatrix(maxlags,1,mxREAL); 
    DELTA_S_MEAN = mxCreateDoubleMatrix(maxlags,1,mxREAL); 
    S_COR = mxCreateDoubleMatrix(maxlags,1,mxREAL); 
	
	// 取得输出参数指针
	ps_mean = mxGetPr(S_MEAN);
    pdelta_s_mean = mxGetPr(DELTA_S_MEAN);
	ps_cor = mxGetPr(S_COR);    

    // 调用 C 运算函数 (该函数名不能和本文件名重名)
    CC_LUZHENBO_FUN(ps_mean,pdelta_s_mean,ps_cor,px,N,maxlags);
	return;
}

//---------------------------------------------------------------------------
// 定义 C 运算函数
void CC_LUZHENBO_FUN(double *ps_mean,
                     double *pdelta_s_mean,
                     double *ps_cor,
                     double *px,          // 时间序列（列向量）
                     int N,               // 序列长度
                     int maxlags)         // 时间延迟 
{
    double sigma,*pr_vector,*psj,tmp1,tmp2,r,S,delta_S;
    int i,t,j,m,*pm_vector;
    
    sigma = STD(px,N);
    pm_vector = (int*) mxMalloc(4*sizeof(int));
    pr_vector = (double*) mxMalloc(4*sizeof(double));
    psj = (double*) mxMalloc(4*sizeof(double));  
    
    for (i=0;i<4;i++)
    {
        pm_vector[i] = i+2;
        pr_vector[i] = sigma/2*(i+1);
    }
    
    for (t=1;t<=maxlags;t++)
    {
        tmp1 = 0;
        tmp2 = 0;
        for (i=0;i<4;i++)
        {   for (j=0;j<4;j++)
            {
                m = pm_vector[i];
                r = pr_vector[j];
                S = CC_FUNCTION(m,px,N,r,t);
                tmp1 = tmp1 + S;
                psj[j] = S;                
            }
            delta_S = MAX_VECTOR(psj,4) - MIN_VECTOR(psj,4);
            tmp2 = tmp2 + delta_S;
        }
        ps_mean[t-1] = tmp1/16;
        pdelta_s_mean[t-1] = tmp2/4;
        ps_cor[t-1] = tmp2/4 + fabs(tmp1/16);
    }

    mxFree(pm_vector);
    mxFree(pr_vector);    
    mxFree(psj);      
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
    double c,tmp1,tmp2;
    int i,j1,j2,xn_cols;

    xn_cols = N-(m-1)*t;                                // 重构矩阵 xn 列数
    
    tmp1 = 0;
    for (j1=0; j1<xn_cols; j1++)
    {   for (j2=j1+1; j2<xn_cols; j2++)
        {   for (i=0;i<m;i++)
            {
                tmp2 = fabs(px[i*t+j1] - px[i*t+j2]);    // 第i行,第j1列与j2列对应元素相减
                if (tmp2>r)
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

//---------------------------------------------------------------------------
// 计算数组最大值
double MAX_VECTOR(double *p_vector,
                  int len_vector)
{
    int i;    
    double max_value = p_vector[0];
    
    for (i=1; i<len_vector; i++)
    {   if (p_vector[i]>max_value)
        {
            max_value = p_vector[i];
        }
    }
    return max_value;
}

//---------------------------------------------------------------------------
// 计算数组最小值
double MIN_VECTOR(double *p_vector,
                  int len_vector)
{
    int i;    
    double min_value = p_vector[0];
    
    for (i=1; i<len_vector; i++)
    {   if (p_vector[i]<min_value)
        {
            min_value = p_vector[i];
        }
    }
    return min_value;
}

//---------------------------------------------------------------------------
// 计算数组标准差std
double STD(double *p_vector,
           int len_vector)
{
    int i;
    double mean_value,std_value,tmp1=0,tmp2=0;

    for (i=0; i<len_vector; i++)
    {   
        tmp1 = tmp1 + p_vector[i];
    }
    mean_value = tmp1/len_vector;
    
    for (i=0; i<len_vector; i++)
    {   
        tmp2 = tmp2 + (p_vector[i]-mean_value)*(p_vector[i]-mean_value);
    }
    std_value = sqrt(tmp2/len_vector);
    return std_value;
}



  