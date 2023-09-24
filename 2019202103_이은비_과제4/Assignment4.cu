#include <stdio.h>
#include <iostream>
#include <cuda.h>
using namespace std;

__global__ void MatrixMulKernel(int *c, const int* a, const int* b,const int WIDTH){
  int x = blockIdx.x*blockDim.x+threadIdx.x;
  int y = blockIdx.y*blockDim.y+threadIdx.y;
  int i = y*WIDTH+x;
  
  if(x<WIDTH && y<WIDTH){
    int sum =0;
  for(int k=0;k<WIDTH;k++){
    sum += a[y*WIDTH+k]*b[k*WIDTH+x];
  }
  c[i]=sum;
  }
}

int main(){
const int WIDTH = 16;
const int TILE_WIDTH = 8;
int a[WIDTH][WIDTH];
int b[WIDTH][WIDTH];
int c[WIDTH][WIDTH]={0};

for(int y=0;y<WIDTH;y++){
  for(int x=0;x<WIDTH;x++)
  {
    a[y][x]=x+y;
    b[y][x]=x+y;
  }

}


int *dev_a, *dev_b,*dev_c=0;
cudaMalloc((void**)&dev_a,WIDTH*WIDTH*sizeof(int));
cudaMalloc((void**)&dev_b,WIDTH*WIDTH*sizeof(int));
cudaMalloc((void**)&dev_c,WIDTH*WIDTH*sizeof(int));


cudaMemcpy(dev_a,a,WIDTH*WIDTH*sizeof(int),cudaMemcpyHostToDevice);
cudaMemcpy(dev_b,b,WIDTH*WIDTH*sizeof(int),cudaMemcpyHostToDevice);

dim3 dimGrid(WIDTH/TILE_WIDTH,WIDTH/TILE_WIDTH,1);
dim3 dimBlock(TILE_WIDTH,TILE_WIDTH,1);

MatrixMulKernel<<<dimGrid,dimBlock>>>(dev_c,dev_a,dev_b,WIDTH);
cudaMemcpy(c,dev_c,WIDTH*WIDTH*sizeof(int),cudaMemcpyDeviceToHost);
for(int y=0;y<TILE_WIDTH;y++){
  
  for(int x=0;x<TILE_WIDTH;x++){
    printf("%5d",c[y][x]);
  }
  printf(" ");
  for(int x=TILE_WIDTH;x<WIDTH;x++){
    printf("%5d",c[y][x]); 
  }
  printf("\n");
  
}printf("\n");

for(int y=TILE_WIDTH;y<WIDTH;y++){
  
  for(int x=0;x<TILE_WIDTH;x++){
    printf("%5d",c[y][x]);
  }
  printf(" ");
  for(int x=TILE_WIDTH;x<WIDTH;x++){
    printf("%5d",c[y][x]); 
  }
  printf("\n");
  
}


  cudaFree(dev_a);
  cudaFree(dev_b);
  cudaFree(dev_c);
  return 0;
}
