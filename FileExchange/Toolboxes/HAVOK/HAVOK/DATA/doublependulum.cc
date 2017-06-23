#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define PI 3.14159265358979323846
#define ERRTOL (1.e-14)
#define ZERO (1.e-15)

#define RUNTIME 250. 
#define h .001

#define m1 1
#define m2 1
#define l1 1
#define l2 1
#define g 10

#define M11 (l1*l1*(m1+m2))
#define M12 (m2*l1*l2)
#define M21 (m2*l1*l2)
#define M22 (m2*l2*l2)
#define V1 ((m1+m2)*l1*g)
#define V2 (m2*l2*g)

int main()
{
   int i,j,k,N;
   double *x,*y,**traj;
   double *q,*p,*qy;
   double *f,**df;
   double v[2];
   void newton_meth(double *q,double *qy,double *x,double *f,double **df);
   void calc_p(double *p,double *q,double *x);
   double calc_H(double *x);
   double calc_E(double *x);
   N=1+floor(RUNTIME/h);
  
   x=(double*)calloc(4,sizeof(double));
   y=(double*)calloc(4,sizeof(double));
   p=(double*)calloc(2,sizeof(double));
   q=(double*)calloc(2,sizeof(double));
   qy=(double*)calloc(2,sizeof(double));
   f=(double*)calloc(2,sizeof(double));
   df=(double**)calloc(2,sizeof(double*));
   for(i=0;i<2;i++) {
      df[i]=(double*)calloc(2,sizeof(double));
      if(df[i]==NULL) {puts("Out of memory!"); exit(1);}
   }
   traj=(double**)calloc(N,sizeof(double*));
   for(i=0;i<N;i++) {
      traj[i]=(double*)calloc(4,sizeof(double));
      if(traj[i]==NULL) {puts("Out of memory!"); exit(1);}
   } 


   /*IC1
   traj[0][0] = PI;//angle a 
   traj[0][1] = PI;// b
   x[0] = PI;
   x[1] = PI;
   v[0] = 0.3;
   v[1] = 0.3;
   q[0] = v[0]*h+x[0];
   q[1] = v[1]*h+x[1];
   calc_p(p,q,x);
   traj[0][2] = p[0];//angular momentum pa
   traj[0][3] = p[1];// pb*/


   /*IC2*/
   traj[0][0] = PI;//angle a 
   traj[0][1] = PI/4;// b
   x[0] = PI;
   x[1] = PI/4;
   v[0] = 0.0;
   v[1] = 0.0;
   q[0] = v[0]*h+x[0];
   q[1] = v[1]*h+x[1];
   calc_p(p,q,x);
   traj[0][2] = p[0];//angular momentum pa
   traj[0][3] = p[1];// pb
  

   /*IC3
   traj[0][0] = PI/2;//angle a 
   traj[0][1] = PI/2;// b
   x[0] = PI/2;
   x[1] = PI/2;
   v[0] = 0.0;
   v[1] = 0.0;
   q[0] = v[0]*h+x[0];
   q[1] = v[1]*h+x[1];
   calc_p(p,q,x);
   traj[0][2] = p[0];//angular momentum pa
   traj[0][3] = p[1];// pb*/

   for(i=1;i<N;i++) {
      for(j=0;j<4;j++) x[j] = traj[i-1][j];
      newton_meth(q,qy,x,f,df);
      calc_p(p,q,x); 
      for(j=0;j<2;j++) {
         traj[i][j] = q[j];
         traj[i][j+2] = p[j];
      }
   }//VARIATIONAL UPDATE
  
/*   for(i=1;i<N;i=i+100) {
      y[0] = traj[i][0];
      y[1] = traj[i][1];
      y[2] = (traj[i][0]-traj[i-1][0])/h;
      y[3] = (traj[i][1]-traj[i-1][1])/h;
      printf("%e %e\n",i*h,calc_E(y));
   } */
   for(i=0;i<N;i=i+1) printf("%e %e %e %e %e %e\n",traj[i][0],traj[i][1],traj[i][2],traj[i][3],i*h,calc_H(traj[i]));

   for(i=0;i<N;i++) free(traj[i]); 
   for(i=0;i<2;i++) free(df[i]);
   free(traj);
   free(df);
   free(x);
   free(y);
   free(p);
   free(q);
   free(qy);
   free(f);
   return 0;
}


void newton_meth(double *q,double *qy,double *x,double *f,double **df)
{//(x1,x2) is guess for q
   int i,j,k;
   double error;
   void calc_f(double *x,double *q,double *f);
   void calc_df(double *x,double *q,double **df);
   void gauss(int n,double **df,double *y);
   q[0] = x[0];//initial guess
   q[1] = x[1];//initial guess
   i=0;
   error = 1.;
   do {
      i=i+1;
      if(i==150) {
        puts("newton_meth: Error! Newton's method doesn't converge!");
        puts("newton_meth: Action Taken!  Program Aborted!");
        exit(1);
      }
      calc_f(x,q,f);
      for(j=0;j<2;j++) qy[j] = f[j];
      calc_df(x,q,df);
      gauss(2,df,qy);
      for(j=0;j<2;j++) q[j] = q[j] - qy[j];
      error = sqrt(qy[0]*qy[0]+qy[1]*qy[1]);
   }  while (fabs(error) > ERRTOL);
   return;
}

