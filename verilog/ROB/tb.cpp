#include <iostream>
#include <string>

using namespace std;

int main(int argc, char const *argv[]) {
	string input;
	for (int i = 0; i < 54; i++) {
		cout << "func_check(";
		for (int j = 0; j < 13; j++) {
		    cin >> input >> input >> input;
		    switch (j) {
		    	case 0:
		    	    cout << "5'h";
		    	    break;
                case 1:
                    cout << "6'h";
                    break;
                case 2:
                    cout << "64'h";
                    break;
                case 3:
                    cout << "1'b";
                    break;
                case 4:
                    cout << "1'b";
                    break;
                case 5:
                    cout << "1'b";
                    break;
                case 6:
                    cout << "1'b";
                    break;
                case 7:
                    cout << "5'h";
                    break;
                case 8:
                    cout << "1'b";
                    break;
                case 9:
                    cout << "5'h";
                    break;
                case 10:
                    cout << "5'h";
                    break;
                case 11:
                    cout << "1'b";
                    break;
                case 12:
                    cout << "1'b";
                    break;
		    }
            cout << input << " ";
	    }
	    cout << ",\"\");\n//" << i << "\n";
	}
}