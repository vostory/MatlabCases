#include <math.h>
#include "mex.h"
#include "stdio.h"
#include "stdlib.h"


// 定义输入参数
#define X prhs[0]
#define MAXLAGS prhs[1]
#define PARTITIONS prhs[2]

// 定义输出参数
#define R plhs[0]

// 声明 C 运算函数 (该函数名不能和本文件名重名)
void amutual_run();
double max_vector();
double min_vector();
double sum_vector();
int findsn();
void print_array();

//--------------------------------------------------------

void 
mexFunction (int nlhs, mxArray *plhs[],			// 输出参数个数，及输出参数数组
			 int nrhs, const mxArray *prhs[])	// 输入参数个数，及输入参数数组
{
    double *px,*pr;
    int maxLags, partitions, len;
    
  
    //-----------------------------------------------    

    // 取得输入参数
    px = mxGetPr(X);                            // 时间序列
    len = mxGetM(X);                            // 序列长度
	maxLags = (int) mxGetScalar(MAXLAGS);       // 最大时延
	partitions = (int) mxGetScalar(PARTITIONS); // 最大网格数
	
	// mexPrintf("\nlen = %d, maxLags = %d, partitions = %d\n",len,maxLags,partitions); 
	
    // 为输出变量分配内存空间
	R = mxCreateDoubleMatrix(maxLags+1,1,mxREAL); 

	// 取得输出参数指针
	pr = mxGetPr(R);

    // 调用 C 运算函数 (该函数名不能和本文件名重名)
    amutual_run(pr,px,len,maxLags,partitions);
	return;
}

//--------------------------------------------------------
// 定义 C 运算函数

void amutual_run(double *pr,        // 互信息
                 double *px,        // 时间序列
                 int len,           // 序列长度
                 int maxLags,       // 最大时延
                 int partitions)    // 最大网格数
{
    double max_x,min_x,width,*pPoint_end,*pP1,*pP2,sum_p1,sum_p2,tmp,a,b;
    int i,j,n,sn,tau;
    
    max_x = max_vector(px,len);
    min_x = min_vector(px,len);
    width = (max_x-min_x)/partitions;   // 网格宽度
    
    // mexPrintf("\nmax_x = %f, min_x = %f, witdh = %f\n",max_x,min_x,width); 

    pPoint_end = (double*) mxCalloc(partitions,sizeof(double));
    for (i=0;i<partitions;i++)
    {
        pPoint_end[i] = min_x + (i+1)*width;        // 每一网格终点
    }

    pP1 = (double*) mxCalloc(partitions,sizeof(double));
    for (i=0;i<len;i++)
    {
        sn = findsn(px[i],pPoint_end,partitions);   // 特别注意:返回区间号(从0开始)
        pP1[sn] = pP1[sn]+1;
    }
    sum_p1 = sum_vector(pP1,partitions);
    for (i=0;i<partitions;i++)
    {
        pP1[i] = pP1[i]/sum_p1;                     // 除以总和,转成概率密度
    }

    // print_array(pP1,partitions,1);

    for (tau=0;tau<=maxLags;tau++)
    {
        pP2 = (double*) mxCalloc(partitions*partitions,sizeof(double));
        for (n=0;n<len-tau;n++)
        {
            i = findsn(px[n],pPoint_end,partitions);
            j = findsn(px[n+tau],pPoint_end,partitions);
            pP2[j*partitions+i] = pP2[j*partitions+i] + 1;
        }
        sum_p2 = sum_vector(pP2,partitions*partitions);
        for (i=0;i<partitions*partitions;i++)
        {
            pP2[i] = pP2[i]/sum_p2;                     // 除以总和,转成概率密度
        }
        // print_array(pP2,partitions,partitions);
        
        tmp = 0;
        for (i=0;i<partitions;i++)
        {    for (j=0;j<partitions;j++)
            {
                a = pP2[j*partitions+i];
                b = pP1[i]*pP1[j];
                if (a>0 && b!=0)
                {
                    tmp = tmp + a*(log(a/b)/log(2));    // 以2为底的对数
                }
            }
        }
        pr[tau] = tmp;        
        mxFree(pP2);
    }
    mxFree(pP1);
    mxFree(pPoint_end);    
}

//--------------------------------------------------------
// 计算数组最大值

double max_vector(double vector[], 
                  int len)
{
    double max_value = vector[0];
    int i;
    for (i=1;i<len;i++)
    {   if (vector[i]>max_value)
        {   
            max_value = vector[i];
        }
    }
    return max_value;   
}

//--------------------------------------------------------
// 计算数组最小值

double min_vector(double vector[], 
                  int len)
{
    double min_value = vector[0];
    int i;
    for (i=1;i<len;i++)
    {   if (vector[i]<min_value)
        {   
            min_value = vector[i];
        }
    }
    return min_value;   
}

//--------------------------------------------------------
// 计算数组的和

double sum_vector(double vector[], 
                  int len)
{
    double sum_value = 0;
    int i;
    for (i=0;i<len;i++)
    { 
        sum_value = sum_value + vector[i];
    }
    return sum_value;   
}

//--------------------------------------------------------
// 判断 xn 值位于哪一个区间, 特别注意:返回区间号(从0开始)

int findsn(double xn,           // 序列值
           double point_end[],  // 取值区间的右限
           int len)             // 区间数
{
    int i,sn;
    for (i=0;i<len;i++)
    {   if (xn<=point_end[i])
        {
            sn = i;   
            break;
        }
    }
    return sn;
}

//--------------------------------------------------------
// 打印矩阵内容

void print_array(double *pArray,    // 矩阵指针(列向量)
                 int rows,          // 行
                 int columns)       // 列
{
    int i,j;
    for (i=0;i<rows;i++)
    {   for (j=0;j<columns;j++)
        {
            mexPrintf("%.4f ",pArray[j*rows+i]);        
        }
        mexPrintf("\n");
    }    
} 


