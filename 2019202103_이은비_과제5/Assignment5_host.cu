#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <chrono>


#define GRIDSIZE 16*1024 //16K
#define BLOCKSIZE 1024 //1K
#define TOTALSIZE (GRIDSIZE*BLOCKSIZE) //16M

void genData(float* ptr, unsigned int size) {
    while (size--) {
        *ptr++ = (float)(rand() % 1000) / 1000.0F;
    }
}

void adjDiff(float* dst, const float* src, unsigned int size) {
    for (int i = 1; i < size; i++) {
        dst[i] = src[i] - src[i - 1];
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
    //start the timer
        std::chrono::system_clock::time_point start = std::chrono::system_clock::now();
    //calculate the adjacent difference
        pResult[0] = 0.0F; // exceptional case for i = 0
        adjDiff(pResult, pSource, TOTALSIZE);
    //end the timer
        std::chrono::system_clock::time_point end = std::chrono::system_clock::now();
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
}
