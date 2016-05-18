#include <stdint.h>
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <math.h>
using namespace std; 

typedef struct uint128_type
{
    uint8_t t[16];
}uint128_t; 

//globals
FILE *pFile; 
FILE *pFile_hist_waddr; 
FILE *pFile_hist_wdata; 
FILE *pFile_cdf_waddr; 
FILE *pFile_cdf_wdata; 
FILE *pFile_divider_scratch_wdata; 
FILE *pFile_divider_scratch_waddr; 
FILE *pFile_divider_output_wdata; 
FILE *pFile_divider_output_waddr; 
FILE *pFile_scratchmem_dump_for_divider; 
FILE *pFile_scratchmem_dump_for_cdf; 

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

uint8_t conv2hex(char c)
{
   switch(c)
   {
           case '0' : return 0;          
           case '1' : return 1;          
           case '2' : return 2;          
           case '3' : return 3;          
           case '4' : return 4;          
           case '5' : return 5;          
           case '6' : return 6;          
           case '7' : return 7;          
           case '8' : return 8;          
           case '9' : return 9;          
           case 'A' : return 10;          
           case 'B' : return 11;          
           case 'C' : return 12;          
           case 'D' : return 13;          
           case 'E' : return 14;          
           case 'F' : return 15;          
           default : printf("input image not in format"); return 0;  
   } 
}
uint128_t read_one_line()
{
	 uint128_t val; 
    
    //reading 32 hexa decimal value in a line - memory width is 128 bits 
    for(int i = 0; i<= 16; i++)
    {
        char get_a = (char)getc(pFile); 

        if(get_a == '\n')
        {
            printf("\n"); 
            return val; 
        }
        else
        {
            char get_b = (char)getc(pFile); 
            val.t[i] = (conv2hex(get_a))<<4 | conv2hex(get_b); 
            printf("%02x", val.t[i]); 
        }
    }

}

