/*Author: Rainer Hegger. Last modified, Sep 20, 2000 */
#include <math.h>
#include "mex.h"
#include <stdio.h>
#include <stdlib.h>
#include <matrix.h>

// 定义输入参数
#define X prhs[0]   // 时间序列（列向量）
#define L prhs[1]  

// 定义输出参数
#define E plhs[0]


// 声明 C 运算函数 (该函数名不能和本文件名重名)
void mutual_FUNCTION(); 
void rescale_data();
double make_cond_entropy();
double *pdata,*entropy;
//int *tau;
unsigned long length;
long partitions=128,corrlength;
long *array,*h1,*h11,**h2;
	

//--------------------------------------------------------


void mexFunction (int nlhs, mxArray *plhs[],			// 输出参数个数，及输出参数数组
			 int nrhs, const mxArray *prhs[])	// 输入参数个数，及输入参数数组
{
 // int i;
	
	if (nrhs!=2) mexErrMsgTxt("只需要2个参数!");  //检查输入参数的个数
	
    // 取得输入参数
    pdata = mxGetPr(X);      // 时间序列（列向量）      
    length = mxGetM(X);  // 序列长度
    corrlength=(long)*mxGetPr(L);
   // for(i=0;i<length;i++)
	//printf("%d %f\n",i ,pdata[i]);
	
    // 为输出变量分配内存空间
	//T= mxCreateDoubleMatrix(1,1,mxREAL); //用于存放E1
	E= mxCreateDoubleMatrix(corrlength+1,1,mxREAL); //用于存放E2
    
   // T= (int*)malloc(sizeof(int)); //用于存放E1
	//E=(double*)malloc((corrlength+1)*sizeof(double)); //用于存放E2
	
	// 取得输出参数指针
	//tau = mxGetPr(T);
    entropy = mxGetPr(E);
	
    // 调用 C 运算函数 (该函数名不能和本文件名重名)
     //tau=(int*)malloc(sizeof(int));
	//	entropy=(double*)malloc((corrlength+1)*sizeof(double));
    mutual_FUNCTION(pdata,length,partitions,corrlength,array,h1,h11,h2);  
	//free(pdata);free(entropy);free(array);free(h1);free(h11);free(h2);
    
   //  for(i=0;i<corrlength;i++)
	//printf("%d  %f\n",i ,entropy[i]);
    //printf("tau=%d\n",*tau);
    
}	





void mutual_FUNCTION(double *pdata,unsigned long length,
					 long partitions,long corrlength,long *array,
					 long *h1,long *h11,long **h2)  
{
	long tau1,i;
	double min,interval,shannon;

	rescale_data(pdata,length,&min,&interval);
	
	h1=(long *)malloc(sizeof(long)*partitions);
	h11=(long *)malloc(sizeof(long)*partitions);
	h2=(long **)malloc(sizeof(long *)*partitions);
	
	for (i=0;i<partitions;i++) 
		h2[i]=(long *)malloc(sizeof(long)*partitions);
	
	array=(long *)malloc(sizeof(long)*length);
	for (i=0;i<length;i++)
		if (pdata[i] < 1.0)
			array[i]=(long)(pdata[i]*(double)partitions);
		else
			array[i]=partitions-1;
	
		
		//shannon=make_cond_entropy(0,array,h1,h11,h2,partitions,length,entropy);
		if (corrlength >= length)
			corrlength=length-1;
		
		
		entropy[0]=make_cond_entropy(0,array,h1,h11,h2,partitions,length);
		for (tau1=1;tau1<=corrlength;tau1++)
		{  entropy[tau1]=make_cond_entropy(tau1,array,h1,h11,h2,partitions,length);}
		/*
        for (i=0;i<=corrlength-1;i++)           
		{ 
			if (entropy[i]<=entropy[i+1])
			{*tau = i;   break;}
		}
		
		for (i=0;i<=corrlength;i++)
		{  printf("%d %e\n",i,entropy[i]);}
		printf("tau=%d\n",*tau);*/
	
}

void rescale_data(double *x,unsigned long l,double *min,double *interval)
{
	int i;
	
	*min=*interval=x[0];
	
	for (i=1;i<l;i++) {
		if (x[i] < *min) *min=x[i];
		if (x[i] > *interval) *interval=x[i];
	}
	*interval -= *min;
	
		for (i=0;i<l;i++)
			x[i]=(x[i]- *min)/ *interval;
	
}



					 
double make_cond_entropy(long t,long *array,long *h1,long *h11,long **h2,
						 long partitions,unsigned long length)
{
  long i,j,hi,hii,count=0;
  double hpi,hpj,pij,cond_ent=0.0,norm;

  for (i=0;i<partitions;i++) {
    h1[i]=h11[i]=0;
    for (j=0;j<partitions;j++)
      h2[i][j]=0;
  }
  for (i=0;i<length;i++)
    if (i >= t) {
      hii=array[i];
      hi=array[i-t];
      h1[hi]++;
      h11[hii]++;
      h2[hi][hii]++;
      count++;
    }

  norm=1.0/(double)count;
  cond_ent=0.0;

  for (i=0;i<partitions;i++) {
    hpi=(double)(h1[i])*norm;
    if (hpi > 0.0) {
      for (j=0;j<partitions;j++) {
	hpj=(double)(h11[j])*norm;
	if (hpj > 0.0) {
	  pij=(double)h2[i][j]*norm;
	  if (pij > 0.0)
	    cond_ent += pij*log(pij/hpj/hpi);
	}
      }
    }
  }

  return cond_ent;
}

 
//----------------------------------------------------

/*
void main()
{
  
  
    int k;
    //double *series,min,interval,shannon;
    FILE *file,*fp;
    
     char a[25];
    double *pdata,ndata;//result,*value;
    
    
    if(!(fp=fopen("stock.dat","r")))
    {
  	  printf("打开文件数据错误!\n");
  	  exit(0);
    }
    
    //得到数据个数 size		
    while(fscanf(fp,"%f",&ndata)==1)
    {length++;}
    
    rewind(fp);
    
    //Set pointer to beginning of file:      
    fseek( fp, 0L, SEEK_SET );
    
    
    //初始化数据
    pdata=(double*)malloc(length*sizeof(double));
    
    //Read data back from file:
    for(k=0;k<length;k++)
    { fgets(a,25,fp);
    pdata[k]=atof(a);}
    fclose( fp );
    
	tau=(int*)malloc(sizeof(int));
	entropy=(double*)malloc((corrlength+1)*sizeof(double));
    mutual_FUNCTION(pdata,length,partitions,corrlength,array,h1,h11,h2);  
    
                file=fopen("file_out.txt","w");
              for (k=0;k<=corrlength;k++)
               	{  fprintf(file,"%d %e\n",k,entropy[k]);}
               	fprintf(file,"tau=%d",*tau);
                    fclose(file);
  
  }
 */
 