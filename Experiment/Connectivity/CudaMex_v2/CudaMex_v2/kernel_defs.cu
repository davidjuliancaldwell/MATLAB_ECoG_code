#include <cuda.h>
#include <cuda_runtime.h>
#include <mex.h>

#define MEX_CHECK_RETURN(in) {cudaError_t __errLocal = in; if(__errLocal != CUDA_SUCCESS) { mexPrintf("ERROR: file %s, line %i\n  CUDA call \n\t" #in " \n  returned error (%i) - \"%s\"\n", __FILE__, __LINE__, __errLocal, cudaGetErrorString(__errLocal)); } }

__device__ __constant__ int rvVectorLengths;
__device__ __constant__ int rvWindowSize;
__device__ __constant__ int rvPrePostLag;
__device__ __constant__ int rvLeftAlpha;
__device__ __constant__ int rvRightAlpha;
__device__ __constant__ int rvNumElsX;
__device__ __constant__ int rvNumElsY;
__device__ __constant__ int rvSharedMemorySizeX;
__device__ __constant__ int rvSharedMemorySizeY;

__device__ float kernel_cov(float *pA, float *pB, int pElements) {
	float summation[2] = {0.0f,0.0f};
	//Calculate the means for each vector
	for(int i = 0; i < pElements; i++) {
		summation[0] = summation[0] + pA[i];
		summation[1] = summation[1] + pB[i];
	}
	summation[0] = summation[0] / pElements;
	summation[1] = summation[1] / pElements;

	float covMeasure = 0.0f;
	//Calculate the means for each vector
	for(int i = 0; i < pElements; i++) {
		covMeasure = covMeasure + (pA[i]-summation[0])*(pB[i]-summation[1]);
	}
	covMeasure = covMeasure / (pElements-1);
	return covMeasure;
}



__global__ void windowed_cov(float *pX, float *pY, float *pOut, int pRowOffset) {

	extern __shared__ float sharedMem[];

	int t = blockIdx.y * gridDim.x + blockIdx.x;
	//t = t + 1;

	int yRange[2];
	yRange[0] = t-rvLeftAlpha;
	yRange[1] = t+rvRightAlpha;
	int xRange[2];
	xRange[0] = t - rvPrePostLag - rvLeftAlpha;
	xRange[1] = t + rvPrePostLag + rvRightAlpha;

	int outputRow = threadIdx.x + pRowOffset;

	int outputLocation = t * (2*rvPrePostLag + 1) + outputRow;
	
	
	/*if(xRange[0] < 0 || yRange[0] < 0 || xRange[1] > rvVectorLengths || yRange[1] > rvVectorLengths) {
		pOut[outputLocation] = 0;
		return;
	}*/

	float *ySharedMem = (float*) sharedMem;
	float *xSharedMem = (float*) &ySharedMem[rvNumElsY];
	
	//__shared__ float ySharedMem[rvSharedMemorySizeY];
	//__shared__ float xSharedMem[rvSharedMemorySizeX];

	/* 
		Load y into shared memory
	*/
	int globalMemLocation;



	//Pull the Y into shared memory
	int localMemPos = threadIdx.x;
	while(localMemPos < rvWindowSize+1) {
		globalMemLocation = min(max(yRange[0] + localMemPos,0),rvVectorLengths-1);
		ySharedMem[localMemPos] = pY[globalMemLocation];
		localMemPos = localMemPos + blockDim.x;
	}

	__syncthreads();
	// Y is loaded!

	/*if(outputRow < 601) {
		pOut[outputLocation] = ySharedMem[300];
	}
	return;*/

	/* 
		Load x into shared memory
	*/

	// Total evaluation range for this sample t
	int xEvalRange[2];
	xEvalRange[0] = t - rvPrePostLag;
	xEvalRange[1] = t + rvPrePostLag;


	// Evaluation range for this current kernel loop
	int kernelLoopEvalRange[2];
	kernelLoopEvalRange[0] = xEvalRange[0] + pRowOffset;
	kernelLoopEvalRange[1] = min(kernelLoopEvalRange[0] + blockDim.x,xEvalRange[1]);

	

	int blockMemoryRange[2];
	blockMemoryRange[0] = kernelLoopEvalRange[0] - rvLeftAlpha;
	blockMemoryRange[1] = min(kernelLoopEvalRange[1] + rvRightAlpha, xEvalRange[1] + rvRightAlpha);


	localMemPos = threadIdx.x;
	
	while(localMemPos < blockMemoryRange[1] - blockMemoryRange[0]+1) {
		globalMemLocation = min(max(blockMemoryRange[0] + localMemPos,0), rvVectorLengths-1);

		xSharedMem[localMemPos] = pX[globalMemLocation];
		localMemPos = localMemPos + blockDim.x;
	}

	__syncthreads();

	if(outputRow >= (2 * rvPrePostLag + 1)) {
		return;
	}
	

	float cov = kernel_cov(ySharedMem, xSharedMem + threadIdx.x, rvWindowSize + 1);
	
	pOut[outputLocation] = cov;
	//pOut[outputLocation] = blockMemoryRange[1];
}

