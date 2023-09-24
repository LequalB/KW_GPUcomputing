#include <stdio.h>
#include <iostream>
#include <cuda.h>
using namespace std;

__global__ void mulKernel(int *c, const int* a, const int* b,const int WIDTH){
  int x = threadIdx.x;
  int y = threadIdx.y;
  int i = y*(blockDim.x)+x;
  if(x<WIDTH && y<WIDTH){
    int sum =0;
  for(int k=0;k<WIDTH;k++){
    sum += a[y*WIDTH+k]*b[k*WIDTH+x];
  }
  c[i]=sum;
  }
}

int main(){
const int WIDTH = 5;
const int a[WIDTH][WIDTH]={1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1,1,1,1,1};
const int b[WIDTH][WIDTH]={2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6};
int c[WIDTH][WIDTH]={0};



int *dev_a, *dev_b,*dev_c=0;
cudaMalloc((void**)&dev_a,WIDTH*WIDTH*sizeof(int));
cudaMalloc((void**)&dev_b,WIDTH*WIDTH*sizeof(int));
cudaMalloc((void**)&dev_c,WIDTH*WIDTH*sizeof(int));


cudaMemcpy(dev_a,a,WIDTH*WIDTH*sizeof(int),cudaMemcpyHostToDevice);
cudaMemcpy(dev_b,b,WIDTH*WIDTH*sizeof(int),cudaMemcpyHostToDevice);

dim3 DimBlock(WIDTH,WIDTH);
mulKernel<<<1,DimBlock>>>(dev_c,dev_a,dev_b,WIDTH);
cudaMemcpy(c,dev_c,WIDTH*WIDTH*sizeof(int),cudaMemcpyDeviceToHost);

for(int y=0;y<WIDTH;y++){
  for(int x=0;x<WIDTH;x++){
    printf("%5d",c[y][x]);
  }
  printf("\n");
}

  cudaFree(dev_a);
  cudaFree(dev_b);
  cudaFree(dev_c);
  return 0;
}