void calc_f(double *x,double *q,double *f)
{
   f[0] = x[2]-M11*(q[0]-x[0])/h-M12*(q[1]-x[1])*(cos(x[0]-x[1])+cos(q[0]-q[1]))/(2*h)-M12*(q[0]-x[0])*(q[1]-x[1])*(sin(x[0]-x[1]))/(2*h)-V1*sin(x[0])*h/2;
   f[1] = x[3]-M22*(q[1]-x[1])/h-M12*(q[0]-x[0])*(cos(x[0]-x[1])+cos(q[0]-q[1]))/(2*h)+M12*(q[0]-x[0])*(q[1]-x[1])*(sin(x[0]-x[1]))/(2*h)-V2*sin(x[1])*h/2;
   return;
}

void calc_df(double *x,double *q,double **df)
{
   df[0][0] = -M11/h+M12*(q[1]-x[1])*(sin(q[0]-q[1])-sin(x[0]-x[1]))/(2*h);
   df[0][1] = -1*(M12/(2*h))*(cos(x[0]-x[1])+cos(q[0]-q[1])+(q[1]-x[1])*(sin(q[0]-q[1]))+(q[0]-x[0])*(sin(x[0]-x[1])));
   df[1][0] = (M12/(2*h))*(-cos(x[0]-x[1])-cos(q[0]-q[1])+(q[0]-x[0])*sin(q[0]-q[1])+(q[1]-x[1])*sin(x[0]-x[1]));
   df[1][1] = -M22/h-M12*(q[0]-x[0])*(sin(q[0]-q[1])-sin(x[0]-x[1]))/(2*h);
   return;
}

void calc_p(double *p,double *q,double *x)
{
   p[0] = 2*M11*(q[0]-x[0])+M12*(q[1]-x[1])*(cos(x[0]-x[1])+cos(q[0]-q[1]))-M12*(q[0]-x[0])*(q[1]-x[1])*(sin(q[0]-q[1]))-V1*sin(q[0])*h*h;
   p[0] = p[0]/(2*h);
   p[1] = 2*M22*(q[1]-x[1])+M12*(q[0]-x[0])*(cos(x[0]-x[1])+cos(q[0]-q[1]))+M12*(q[0]-x[0])*(q[1]-x[1])*(sin(q[0]-q[1]))-V2*sin(q[1])*h*h;
   p[1] = p[1]/(2*h);
   return;
}

double calc_H(double *x)
{
   double denom,numer,value,pot;
   numer = l2*l2*m2*x[2]*x[2]+l1*l1*(m1+m2)*x[3]*x[3]-2*m2*l1*l2*x[2]*x[3]*cos(x[0]-x[1]);
   denom = 2*l1*l1*l2*l2*m2*(m1+m2*sin(x[0]-x[1])*sin(x[0]-x[1]));
   pot = V1*(1-cos(x[0]))+V2*(1-cos(x[1]));
   value = numer/denom + pot;
   return value;
}

double calc_E(double *x)
{
   double kin,pot,value;
   kin = .5*M11*x[2]*x[2]+.5*M22*x[3]*x[3]+M12*x[2]*x[3]*cos(x[0]-x[1]);
   pot = V1*(1-cos(x[0]))+V2*(1-cos(x[1]));
   value = kin+pot;
   return value;
}


void gauss(int n, double **a, double *b)
{
   int i_max,i,k,j;
   double max,m;
   double aux;
   void permutar_files_matriu(double **matriu, int m, int i, int j);
   
   for(k=0;k<=n-2;k++)
   {
     max = fabs(a[k][k]);
     i_max=k;
     for(i=k+1;i<n;i++)
       if(fabs(a[i][k])>max){  max=fabs(a[i][k]); i_max=i; }
     if(i_max!=k)
     {
       permutar_files_matriu(a,n,i_max,k);
       aux = b[k];
       b[k] = b[i_max];
       b[i_max] = aux;
     }
     for(i=k+1;i<=n-1;i++)
     {
       if(fabs(a[k][k])<ZERO)
       {
         printf("~~~*~~~gauss: ERROR! dividint per zero en Gauss! , k= %d\n", k);
	 exit(1);
       }
       m = a[i][k]/(a[k][k]);
       b[i]= b[i]- m*b[k];
       a[i][k]=0;
       for(j=k+1;j<n;j++) a[i][j]= a[i][j]-m*a[k][j];
     }
   }
   for(i=n-1;i>=0;i--)
   {
     max=0.;
     for(j=i+1;j<n;j++)  max=max+a[i][j]*b[j];
     b[i]=(b[i]-max)/(a[i][i]);
   }
}

void permutar_files_matriu(double **matriu, int m, int i, int j)
{
   int k;
   double aux;
   for(k=0;k<m;k++)
   {
     aux = matriu[i][k];
     matriu[i][k] = matriu[j][k];
     matriu[j][k] = aux;
   }
}
