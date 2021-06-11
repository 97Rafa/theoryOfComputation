#include "pilib.h"

/* program */  

 
 
int add(int x1, int x2) {int r=0;
r = x1 + x2;

return r;

}

int sub(int x1, int x2) {int r=0;
r = x1 - x2;

return r;

}

int mul(int x1, int x2) {int r=0;
r = x1 * x2;

return r;

}

int divis(int x1, int x2) {int r=0;
r = x1 / x2;

return r;

}

int main() {
 	int x, y, res=0;
int op;
writeString("#######################\n");
writeString("###  iCalculator    ###\n");
writeString("#######################\n\n\n");
writeString("Please enter an integer:\n");
x = readInt();
writeString("..aaand another one please:\n");
y = readInt();
writeString("What operation would you like to do?\n1: Addition\n2: Substraction\n3: Multiplication\n4: Division\n");
op = readInt();
if (op == 1) {
 res = add(x, y);
 
}
 else if (op == 2) {
 res = sub(x, y);
 
}
 else if (op == 3) {
 res = mul(x, y);
 
}
 else if (op == 4) {
 res = divis(x, y);
 
}
 else {
writeString("There is no such an operation.\n");

return;

}
writeString("The Result of the Operation is: ");
writeInt(res);
writeString("\n");

} 

/*Accepted!*/
