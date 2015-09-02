#include <mex.h>
#include <matrix.h>
#include <cuda.h>
#include <cuda_runtime.h>

#include <string.h>

static int retval = 0;

extern void RunCuda(float *pStatic, float *pMoving, float *pOutput, int pNumElements, int pWindowSize, int pPrePostLag);

void mexFunction(int pNLHS, mxArray *pLHS[],int pNRHS, const mxArray *pRHS[]) {
	//mexPrintf("In CUDA mex file!\n");

	//mexPrintf("# inputs: %i\n", pNRHS);

	if(pNRHS <= 0) {
		return;
	}
	if(pNRHS != 4) {
		mexErrMsgTxt("usage: CudaMex(nonshiftedChannel, shiftedChannel, windowSize, prePostLag)\n");
		retval = -1;
		return;
	}

	//mexPrintf("Input type: %s\n", mxGetClassName(pRHS[0]));

	if(strcmp(mxGetClassName(pRHS[0]),"single") != 0) {
		mexErrMsgTxt("This file handles 'single' input only\n");
		retval = -1;
		return;
	}

	// Check inputs to make sure that they're acceptable
	mwSize numElements;
	for(int inputNum = 0; inputNum < 2; inputNum++) {
		mwSize nDims = mxGetNumberOfDimensions(pRHS[inputNum]);
		//mexPrintf("First input # dimensions: %i\n", nDims);

		const mwSize *size = mxGetDimensions_730(pRHS[inputNum]);
		bool allOtherDimsAreOne = true;
		//mexPrintf("  Dimension: %i", size[0]);
		for(int dim = 1; dim < nDims; dim++) {
			allOtherDimsAreOne &= size[dim]==1;
			//mexPrintf("x%i", size[dim]);
		}
		//mexPrintf("\n");

		if(!allOtherDimsAreOne) {
			mexErrMsgIdAndTxt("MATLAB:CudaMex", "Neex Nx1 for input %i", inputNum);
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

	float *nonShiftedChan, *shiftedChan, output;

	nonShiftedChan = (float*)mxGetData(pRHS[0]);
	shiftedChan = (float *)mxGetData(pRHS[1]);

	mwSize outSize[2];
	outSize[0] = 2 * prePostLag + 1;
	outSize[1] = numElements;

	mxArray *outputArray = mxCreateNumericArray_730(2,outSize, mxSINGLE_CLASS, mxREAL);
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

	RunCuda(nonShiftedChan, shiftedChan, outputPtr, numElements, windowSize, prePostLag);
	pLHS[0] = outputArray;

}