void RunCuda(float *pStaticVector, float *pMovingVector, float *pOutput, int pNumElements, int pWindowSize, int pPrePostLag) {

	int deviceCount;
	MEX_CHECK_RETURN(cudaGetDeviceCount(&deviceCount));

	if(deviceCount == 2) {
		cudaSetDevice(1);
	}

	// Calculate the size of the output
	int heightOut = pPrePostLag * 2 + 1;
	int widthOut = pNumElements;
	int outputLength = heightOut * widthOut;

	int leftAlpha = ceil(pWindowSize/2.0f);
	int rightAlpha = floor(pWindowSize/2.0f);
	int numElsX = pWindowSize + 2 * pPrePostLag + 1;
	int numElsY = pWindowSize;
	int smXSz = numElsX*sizeof(float);
	int smYSz = numElsY*sizeof(float);

	//THIS WORKS
	int kernelRunsPerSample = 1;
	int threadsPerBlock = ceil(heightOut / 32.0f) * 32;

	while (threadsPerBlock > 512) {
		kernelRunsPerSample ++;
		threadsPerBlock = ceil((heightOut / kernelRunsPerSample)/32.0f)*32;
	}

	//Need to setup the number of blocks horizontally

	int verticalBlocksInGrid = 1;
	int horizontalBlocksInGrid = int(pNumElements * 1.0f / verticalBlocksInGrid); 

	while(horizontalBlocksInGrid > 65535) {
		verticalBlocksInGrid++;
		horizontalBlocksInGrid = int(pNumElements * 1.0f / verticalBlocksInGrid); 
	}



	//Now allocate the device data;

	float *deviceX, *deviceY, *deviceOutput;
	//mexPrintf("Allocating device input memory of length %i\n",pNumElements);
	MEX_CHECK_RETURN(cudaMalloc(&deviceX, sizeof(float) * pNumElements)); 
	MEX_CHECK_RETURN(cudaMalloc(&deviceY, sizeof(float) * pNumElements));

	//mexPrintf("Allocating device output (%ix%i) memory of length %.2fMB (%i bytes)\n",heightOut, widthOut, outputLength/1024.0f/1024.0f*sizeof(float),outputLength*sizeof(float));
	MEX_CHECK_RETURN(cudaMalloc(&deviceOutput, sizeof(float) * outputLength));

	//mexPrintf("Setting constants\n");
	MEX_CHECK_RETURN(cudaMemcpyToSymbol("rvVectorLengths", &pNumElements,sizeof(int)));
	MEX_CHECK_RETURN(cudaMemcpyToSymbol("rvWindowSize", &pWindowSize,sizeof(int)));
	MEX_CHECK_RETURN(cudaMemcpyToSymbol("rvPrePostLag", &pPrePostLag,sizeof(int)));
	MEX_CHECK_RETURN(cudaMemcpyToSymbol("rvLeftAlpha", &leftAlpha,sizeof(int)));
	MEX_CHECK_RETURN(cudaMemcpyToSymbol("rvRightAlpha", &rightAlpha,sizeof(int)));
	MEX_CHECK_RETURN(cudaMemcpyToSymbol("rvNumElsX", &numElsX, sizeof(int)));
	MEX_CHECK_RETURN(cudaMemcpyToSymbol("rvNumElsY", &numElsY, sizeof(int)));
	MEX_CHECK_RETURN(cudaMemcpyToSymbol("rvSharedMemorySizeX", &smXSz, sizeof(int)));
	MEX_CHECK_RETURN(cudaMemcpyToSymbol("rvSharedMemorySizeY", &smYSz, sizeof(int)));

	//mexPrintf("Copying local memory to device\n");
	MEX_CHECK_RETURN(cudaMemcpy( deviceX, pStaticVector, sizeof(float) * pNumElements, cudaMemcpyHostToDevice ));
	MEX_CHECK_RETURN(cudaMemcpy( deviceY, pMovingVector, sizeof(float) * pNumElements, cudaMemcpyHostToDevice ));

	//Don't think we need to do this
	//MEX_CHECK_RETURN(cudaMemcpy( deviceOutput, pOutput, sizeof(float) * outputLength, cudaMemcpyHostToDevice ));



	dim3 dimGrid(horizontalBlocksInGrid, verticalBlocksInGrid);
	dim3 dimBlock(threadsPerBlock);

	//kernelRunsPerSample = 1; //mexPrintf("**HARDCODED TO kernelRunsPerSample=%i**\n",kernelRunsPerSample);

	//mexPrintf("Starting CUDA!! will run kernel %ix times with Grid dimension %ix%i, TBP(%i)\n", kernelRunsPerSample, horizontalBlocksInGrid, verticalBlocksInGrid, threadsPerBlock);
	for(int runNum = 0; runNum < kernelRunsPerSample; runNum++) {
		windowed_cov<<<dimGrid, dimBlock,smXSz + smYSz>>>(deviceX, deviceY, deviceOutput, runNum * threadsPerBlock);
		MEX_CHECK_RETURN(cudaDeviceSynchronize());
		MEX_CHECK_RETURN(cudaGetLastError());
	}


	//mexPrintf("Pulling results from GPU\n");
	MEX_CHECK_RETURN(cudaMemcpy( pOutput, deviceOutput, sizeof(float) * outputLength, cudaMemcpyDeviceToHost ));

   	//mexPrintf("Freeing device output memory\n");
	MEX_CHECK_RETURN(cudaFree(deviceOutput));

	//mexPrintf("Freeing device memory\n");
	MEX_CHECK_RETURN(cudaFree(deviceX));
	MEX_CHECK_RETURN(cudaFree(deviceY));
	
	return;
}
