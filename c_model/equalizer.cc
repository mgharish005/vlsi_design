#include <stdint.h>
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
using namespace std; 

typedef struct uint128_type
{
    uint8_t t[16];
}uint128_t; 

//globals
FILE *pFile; 
FILE *pFile_hist_waddr; 
FILE *pFile_hist_wdata; 

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

uint128_t read_one_line()
{
	 uint128_t val; 
    uint32_t val0, val1, val2, val3; 
    uint32_t mask1 = 0xF000; 
    uint32_t mask2 = 0x0F00; 
    uint32_t mask3 = 0x00F0; 
    uint32_t mask4 = 0x000F; 

    //reading 32 hexa decimal value in a line - memory width is 128 bits 
//  if(fscanf(pFile, "%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x\n", &val) !=EOF)
    if(fscanf(pFile, "%x%x%x%x\n", &val0, &val1, &val2, &val3) !=EOF)
	 {
         val.t[0] = val0 && mask1 >> 0xc; 
         val.t[1] = val0 && mask2 >> 0x8; 
         val.t[2] = val0 && mask3 >> 0x4; 
         val.t[3] = val0 && mask4; 
         
         val.t[4] = val1 && mask1 >> 0xc; 
         val.t[5] = val1 && mask2 >> 0x8; 
         val.t[6] = val1 && mask3 >> 0x4; 
         val.t[7] = val1 && mask4; 

         val.t[8]  = val2 && mask1 >> 0xc; 
         val.t[9]  = val2 && mask2 >> 0x8; 
         val.t[10] = val2 && mask3 >> 0x4; 
         val.t[11] = val2 && mask4; 
         
         val.t[12] = val3 && mask1 >> 0xc; 
         val.t[13] = val3 && mask2 >> 0x8; 
         val.t[14] = val3 && mask3 >> 0x4; 
         val.t[15] = val3 && mask4; 
    		return val; 
	 }
	 else
    		printf("FATAL! File illegal"); 
}

uint8_t** load_image(uint32_t m, uint32_t n)  
{
    uint128_t local_line; 
	 uint8_t** input_image;
    	

	 input_image = (uint8_t**)malloc(sizeof(uint8_t*)*m);  	
	 if(!input_image)
	 	printf("Unable to allocate memory for image"); 	
	 for(int i = 0; i<m; i++)
	 {
        local_line = read_one_line(); 
    		*(input_image+i) = (uint8_t*)malloc(sizeof(uint8_t)*n); 
    		for(int j = 0; j< n; j++)
    		{
    			*(*(input_image+i) + j) = local_line.t[j]; 
    		}
	 }	

	 printf("image loaded successfully \n"); 
	 return input_image; 

}

uint32_t* draw_histogram(uint8_t** f, uint32_t l, uint32_t m, uint32_t n)
{
	 pFile_hist_wdata = fopen("hist_scratch_wdata.txt", "w"); 
	 pFile_hist_waddr = fopen("hist_scratch_waddr.txt", "w"); 
//  if(pFile_hist_wdata == NULL)
//  {
//      printf("File cannot be opened for histogram scoreboarding"); 
//  }
    uint32_t* h;
    uint32_t two_pow_l = (1<<l) -1 ;  
    uint32_t h_index ; 
    h = (uint32_t*)malloc(sizeof(uint32_t)*two_pow_l); 
    if(!h)
	 	printf("Unable to allocate memory for histogram"); 	
    for(int i = 0; i<m; i++)
	 {
    		*(f+i) = (uint8_t*)malloc(sizeof(uint32_t)*n); 
    		for(int j = 0; j< n; j++)
    		{
            h_index = *(*f+i)+j & two_pow_l; 
            if(h_index >= 1<<l)
                printf("FATAL Issue - due to h_index >= 2^l"); 
            (*(h + h_index)) ++ ; 

            fprintf(pFile_hist_waddr, "%d\n", (h_index/4); 
            //for scoreboarding
            if(h_index < 4)
            {
                fprintf(pFile_hist_wdata, "%x%x%x%x\n", *h, *(h+1), *(h+2), *(h+3));   
            } 
            else if (h_index % 4)
            {
                fprintf(pFile_hist_wdata, "%x%x%x%x\n", *(h+h_index),*(h+h_index+1),*(h+h_index+2),*(h+h_index+3));  
            } 
            else if ((h_index-1) % 4)
            {
                fprintf(pFile_hist_wdata, "%x%x%x%x\n", *(h+h_index-1),*(h+h_index),*(h+h_index+1),*(h+h_index+2));  
            }
            else if ((h_index-2) % 4)
            {
                fprintf(pFile_hist_wdata, "%x%x%x%x\n", *(h+h_index-2),*(h+h_index-1),*(h+h_index),*(h+h_index+1));  
            }
            else if ((h_index-3) % 4)
            {
                fprintf(pFile_hist_wdata, "%x%x%x%x\n", *(h+h_index-3),*(h+h_index-2),*(h+h_index-1),*(h+h_index));  
            }
    		}
    }
	 printf("histogram loaded successfully \n"); 
    fclose(pFile_hist_wdata); 
    fclose(pFile_hist_waddr); 
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

uint8_t** compute_output(uint32_t* cdf, uint8_t** input_image, uint32_t m, uint32_t n, uint32_t l)
{
    uint32_t cdf_min;  
    uint8_t input_image_local;  
    uint8_t** output_image; 
    uint32_t two_pow = l <<1;
    cdf_min = *(cdf + two_pow); 
    
    uint32_t factor = 0; 
    factor = (l-1)/((n-m)-cdf_min); 

	 output_image = (uint8_t**)malloc(sizeof(uint8_t*)*m);  	
	 if(!output_image)
	 	printf("Unable to allocate memory for output image"); 	

    for(int i = 0; i<m; i++)
	 {
    		*(output_image+i) = (uint8_t*)malloc(sizeof(uint8_t)*n); 
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
	 uint8_t **f = NULL; 
	 uint8_t **g = NULL; 
	 uint32_t *h = NULL; 
	 uint32_t *cdf = NULL; 
	 
    uint32_t cdf_min = 0;
	 
    //1. load image from file
  	 f = load_image(M, N); 
   
    //2. draw histogram 
    h = draw_histogram(f,l, 64, 4); //there are only 255 bins possible
    
    //3. calculate cdf
    cdf = compute_cdf(h,l);   
    cdf_min = *(cdf + two_pow); 

    //4. compute g
    g = compute_output(cdf, f, M, N, l); 
    return 0; 

}
