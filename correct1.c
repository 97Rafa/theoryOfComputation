#include "pilib.h"

/* program */  

 
 
int main() {
 	writeString("##############################\n");
writeString("###   Triangle Generator   ###\n");
writeString("##############################\n\n\n");
int i, space, rows, k=0, count=0, res, res2, count1=0;
writeString("Enter the numbers of rows:\n");
rows = readInt();
for(i = 1; i <= rows; i = i + 1){
for(space = 1; space <= rows - i; space = space + 1){
writeString("  ");
 
}

while(k != 2 * i - 1){
if (count <= rows - 1) {
 res = i + k;
writeInt(res);
count = count + 1;
 
}
 else {
count1 = count1 + 1;
res2 = i + k - 2 * count1;
writeInt(res2);

}
k = k + 1;
 
}

count1 = 0;
count = 0;
k = 0;
writeString("\n");
 
}


return 0;

} 

/*Accepted!*/
