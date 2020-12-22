#include <iostream>
#include <fstream>
#include <string>
#include <map>
using namespace std;

int main() {
	map<string,int> mymap;
	string line, aux;
	char delim = '.';
	map<string,int>::iterator pos;

	ifstream myIfile("hostsClean.csv");

	if (myIfile.is_open()) {
		while (getline(myIfile,line)) {
			if (line.find(delim) != -1) {
				aux = line.substr(line.find_last_of(delim));
				aux = aux.substr(0, aux.size()-1);
				
				pos = mymap.find(aux);
				if (pos == mymap.end()) {
					mymap[aux] = 1;
				}
				else {
					mymap.at(aux) = pos->second +1;
				}
			}
		}
		myIfile.close();
		ofstream myOfile("res.txt");
		if (myOfile.is_open()) {
			for (auto const& x : mymap) {
				if (x.second > 10 && x.first.size() == 3) 
			    	myOfile << x.first << ':' << x.second << endl;
			}
			myOfile.close();
		}
		else cout << "Unable to open file output";
	}

	else cout << "Unable to open file input"; 
}
