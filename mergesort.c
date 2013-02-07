/**********************************************************
* mergesort.c                                             *
*                                                         *
* This program sorts using a simple merge sort algorithm. *
* Written by Chris Copeland (chrisnc@stanford.edu)        *
**********************************************************/

#include "stdio.h"
#include "stdlib.h"

void Mergesort(int *array, int n, int *tempArray);
void Merge(int *array, int n, int *tempArray, int mid);
void ArrCpy(int *dst, int *src, int n);

int main() {
    int *nums, *tempArray, i, array_size;

    printf("How many elements to be sorted? ");
    scanf("%d", &array_size);

    nums = (int *) malloc(sizeof(int) * array_size);
    tempArray = (int *) malloc(sizeof(int) * array_size);

    for (i = 0; i < array_size; i++) {
        printf("Enter next element: ");
        scanf("%d", &(nums[i]));
    }

    Mergesort(nums, array_size, tempArray);

    printf("The sorted list is:\n");
    for (i = 0; i < array_size; i++)
        printf("%d ", nums[i]);
    printf("\n");
    free(nums);
    free(tempArray);
}

void Mergesort(int *array, int n, int *tempArray)
{
    if (n < 2)
        return;
    int mid = n/2;
    Mergesort(array, mid, tempArray);
    Mergesort(array + mid, n - mid, tempArray);
    Merge(array, n, tempArray, mid);
}

void Merge(int *array, int n, int *tempArray, int mid)
{
    int tpos = 0, lpos = 0, rpos = 0, rn = n - mid, *rarr = array + mid;
    while (lpos < mid && rpos < rn) {
        if (array[lpos] < rarr[rpos])
            tempArray[tpos] = array[lpos++];
        else
            tempArray[tpos] = rarr[rpos++];
        ++tpos;
    }
    if (lpos < mid)
        ArrCpy(tempArray + tpos, array + lpos, mid - lpos);
    if (rpos < rn)
        ArrCpy(tempArray + tpos, rarr + rpos, rn - rpos);
    ArrCpy(array, tempArray, n);
}

void ArrCpy(int *dst, int *src, int n) {
    int i;
    for (i = 0; i < n; ++i)
        dst[i] = src[i];
}
