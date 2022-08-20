#include <iostream>
#include <vector>
#include <string>
#include <random>
#include <time.h>
#include <fstream>

using namespace std;

vector<string> asentamientos;
vector<string> almacenes;
vector<string> personales;
vector<string> suministros;
vector<string> rovers;
vector<string> peticiones;
int nAsen, nAlm, nPers, nSum, nRover, nPet;
int ext, pond_prior, pond_dist;
bool minimizar = false;
string name;
string domain = "Rover";


vector<vector<bool> > create(){
  int tam = nAlm + nAsen;
  vector<vector<bool> > mat(tam, vector<bool>(tam, false));

  /*for (int i = 0; i < tam; ++i) {
    mat[0][i] = true;
    mat[tam-1][i] = true;
    mat[i][0] = true;
    mat[i][tam-1] = true;
  }*/

  // Por lo menos un ciclo que conecte todos los vertices
  int i = 1;
  int j = 0;
  while (i < tam && j < tam) {
    mat[i][j] = true;
    i++;
    j++;
  }
  mat[tam-1][0] = true;

  // path random
  for (int i = 0; i < tam; i++) {
    for (int j = 0; j < tam; j++) {
      if (rand()%2 == 0) {
        mat[i][j] = true;
      }
    }
  }
  return mat;
}

void write_header(string &s) {
  s += "(define (problem " + name + ") (:domain " + domain + ")" + "\n";
}

void write_object(string &s) {
  s += "(:objects\n";
  for (int i = 0; i < nAlm; i++) s += almacenes[i] + " ";
  s += "- almacen\n";

  for (int i = 0; i < nAsen; i++) s += asentamientos[i] + " ";
  s += "- asentamiento\n";

  for (int i = 0; i < nPers; i++) s += personales[i] + " ";
  s += "- personal\n";

  for (int i = 0; i < nSum; i++) s += suministros[i] + " ";
  s += "- suministro\n";

  for (int i = 0; i < nRover; i++) s += rovers[i] + " ";
  s += "- rover\n";

  for (int i = 0; i < nPet; i++) s += peticiones[i] + " ";
  s += "- id\n";

  if (ext == 3) s += "priorA priorB priorC  - id\n";

  s += ")\n";
}

void write_ini (string &s) {
  s += "(:init\n";

  int nPetSum = rand()%nPet;
  int nPetPers = nPet - nPetSum;

  //--------------Peticiones-----------------------
  for (int i = 0; i < nPetSum; i++){
    int randAsen = rand()%nAsen;
    s += "(petition_suministro " + asentamientos[randAsen] + " " + peticiones[i] + ")\n";
    if (ext == 3) s += "(= (cost_petition_suministro " + asentamientos[randAsen] + " " + peticiones[i] + ") " + to_string(rand()%3+1) + ")\n";
  }

  s += "\n";

  for (int i = nPetPers; i < nPet; i++){
    int randAsen = rand()%nAsen;
    s += "(petition_personal " + asentamientos[randAsen] + " " + peticiones[i] + ")\n";
    if (ext >= 3) s += "(= (cost_petition_personal " + asentamientos[randAsen] + " " + peticiones[i] + ") " + to_string(rand()%3+1) + ")\n";
  }

  s += "\n\n";

  //---------------At-----------------------------
  for (int i = 0; i < nSum; i++) {
    s += "(at " + suministros[i] + " " + almacenes[rand()%nAlm] + ")\n";
  }

  s += "\n";

  for (int i = 0; i < nPers; i++) {
    s += "(at " + personales[i] + " " + asentamientos[rand()%nAsen] + ")\n";
  }

  s += "\n";

  for (int i = 0; i < nRover; i++) {
    if (rand()%2 != 0) s += "(at " + rovers[i] + " " + asentamientos[rand()%nAsen] + ")\n";
    else s += "(at " + rovers[i] + " " + almacenes[rand()%nAlm] + ")\n";
  }

  s += "\n\n";

  //------------Ini rover capacity-----------------
  if (ext >= 1) {
    for (int i = 0; i < nRover; i++) {
      s += "(= (number_personal " + rovers[i] + ") 0)\n";
      s += "(= (number_suministro " + rovers[i] + ") 0)\n";
    }
  }

  //------------------Fuel--------------------------
  if (ext >= 2) {
    for (int i = 0; i < nRover; i++) {
      int fuel = rand()%100;
      s += "(= (fuel " + rovers[i] + ") " + to_string(fuel) + ")\n";
    }
    s += "(= (total_fuel_used) 0)";
    s += "(= (total_petition_score) 0)";
  }

  //--------------------path.........................
  vector<vector<bool> > mat = create();
  int tam = mat.size();
  for (int i = 0; i < tam; ++i) {
    for (int j = 0; j < i; ++j) {
      if (mat[i][j]) {
        s += "(path ";
        if (i < nAlm) s += almacenes[i] + " ";
        else s += asentamientos[i-nAlm] + " ";
        if (j < nAlm) s += almacenes[j] + ")\n";
        else  s += asentamientos[j-nAlm] + ")\n";
      }
    }
  }

  s += ")";

}