uint8_t** load_image(uint32_t m, uint32_t n)  
{
    uint128_t local_line; 
	 uint8_t** input_image;
    	

	 input_image = (uint8_t**)malloc(sizeof(uint8_t*)*n);  	
	 if(!input_image)
	 	printf("Unable to allocate memory for image"); 	
	 for(int i = 0; i<n; i++)
	 {
        local_line = read_one_line(); 
    		*(input_image+i) = (uint8_t*)malloc(sizeof(uint8_t)*m); 
    		for(int j = 0; j< m; j++)
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

    for (int i = 0 ; i < two_pow_l; i++)
            *(h+i) = 0; 
    printf("histogram---------");
    for(int i = 0; i<n; i++)
	 {
         printf("\n"); 
    	 for(int j = m-1; j>=0; j--)
    	 {
            uint8_t offset_temp; 
            uint8_t waddr_in_memory; 

            h_index = *(*(f+i)+j) & two_pow_l; 
            offset_temp  = ((h_index) & 3); 

            printf("%d ", h_index); 
            if(h_index >= 1<<l)
                printf("FATAL Issue - due to h_index >= 2^l"); 
            *(h + h_index) = *(h + h_index) + 1 ; 

		
          //printf("offset_Temp = %0d\n", offset_temp); 
          //printf("h_index/4 = %0d\n", h_index/4); 
            waddr_in_memory = (h_index>>2); 
            fprintf(pFile_hist_waddr, "%d\n", waddr_in_memory); 

            
          //printf("offset = %x\n", offset_temp); 
            //for scoreboarding

            if(offset_temp == 0)
            { 
              //fprintf(pFile_hist_wdata,"0 h_index>>2 = %x ", h_index>>2); 
                fprintf(pFile_hist_wdata, "%032x%032x%032x%032x\n", *(h+(h_index)),*(h+(h_index)+1),*(h+(h_index)+2),*(h+(h_index)+3));  
            } 
            else if(offset_temp == 1)
            {
                fprintf(pFile_hist_wdata, "%032x%032x%032x%032x\n", *(h+(h_index)-1),*(h+(h_index)),*(h+(h_index)+1),*(h+(h_index)+2));  
            }
            else if(offset_temp == 2)
            {
                fprintf(pFile_hist_wdata, "%032x%032x%032x%032x\n", *(h+h_index-2),*(h+h_index-1),*(h+h_index),*(h+h_index+1));  
            }
            else if(offset_temp == 3)
            {
                fprintf(pFile_hist_wdata, "%032x%032x%032x%032x\n", *(h+(h_index-3)),*(h+(h_index-2)),*(h+(h_index-1)),*(h+h_index));  
            }
    		}
    }
	 printf("\nhistogram loaded successfully \n"); 
    fclose(pFile_hist_wdata); 
    fclose(pFile_hist_waddr); 
    return h;  
}

uint32_t* compute_cdf(uint32_t* h, uint32_t l)
{
	 pFile_cdf_wdata = fopen("cdf_scratch_wdata.txt", "w"); 
	 pFile_cdf_waddr = fopen("cdf_scratch_waddr.txt", "w"); 
    pFile_scratchmem_dump_for_cdf = fopen("scratchmem_dump_for_cdf.txt", "w"); 
    pFile_scratchmem_dump_for_divider = fopen("scratchmem_dump_for_divider.txt", "w"); 

    uint32_t* cdf;
    uint32_t min = 55555;
    uint8_t waddr_in_memory; 
    
    uint32_t two_pow_l = (1<<l) -1 ;  
    cdf = (uint32_t*)malloc(sizeof(uint32_t)*(two_pow_l+1)); 

    if(!cdf)
	 	printf("Unable to allocate memory for histogram"); 	


    for(int i = 0; i <= two_pow_l; i++)
    {
        if(i) 
            *(cdf + i) = *(cdf+i - 1) + *(h+i);  
        else
            *(cdf) = *h;  
        waddr_in_memory = i / 4;  
        fprintf(pFile_cdf_waddr, "%032x\n", waddr_in_memory); 
        fprintf(pFile_cdf_wdata, "%032x\n", *(cdf + i)); 

        //find min
            if(*(cdf+i) < min && *(cdf+i) > 0)
                min = *(cdf + i);  
    } 
    *(cdf + (l<<1)) = min; 

    fprintf(pFile_cdf_wdata, "%d\n", *(cdf + (l<<1))); 
   
    printf("tow_pow_l/4 = %d", (two_pow_l)); 
    printf("min [cdf_compute]= %d", (min)); 
    printf("two_pow_l + 1 /4 = %d", (two_pow_l+1)/4); 

 // printf("hisotgrammmm------"); 
 // for(int j = 0 ; j < two_pow_l + 1; j++)
 //     printf("%08x\n", *(h+j));
 // printf("------------------"); 

    int i,j; 
    for( i = 0,  j = 0; i< (two_pow_l+1)/4; i = i + 1, j = j + 4)
    {
      //printf("hist i %d\n",i);
        fprintf(pFile_scratchmem_dump_for_cdf, "%08x%08x%08x%08x\n", *(h +j), *(h+j+1), *(h+j+2), *(h+j+3) ); 
        fprintf(pFile_scratchmem_dump_for_divider, "%08x%08x%08x%08x\n", *(h +j), *(h+j+1), *(h+j+2), *(h+j+3) ); 
    }
    for(i=0, j = 0; i< (two_pow_l+1)/4; i++, j = j + 4)
    {
        fprintf(pFile_scratchmem_dump_for_divider, "%08x%08x%08x%08x\n", *(cdf +j), *(cdf+j+1), *(cdf+j+2), *(cdf+j+3) ); 
    }
	 printf("cdf computed successfully \n"); 
    fclose(pFile_cdf_wdata); 
    fclose(pFile_cdf_waddr); 
    fclose(pFile_scratchmem_dump_for_divider); 
    fclose(pFile_scratchmem_dump_for_cdf); 
    return cdf; 
}

uint8_t** compute_output(uint32_t* cdf, uint8_t** input_image, uint32_t m, uint32_t n, uint32_t l, uint32_t cdf_min)
{
	 pFile_divider_scratch_wdata = fopen("divider_scratch_wdata.txt", "w"); 
	 pFile_divider_scratch_waddr = fopen("divider_scratch_waddr.txt", "w"); 

    uint8_t input_image_local;  
    uint8_t** output_image; 
    uint8_t* cdf_order_output_image; 
    uint32_t two_pow = 1 <<l;
    
    float factor = 1.0; 
    factor = (float)(two_pow-1)/((n*m)-cdf_min); 

	 output_image = (uint8_t**)malloc(sizeof(uint8_t*)*n);  	
    cdf_order_output_image  = (uint8_t*)malloc(sizeof(uint8_t)*two_pow); 

    printf("two pow = %d\n", two_pow-1); 
    printf("l = %d\n", l); 
    printf("two pow - 1 = %d\n", two_pow-1); 
    printf("cdf_min = %d\n", cdf_min); 
    printf("n*m -cdf_min = %d\n", n*m-cdf_min); 
    printf("factor = %32.32f\n", factor); 
	 if(!output_image)
	 	printf("Unable to allocate memory for output image"); 

	 if(!cdf_order_output_image)
	 	printf("Unable to allocate memory for cdf_order_output_image image"); 

    //for scoreboarding------------------------------------------------------------------------------

    for(int i=0; i< two_pow; i++)
        *(cdf_order_output_image + i) = 0; 

    for(int i=0; i< two_pow; i++)
    {
        *(cdf_order_output_image + i) = (floor) ((*(cdf+i) - cdf_min)*factor);   
        if(i % 4 == 3)
        {
            fprintf(pFile_divider_scratch_wdata, "%08x%08x%08x%08x\n", *(cdf_order_output_image+i-3),*(cdf_order_output_image+i-2),*(cdf_order_output_image+i-1),*(cdf_order_output_image+i));  
           fprintf(pFile_divider_scratch_waddr, "%032x\n", i/4); 
        } 
        

    }
    //-----------------------------------------------------------------------------------------------

    for(int i = 0; i<n; i++)
	 {
        *(output_image+i) = (uint8_t*)malloc(sizeof(uint8_t)*m); 
    		for(int j = 0; j< m; j++)
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


    
	 uint32_t l = 8;
	 uint32_t two_pow = l<<1;
	 uint8_t **f = NULL; 
	 uint8_t **g = NULL; 
	 uint32_t *h = NULL; 
	 uint32_t *cdf = NULL; 
	 
    uint32_t cdf_min = 0;
	 
    //1. load image from file
  	 f = load_image(M, N); 
   
    //2. draw histogram 
    h = draw_histogram(f,l, M, N); //there are only 255 bins possible
    
    //3. calculate cdf
    cdf = compute_cdf(h,l);   
    cdf_min = *(cdf + two_pow); 

    //4. compute g
    g = compute_output(cdf, f, M, N, l, cdf_min); 
    return 0; 

}
