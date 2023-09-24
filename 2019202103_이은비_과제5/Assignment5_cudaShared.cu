#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <chrono>


#define GRIDSIZE (16*1024) //16K
#define BLOCKSIZE 1024 //1K
#define TOTALSIZE (GRIDSIZE*BLOCKSIZE) //16M

void genData(float* ptr, unsigned int size) {
    while (size--) {
        *ptr++ = (float)(rand() % 1000) / 1000.0F;
    }
}

__global__ void adj_diff_shared(float* result,float* input){
  __shared__ float s_data[BLOCKSIZE];
  unsigned int tx = threadIdx.x;
  unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
  s_data[tx] = input[i];
  __syncthreads();
  if(tx>0){
    result[i] = s_data[tx] - s_data[tx-1];
  }
  else if(i>0){
    result[i] = s_data[tx]- input[i-1];
  }

}

int main() {
    float* pSource = NULL;
    float* pResult = NULL;
    int i;
    long long cntStart, cntEnd, freq = 0LL;

    pSource = (float*)malloc(TOTALSIZE * sizeof(float));
    pResult = (float*)malloc(TOTALSIZE * sizeof(float));
    //generate input source data
        genData(pSource, TOTALSIZE);
        float* pSourceDev = NULL;
        float* pResultDev = NULL;
    //calculate the adjacent difference
        pResult[0] = 0.0F; // exceptional case for i = 0
        cudaMalloc((void**)&pSourceDev,TOTALSIZE*sizeof(float));
        cudaMalloc((void**)&pResultDev,TOTALSIZE*sizeof(float));
    //CUDA memcpy from host to device
      cudaMemcpy(pSourceDev,pSource,TOTALSIZE*sizeof(float),cudaMemcpyHostToDevice);
    //start the timer
        std::chrono::system_clock::time_point start = std::chrono::system_clock::now();
   //CUDA launch the kernel adjDiff
   dim3 dimGrid(GRIDSIZE,1,1);
   dim3 dimBlock(BLOCKSIZE,1,1);
   adj_diff_shared<<<dimGrid,dimBlock>>>(pResultDev,pSourceDev);
    //end the timer
        std::chrono::system_clock::time_point end = std::chrono::system_clock::now();
    //CUDA memcpy from device to host
     cudaMemcpy(pResult,pResultDev,TOTALSIZE*sizeof(float),cudaMemcpyDeviceToHost);
    std::chrono::nanoseconds duration_nano = end - start;
    printf("%lld\n", duration_nano);
    //print sample cases
        i = 1;
    printf("i=%7d : %f=%f-%f\n", i, pResult[i], pSource[i], pSource[i - 1]);
    i = TOTALSIZE - 1;
    printf("i=%7d : %f=%f-%f\n", i, pResult[i], pSource[i], pSource[i - 1]);
    i = TOTALSIZE / 2;
    printf("i=%7d : %f=%f-%f\n", i, pResult[i], pSource[i], pSource[i - 1]);
    free(pSource);
    free(pResult);
    cudaFree(pSourceDev);
    cudaFree(pResultDev);
}
