#include <stdint.h>
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
using namespace std; 

//globals
FILE *pFile; 

void print_bits(uint32_t num)
{
    uint32_t size = sizeof(uint32_t); 
	 uint32_t maxPow = 1<<(size*8-1); 
	 printf("size = %d maxPow = %u \n", size, maxPow); 
	 int i=0; 
	 for(;i<size*8;i++)
	 {
    		printf("%u", num&maxPow ? 1:0);
	     //  printf("num = %u\n", num);
    		num = num <<1; 
	 }
}

uint32_t read_one_line()
{
	 uint32_t val = 0; 
	 if(fscanf(pFile, "%x\n", &val) !=EOF)
	 {
    		return val; 
	 }
	 else
    		printf("FATAL! File illegal"); 
}

uint32_t** load_image(uint32_t m, uint32_t n)  
{

	 uint32_t** input_image;
    	
	 input_image = (uint32_t**)malloc(sizeof(uint32_t*)*m);  	
	 if(!input_image)
	 	printf("Unable to allocate memory for image"); 	
	 for(int i = 0; i<m; i++)
	 {
    		*(input_image+i) = (uint32_t*)malloc(sizeof(uint32_t)*n); 
    		for(int j = 0; j< n; j++)
    		{
    			*(*(input_image+i) + j) = read_one_line(); 
    		}
	 }	

	 printf("image loaded successfully \n"); 
	 return input_image; 

}

uint32_t* draw_histogram(uint32_t** f, uint32_t l, uint32_t m, uint32_t n)
{
    uint32_t* h;
    uint32_t two_pow_l = (1<<l) -1 ;  
    uint32_t h_index ; 
    h = (uint32_t*)malloc(sizeof(uint32_t)*two_pow_l); 
    if(!h)
	 	printf("Unable to allocate memory for histogram"); 	
    for(int i = 0; i<m; i++)
	 {
    		*(f+i) = (uint32_t*)malloc(sizeof(uint32_t)*n); 
    		for(int j = 0; j< n; j++)
    		{
            h_index = *(*f+i)+j & two_pow_l; 
            if(h_index >= 1<<l)
                printf("FATAL Issue - due to h_index >= 2^l"); 
            (*(h + h_index)) ++ ; 
    		}
    }
	 printf("histogram loaded successfully \n"); 
    return h; 
        
}

uint32_t* compute_cdf(uint32_t* h, uint32_t l)
{
    uint32_t* cdf;
    uint32_t min = l<<1;
    
    uint32_t two_pow_l = (1<<l) -1 ;  
    cdf = (uint32_t*)malloc(sizeof(uint32_t)*(two_pow_l+1)); 
    if(!cdf)
	 	printf("Unable to allocate memory for histogram"); 	
    for(int i = 0; i < two_pow_l; i++)
    { 
        for(int j = 0; j <= i ; j++)
                *(cdf + i) = *(cdf+i) + *(h+j);  
        //find min
        if(*(cdf+i) < min)
           min = *(cdf + i);  
    } 
    *(cdf + (l<<1)) = min; 
	 printf("cdf computed successfully \n"); 
    return cdf; 
}

uint32_t** compute_output(uint32_t* cdf, uint32_t** input_image, uint32_t m, uint32_t n, uint32_t l)
{
    uint32_t cdf_min;  
    uint32_t input_image_local;  
    uint32_t** output_image; 
    uint32_t two_pow = l <<1;
    cdf_min = *(cdf + two_pow); 
    
    uint32_t factor = 0; 
    factor = (l-1)/((n-m)-cdf_min); 

	 output_image = (uint32_t**)malloc(sizeof(uint32_t*)*m);  	
	 if(!output_image)
	 	printf("Unable to allocate memory for output image"); 	

    for(int i = 0; i<m; i++)
	 {
    		*(output_image+i) = (uint32_t*)malloc(sizeof(uint32_t)*n); 
    		for(int j = 0; j< n; j++)
    		{
            input_image_local = *(*(input_image+i)+j); 
    			*(*(output_image+i) + j) = (*(cdf + input_image_local) - cdf_min)*factor; 
    		}
    }
	 printf("output_image computed successfully \n"); 
    return output_image; 
}
int main(int argc, char *argv[])
{

    char trace_file[40]; 
	 strcpy(trace_file, argv[1]); 
	 uint32_t M = atoi(argv[2]); 
	 uint32_t N = atoi(argv[3]); 
    
	 //File parsing
	 pFile = fopen(trace_file, "r"); 
    
	 uint32_t l = 16;
	 uint32_t two_pow = l<<1;
	 uint32_t **f = NULL; 
	 uint32_t **g = NULL; 
	 uint32_t *h = NULL; 
	 uint32_t *cdf = NULL; 
	 
    uint32_t cdf_min = 0;
	 
    //1. load image from file
  	 f = load_image(M, N); 
   
    //2. draw histogram 
    h = draw_histogram(f,l, M, N); 
    
    //3. calculate cdf
    cdf = compute_cdf(h,l);   
    cdf_min = *(cdf + two_pow); 

    //4. compute g
    g = compute_output(cdf, f, M, N, l); 
    return 0; 

}
