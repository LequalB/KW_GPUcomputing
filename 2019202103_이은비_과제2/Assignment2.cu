#include <iostream>
#include <cuda.h>
__global__ void addKernel(int *d,const int *a,const int *b,const int *c){
    int i = threadIdx.x; //kernel function
    d[i]=a[i]+b[i]+c[i];
} //use PREFIX '__global__'that launched by CPU
int main(){
    const int SIZE = 5; //arraysize
    const int a[SIZE] = {1,2,3,4,5}; //initialize the values of source arrays
    const int b[SIZE] = {11,12,13,14,15};
    const int c[SIZE] = {21,22,23,24,25};
    int d[SIZE] ={0}; //initialize the array to store result value 
    
    int *dev_a = 0; //initialize variables
    int *dev_b = 0;
    int *dev_c = 0;
    int *dev_d = 0;

    cudaMalloc((void**)&dev_d,SIZE*sizeof(int)); //Allocate the memory of the kernel 
    cudaMalloc((void**)&dev_a,SIZE*sizeof(int));
    cudaMalloc((void**)&dev_b,SIZE*sizeof(int));
    cudaMalloc((void**)&dev_c,SIZE*sizeof(int));

    cudaMemcpy(dev_a,a,SIZE*sizeof(int),cudaMemcpyHostToDevice); //Copy data from CPU to GPU
    cudaMemcpy(dev_b,b,SIZE*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c,c,SIZE*sizeof(int),cudaMemcpyHostToDevice);
    addKernel<<<1,SIZE>>>(dev_d,dev_a,dev_b,dev_c); //kernel function call
    cudaDeviceSynchronize();

    cudaMemcpy(d,dev_d,SIZE*sizeof(int),cudaMemcpyDeviceToHost); //Copy data from GPU to CPU

    printf("{1,2,3,4,5}+{11,12,13,14,15}+{21,22,23,24,25} = {%d,%d,%d,%d,%d}\n",
           d[0],d[1],d[2],d[3],d[4]); //Print to check results

    cudaFree(dev_d); //Release memory allocated to the kernel
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);
    return 0;

}
