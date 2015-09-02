#include <mex.h>
#include <matrix.h>
#include <cuda.h>
#include <cuda_runtime.h>

#include <string.h>

static int retval = 0;

extern void RunCuda(float *pStatic, float *pMoving, float *pOutput, int pNumElements, int pWindowSize, int pPrePostLag, float *pWindow );

void mexFunction(int pNLHS, mxArray *pLHS[],int pNRHS, const mxArray *pRHS[]) {
	//mexPrintf("In CUDA mex file!\n");

	//mexPrintf("# inputs: %i\n", pNRHS);

	if(pNRHS <= 0) {
		return;
	}
	if(pNRHS != 5) {
		mexErrMsgTxt("usage: gausswc(nonshiftedChannel, shiftedChannel, windowSize, prePostLag,gaussianwindow)\n");
		retval = -1;
		return;
	}

	//mexPrintf("Input type: %s\n", mxGetClassName(pRHS[0]));

	if(strcmp(mxGetClassName(pRHS[0]),"single") != 0 || strcmp(mxGetClassName(pRHS[1]),"single") != 0 || strcmp(mxGetClassName(pRHS[4]),"single") != 0) {
		mexErrMsgTxt("This file handles 'single' input only\n");
		retval = -1;
		return;
	}

	// Check inputs to make sure that they're acceptable
	mwSize numElements;
	for(int inputNum = 0; inputNum < 2; inputNum++) {
		mwSize nDims = mxGetNumberOfDimensions(pRHS[inputNum]);
		//mexPrintf("First input # dimensions: %i\n", nDims);

		const mwSize *size = mxGetDimensions(pRHS[inputNum]);
		bool allOtherDimsAreOne = true;
		//mexPrintf("  Dimension: %i", size[0]);
		for(int dim = 1; dim < nDims; dim++) {
			allOtherDimsAreOne &= size[dim]==1;
			//mexPrintf("x%i", size[dim]);
		}
		//mexPrintf("\n");

		if(!allOtherDimsAreOne) {
			mexErrMsgIdAndTxt("MATLAB:CudaMex", "Need Nx1 for input %i", inputNum);
			retval = -1;
			return;
		}

		numElements = mxGetNumberOfElements(pRHS[inputNum]);
		//mexPrintf("Total number of elements: %i\n", numElements);
		float *pDataFromMatlab = (float*)mxGetData(pRHS[inputNum]);
		////mexPrintf("Data in order of memory:\n");
		//for(int i = 0; i < numElements; i++) {
		//	//mexPrintf("\t%f\n", pDataFromMatlab[i]);
		//}
	}

	int windowSize = 0;
	int prePostLag = 0;

	//Get Window Size
	if(strcmp(mxGetClassName(pRHS[2]),"single")== 0) {
		windowSize = (int)(*((float *)mxGetData(pRHS[2])));
	}
	else if(strcmp(mxGetClassName(pRHS[2]),"double")== 0) {
		windowSize = (int)(*((double *)mxGetData(pRHS[2])));
	}

	//Get prePostLAg
	if(strcmp(mxGetClassName(pRHS[3]),"single")== 0) {
		prePostLag = (int)(*((float *)mxGetData(pRHS[3])));
	}
	else if(strcmp(mxGetClassName(pRHS[3]),"double")== 0) {
		prePostLag = (int)(*((double *)mxGetData(pRHS[3])));
	}

	float *nonShiftedChan, *shiftedChan, *window, output;

	nonShiftedChan = (float*)mxGetData(pRHS[0]);
	shiftedChan = (float *)mxGetData(pRHS[1]);

	const mwSize *sizeWindow = mxGetDimensions(pRHS[4]);

	if(sizeWindow[1] != 1 || sizeWindow[0] != windowSize)  {
		mexErrMsgIdAndTxt("MATLAB:CudaMex", "Need WindowSizex1 for input 5");
		retval = -1;
		return;
	}



	window = (float *)mxGetData(pRHS[4]);

	mwSize outSize[2];
	outSize[0] = 2 * prePostLag + 1;
	outSize[1] = numElements;

	

	mxArray *outputArray = mxCreateNumericArray(2,outSize, mxSINGLE_CLASS, mxREAL);
	float *outputPtr = (float*)mxGetData(outputArray); 



	cudaError_t err;
	int deviceCount;
	err = cudaGetDeviceCount(&deviceCount);
	if(err != CUDA_SUCCESS) {
		printf("Error querying device count!\n ERROR %i: %s\n", err, cudaGetErrorString(err));
		retval = -1;
		return;
	}
	//mexPrintf("Detected %i CUDA devices\n", deviceCount);

	if(deviceCount <= 0) {
		mexErrMsgIdAndTxt("MATLAB:CudaMex:CudaInitializer", "No CUDA devices found!");
		return;
	}



	//mexPrintf("Window size: %i\n prePostLag: %i\n", windowSize, prePostLag);

	RunCuda(nonShiftedChan, shiftedChan, outputPtr, numElements, windowSize, prePostLag,  window);
	pLHS[0] = outputArray;

}