void write_goal(string &s) {
  s += "(:goal\n";
  s += "  (and\n";
  for (int i = 0; i < nSum; i++) s += "   (delivered " + suministros[i] + ")\n";
  for (int i = 0; i < nPers; i++) s += "   (delivered " + personales[i] + ")\n";
  s += "  )\n";
  s += ")\n";
}

void write_metric(string &s) {
  if (ext >= 3) {
    if (minimizar) s += "(:metric maximize (- (*" + to_string(pond_prior) + " (total_petition_score)) (*" + to_string(pond_dist) + " (total_fuel_used))))\n";
    else s +=  "(:metric maximize (total_petition_score))\n";
  }
  else if (minimizar) s += "(:metric minimize (total_fuel_used))\n";
}


int main() {

  string content = "";
  srand(time(NULL));

  cout << "Que nombre quieres ponerle al fichero de salida?" << endl;
  cin >> name;

  cout << "Que extension del problema quieres? [0,3]" << endl;
  cin >> ext;
  while (ext < 0 or ext > 3) {
    cout << "Extension erronea, introduce de nuevo\n";
    cin >> ext;
  }

  if (ext >= 2) {
    int opt;
    cout << "Introduce:\n 0. No minimizar\n 1. Minimizar\n";
    cin >> opt;
    if (opt == 1) minimizar = true;
  }

  cout << "Quantos asentamientos quieres?\n";
  cin >> nAsen;

  cout << "Quantos almacenes quieres?\n";
  cin >> nAlm;

  cout << "Quantos personales en total quieres?\n";
  cin >> nPers;

  cout << "Quantos suministros quieres?\n";
  cin >> nSum;

  cout << "Quantos rovers quieres?\n";
  cin >> nRover;

  cout << "Quantas peticiones en total quieres (tiene que ser mayor que la suma de suministros y personales)?\n";
  cin >> nPet;
  while (nPet < nSum + nPers) {
    cout << "El numero de perticiones ha de ser superior a la suma de personles mas suministros, introduce de nuevo" << endl;
    cin >> nPet;
  }

  if (ext >= 3 && minimizar) {
    cout << "Introduce la importancia de la prioridad de peticiones\n";
    cin >> pond_prior;
    cout << "Introduce la importancia de la minimizacion de distancias (para ahorrar combustible)\n";
    cin >> pond_dist;
  }

  cout << "Generando el fichero " << name << ", espere por favor..." << endl;

  asentamientos = vector<string>(nAsen);
  for (int i = 0; i < nAsen; i++){
    asentamientos[i] = "as" + to_string(i);
  }

  almacenes = vector<string>(nAlm);
  for (int i = 0; i < nAlm; i++){
    almacenes[i] = "al" + to_string(i);
  }

  personales = vector<string>(nPers);
  for (int i = 0; i < nPers; i++){
    personales[i] = "p" + to_string(i);
  }

  suministros = vector<string>(nSum);
  for (int i = 0; i < nSum; i++){
    suministros[i] = "s" + to_string(i);
  }

  rovers = vector<string>(nRover);
  for (int i = 0; i < nRover; i++){
    rovers[i] = "r" + to_string(i);
  }

  peticiones = vector<string>(nPet);
  for (int i = 0; i <  nPet; i++){
    peticiones[i] = "pet" + to_string(i);
  }

  write_header(content);
  write_object(content);
  write_ini(content);
  write_goal(content);
  write_metric(content);
  content += ")";

  ofstream file (name + "_" + to_string(ext) + ".pddl");
  if (file.is_open()){
    file << content;
    file.close();
    cout << "Fichero " + name + ".pddl creado correctamente\n";
  }
  else cout << "Error al crear el juego de prueba" << endl;

}
