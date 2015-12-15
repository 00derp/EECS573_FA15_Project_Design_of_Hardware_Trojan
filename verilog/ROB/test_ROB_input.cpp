#include <iostream>
#include <string>

using namespace std;

int main(int argc, char const *argv[])
{
	while(1) {
		cout << "    @(negedge clock);\n";
		cout << "    $display(\"ROB_ARF_num_out = %h, ROB_PRF_num_out = %h, ROB_NPC_out = %h, ROB_branch_mispredict_out = %h, ROB_is_store_inst_out = %b, ROB_is_branch_inst_out = %b, ROB_commit_out = %b, ROB_ROB_num_out = %h, ROB_dispatch_disable = %b, ROB_is_full_out = %b, ROB_head = %h, ROB_tail = %h, full = %b, wr_en = %b\", ROB_ARF_num_out, ROB_PRF_num_out, ROB_NPC_out, ROB_branch_mispredict_out, ROB_is_store_inst_out, ROB_is_branch_inst_out, ROB_commit_out, ROB_ROB_num_out, ROB_dispatch_disable, ROB_head, ROB_tail, full, wr_en, \"\");" << endl;
		for (int i=0; i < 11; i++) {
			string input;
			cin >> input;
			if (input == "end")
				return 0;
			switch (i%11) {
				case 0:
				  //cout << setw(30);
				  cout << "    id_rs_valid_inst_in      = ";
				  cout << input << ";" << endl;
				  break;
				case 1:
				  //cout << setw(30);
				  cout << "    id_rs_ARF_num_in         = ";
				  cout << input << ";" << endl;
				  break;
				case 2:
				  //cout << setw(30);
				  cout << "    id_rs_PRF_num_in         = ";
				  cout << input << ";" << endl;
				  break;
				case 3:
				  //cout << setw(30);
				  cout << "    id_rs_is_branch_inst_in  = ";
				  cout << input << ";" << endl;
				  break;
				case 4:
				  //cout << setw(30);
				  cout << "    id_rs_is_store_inst_in   = ";
				  cout << input << ";" << endl;
				  break;
				case 5:
				  //cout << setw(30);
				  cout << "    ex_NPC_in                = ";
				  cout << input << ";" << endl;
				  break;
				case 6:
				  //cout << setw(30);
				  cout << "    ex_branch_mispredict_in  = ";
				  cout << input << ";" << endl;
				  break;
				case 7:
				  //cout << setw(30);
				  cout << "    ex_branch_inst_in        = ";
				  cout << input << ";" << endl;
				  break;
				case 8:
				  cout << "    ex_store_inst_in         = ";
				  cout << input << ";" << endl;
				  break;
				case 9:
				  //cout << setw(30);
				  cout << "    ex_ROB_num_in            = ";
				  cout << input << ";" << endl;
				  break;
				case 10:
				  //cout << setw(30);
				  cout << "    CDB_tag_in               = ";
				  cout << input << ";" << endl << endl << endl;
				  break;
			}
		}
    }
	return 0;
}