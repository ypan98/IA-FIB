
import IA.Energia.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class State {
    
    
    public static Cliente[] clientes;
    public static Central[] centrales;
    public int [] centralAssig;
    
    public int [] nClientesCentrales;
    public double [] WGastadaCentrales;
    public double ganancia;
    public double penalizacion;
    public int val = 500; //valor que penalizamos cada vez que no se cumpla las restricciones
    public double potenciaSobrada; 
    
    
    
    public State (Clientes clientesIni, Centrales centralesIni, int seed) throws Exception {  
        
        Random rnd = new Random(seed);
        nClientesCentrales = new int [centralesIni.size()];
        for (int i = 0; i < nClientesCentrales.length; ++i) nClientesCentrales[i] = 0;
        WGastadaCentrales = new double [centralesIni.size()];
        for (int i = 0; i < WGastadaCentrales.length; ++i) WGastadaCentrales[i] = 0;
        centralAssig = new int [clientesIni.size()];
        for (int i = 0; i < centralAssig.length; ++i) centralAssig[i] = -1; //Todos los clientes a -1
        ganancia = 0;
        penalizacion = 0;
        potenciaSobrada = 0;
        clientes = new Cliente[clientesIni.size()];
        centrales = new Central[centralesIni.size()];
        for (int i = 0; i < clientesIni.size(); ++i){
            clientes[i] = clientesIni.get(i);
        }
        for (int i = 0; i < centralesIni.size(); ++i){
            centrales[i] = centralesIni.get(i);
        }
        //Estado inicial
                   
        List<Integer> pool = IntStream.range(0, centrales.length).boxed().collect(Collectors.toList());
        

        //estrategia 1: distribuimos todos los clientes garantizados equitativamente sobre todas las centrales

        
        for(int i = 0 ; i < this.clientes.length; ++i){
            Cliente curr_client = clientes[i];    
            if (curr_client.getContrato() == Cliente.GARANTIZADO) {
                Collections.shuffle(pool, rnd);
                for(int c: pool){
                    if (WGastadaCentrales[c] + consumoCentral(i,c) <= centrales[c].getProduccion()){
                        centralAssig[i] = c;
                        ++nClientesCentrales[c];
                        WGastadaCentrales[c] += consumoCentral(i,c);
                        break;
                    }
                }
            }
        }
        

        /*//estrategia 2: distribuimos todos los clientes garantizados equitativamente sobre todas las centrales y despues los no garantizados
        
         for(int i = 0 ; i < this.clientes.length; ++i){
            Cliente curr_client = clientes[i];    
            if (curr_client.getContrato() == Cliente.GARANTIZADO) {
                Collections.shuffle(pool, rnd);
                for(int c: pool){
                    if (WGastadaCentrales[c] + consumoCentral(i,c) <= centrales[c].getProduccion()){
                        centralAssig[i] = c;
                        ++nClientesCentrales[c];
                        WGastadaCentrales[c] += consumoCentral(i,c);
                        break;
                    }
                }
            }
        }
        
        for(int i = 0 ; i < this.clientes.length; ++i){
            Cliente curr_client = clientes[i];    
            if (curr_client.getContrato() == Cliente.NOGARANTIZADO) {
                Collections.shuffle(pool, rnd);
                for(int c: pool){
                    if (WGastadaCentrales[c] + consumoCentral(i,c) <= centrales[c].getProduccion()){
                        centralAssig[i] = c;
                        ++nClientesCentrales[c];
                        WGastadaCentrales[c] += consumoCentral(i,c);
                        break;
                    }
                }
            }
        }*/
        
        /* //estrategia 3: recorremos sobre el vector de centrales de forma ordenada pero reordenando previamente el vector de centrales al principio, llenamos uno y vamos al siguiente solamente para clientes garantizados
        Collections.shuffle(pool, rnd);
        for(int i = 0 ; i < this.clientes.length; ++i){
            Cliente curr_client = clientes[i];    
            if (curr_client.getContrato() == Cliente.GARANTIZADO) {
                for(int c: pool){
                    if (WGastadaCentrales[c] + consumoCentral(i,c) <= centrales[c].getProduccion()){
                        centralAssig[i] = c;
                        ++nClientesCentrales[c];
                        WGastadaCentrales[c] += consumoCentral(i,c);
                        break;
                    }
                }
            }
        }*/
        
        /*// estrategia 4: recorremos sobre el vector de centrales de forma ordenada pero reordenando previamente el vector de centrales al principio, llenamos uno y vamos al siguiente para todos los clientes
        
        Collections.shuffle(pool, rnd);
        for(int i = 0 ; i < this.clientes.length; ++i){
            Cliente curr_client = clientes[i];    
            if (curr_client.getContrato() == Cliente.GARANTIZADO) {
                for(int c: pool){
                    if (WGastadaCentrales[c] + consumoCentral(i,c) <= centrales[c].getProduccion()){
                        centralAssig[i] = c;
                        ++nClientesCentrales[c];
                        WGastadaCentrales[c] += consumoCentral(i,c);
                        break;
                    }
                }
            }
        }
        for(int i = 0 ; i < this.clientes.length; ++i){
            Cliente curr_client = clientes[i];    
            if (curr_client.getContrato() == Cliente.NOGARANTIZADO) {
                for(int c: pool){
                    if (WGastadaCentrales[c] + consumoCentral(i,c) <= centrales[c].getProduccion()){
                        centralAssig[i] = c;
                        ++nClientesCentrales[c];
                        WGastadaCentrales[c] += consumoCentral(i,c);
                        break;
                    }
                }
            }
        }*/
        
            
                
        for(int i = 0; i < this.clientes.length; ++i){
            Cliente curr_client = clientes[i];
            if (centralAssig[i] == -1){
                if (curr_client.getContrato() == Cliente.GARANTIZADO) {
                    /*System.out.println("No se han podido asignar todos los clientes garantizados");
                    System.exit(0);*/
                    penalizacion += val;
                }else{
                    ganancia -= VEnergia.getTarifaClientePenalizacion(curr_client.getTipo()) * curr_client.getConsumo();
                }
            }else{
                Central curr_central = centrales[centralAssig[i]];
                 if (curr_client.getContrato() == Cliente.GARANTIZADO) {
                    double tarifaPorW = VEnergia.getTarifaClienteGarantizada(curr_client.getTipo());
                    ganancia += curr_client.getConsumo()*tarifaPorW;
                }
                else {
                    double tarifaPorW = VEnergia.getTarifaClienteNoGarantizada(curr_client.getTipo());
                    ganancia += curr_client.getConsumo()*tarifaPorW;
                }
            }
        }
        
        for(int c = 0; c < this.centrales.length; ++c){
            if(nClientesCentrales[c] == 0){
                ganancia -= VEnergia.getCosteParada(centrales[c].getTipo());
            }else{
                ganancia -= VEnergia.getCosteMarcha(centrales[c].getTipo()) + VEnergia.getCosteProduccionMW(centrales[c].getTipo()) * centrales[c].getProduccion();
                potenciaSobrada += centrales[c].getProduccion()-WGastadaCentrales[c];
            }  
        }
        
    }

    double consumoCentral(int i , int c){
        if (c == -1)
            return 0.0d;
        Cliente cliente = clientes[i];
        Central central = centrales[c];
        double dist = Math.hypot(cliente.getCoordX()- central.getCoordX(), cliente.getCoordY() - central.getCoordY());
        double perdida = VEnergia.getPerdida(dist);
        return cliente.getConsumo()*(1 + perdida);
    }

    
    /*  pre: si clientes[i] es garantizado entonces j no es -1 y al asignar clientes[i] a centrales[j] no se supera la maxima potencia que genera este.
        post: el cliente con indice i, se mueve a la central j. Actualizando los atributos de la clase*/
    void mover(int i, int c) throws Exception {  
        Cliente curr_client = clientes[i];
 
        // desasignamos
       if (centralAssig[i] != -1) {  
           Central curr_central = centrales[centralAssig[i]];
            //potenciaGenerada -= consumoCentral(i, centralAssig[i]);
            double tarifaPorW;
            if (curr_client.getContrato() == Cliente.GARANTIZADO) tarifaPorW = VEnergia.getTarifaClienteGarantizada(curr_client.getTipo());
            else tarifaPorW = VEnergia.getTarifaClienteNoGarantizada(curr_client.getTipo());
            ganancia -= curr_client.getConsumo()*tarifaPorW;
            WGastadaCentrales[centralAssig[i]] -=  consumoCentral(i, centralAssig[i]);
            potenciaSobrada += consumoCentral(i, centralAssig[i]);
            --nClientesCentrales[centralAssig[i]];
            // si la central se queda parado
            if (nClientesCentrales[centralAssig[i]] == 0){
                ganancia -= VEnergia.getCosteParada(curr_central.getTipo());
                potenciaSobrada -= curr_central.getProduccion();
                ganancia += VEnergia.getCosteMarcha(curr_central.getTipo()) + VEnergia.getCosteProduccionMW(curr_central.getTipo()) * curr_central.getProduccion();
            }
       }else{
            ganancia += VEnergia.getTarifaClientePenalizacion(curr_client.getTipo()) * curr_client.getConsumo();
       }
       // asignamos
       if (c != -1) {
            Central new_central = centrales[c];
            double tarifaPorW;
            if (curr_client.getContrato() == Cliente.GARANTIZADO) tarifaPorW = VEnergia.getTarifaClienteGarantizada(curr_client.getTipo());
            else tarifaPorW = VEnergia.getTarifaClienteNoGarantizada(curr_client.getTipo());
            ganancia += curr_client.getConsumo()*tarifaPorW;
            WGastadaCentrales[c] +=  consumoCentral(i, c);
            potenciaSobrada -= consumoCentral(i, c);
           // si la central se pone en marcha
            if (nClientesCentrales[c] == 0){
                ganancia += VEnergia.getCosteParada(new_central.getTipo());
                potenciaSobrada += new_central.getProduccion();
                ganancia -= VEnergia.getCosteMarcha(new_central.getTipo()) + VEnergia.getCosteProduccionMW(new_central.getTipo()) * new_central.getProduccion();
            }
            ++nClientesCentrales[c];
       }else{
            ganancia -= VEnergia.getTarifaClientePenalizacion(curr_client.getTipo()) * curr_client.getConsumo();
       }
       centralAssig[i] = c;
    }
    
    /*  pre: true.
        post: el cliente con indice i, se mueve a la central j. Actualizando los atributos de la clase*/
    void moverNSol(int i, int c) throws Exception {  
        Cliente curr_client = clientes[i];
 
        // desasignamos
       if (centralAssig[i] != -1) {  
           Central curr_central = centrales[centralAssig[i]];
            double tarifaPorW;
            if (curr_client.getContrato() == Cliente.GARANTIZADO) tarifaPorW = VEnergia.getTarifaClienteGarantizada(curr_client.getTipo());
            else tarifaPorW = VEnergia.getTarifaClienteNoGarantizada(curr_client.getTipo());
            ganancia -= curr_client.getConsumo()*tarifaPorW;
            WGastadaCentrales[centralAssig[i]] -=  consumoCentral(i, centralAssig[i]);
            potenciaSobrada += consumoCentral(i, centralAssig[i]);
            --nClientesCentrales[centralAssig[i]];
            // si la central se queda parado
            if (nClientesCentrales[centralAssig[i]] == 0){
                ganancia -= VEnergia.getCosteParada(curr_central.getTipo());
                potenciaSobrada -= curr_central.getProduccion();
                ganancia += VEnergia.getCosteMarcha(curr_central.getTipo());
            }
       }else{
            ganancia += VEnergia.getTarifaClientePenalizacion(curr_client.getTipo());
            if(clientes[i].getContrato() == Cliente.GARANTIZADO){
            penalizacion -= val;
            }
       }
       
       // asignamos
       if (c != -1) {
            Central new_central = centrales[c];
            double tarifaPorW;
            if (curr_client.getContrato() == Cliente.GARANTIZADO) tarifaPorW = VEnergia.getTarifaClienteGarantizada(curr_client.getTipo());
            else tarifaPorW = VEnergia.getTarifaClienteNoGarantizada(curr_client.getTipo());
            ganancia += curr_client.getConsumo()*tarifaPorW;
            if (new_central.getProduccion() < WGastadaCentrales[c] + consumoCentral(i, c)) penalizacion += val;
            WGastadaCentrales[c] +=  consumoCentral(i, c);
            potenciaSobrada -= consumoCentral(i, c);
           // si la central se pone en marcha
            if (nClientesCentrales[c] == 0){
                ganancia += VEnergia.getCosteParada(new_central.getTipo());
                potenciaSobrada += new_central.getProduccion();
                ganancia -= VEnergia.getCosteMarcha(new_central.getTipo());

            }
            ++nClientesCentrales[c];
       }else{
            ganancia -=VEnergia.getTarifaClientePenalizacion(curr_client.getTipo());
            if(clientes[i].getContrato() == Cliente.GARANTIZADO){
            penalizacion += val;
            }
       }
       centralAssig[i] = c;
    }

     /*  pre: true 
        post: indica si se ha realizado el intercambio de centrales de los 2 clientes*/
    Boolean intercambio(int i , int j)  throws Exception{     
         
        // mirar si los clientes estan en centrales diferentes, y no desasignamos (central -1) a un cliente garantizado  
        
        if (centralAssig[i] == centralAssig[j] || centralAssig[i] == -1 && clientes[j].getContrato() == Cliente.GARANTIZADO || //si son iguales pueden estar mas cercanos al intercambiar
                centralAssig[j] == -1 && clientes[i].getContrato() == Cliente.GARANTIZADO)
                return false;
        else{
            
              /*Todos los clientes garantizados estan asignados a una central, y eso lo mantenemos siempre. Por lo tanto a este punto curr_client y other_client,
                o estan todos asignados una central o bien ambos son no garantizados, hace falta ver que el garantizado al asignarlo no supere la potencia maxima de la central*/ 
              
             if (centralAssig[i] != -1) {
                if (/*other_client.getContrato() == Cliente.GARANTIZADO &&*/ //estas asignando un cliente no garantizado cuando no cubres toda la demanda de este por lo tanto no es solución 
                    centrales[centralAssig[i]].getProduccion() < WGastadaCentrales[centralAssig[i]] - consumoCentral(i, centralAssig[i]) + consumoCentral(j, centralAssig[i])) 
                    return false;
             }
             if (centralAssig[j] != -1) {
                if (/*curr_client.getContrato() == Cliente.GARANTIZADO && */ // lo mismo que arriba, o asignas o les pagas la indemnización no puedes asignarlos si no les das su demanda
                    centrales[centralAssig[j]].getProduccion() < WGastadaCentrales[centralAssig[j]] - consumoCentral(j, centralAssig[j]) + consumoCentral(i, centralAssig[j])) 
                    return false;
             }
        }
        int aux = centralAssig[i];
        mover(i, centralAssig[j]);
        mover(j, aux);
        return true;
    }
      
    
    /* pre: true
      post: indica si se ha movido el cliente i a la central c */
    Boolean cambio(int i, int c) throws Exception{   //asignar cliente i a la central c
        Cliente curr_client = clientes[i];
        if (centralAssig[i] == c) return false;
        if (c == -1){
            if (curr_client.getContrato() == Cliente.GARANTIZADO) return false;
        }
        else {
            if (centrales[c].getProduccion() < WGastadaCentrales[c] + consumoCentral(i, c)) return false;
        }
        mover(i,c);
        return true;
    }
    
    /* pre: true
      post: indica si se ha movido el cliente i a la central c */
    Boolean cambioNSol(int i, int c) throws Exception{   
        if (centralAssig[i] == c) return false;
        moverNSol(i,c);
        return true;
    }
   
    // hacer copias
    public State (State _state) {
        nClientesCentrales = new int[_state.nClientesCentrales.length];
        System.arraycopy(_state.nClientesCentrales, 0, nClientesCentrales, 0, nClientesCentrales.length) ;
        WGastadaCentrales = new double[_state.WGastadaCentrales.length];
        System.arraycopy(_state.WGastadaCentrales, 0, WGastadaCentrales, 0, WGastadaCentrales.length) ;
        centralAssig = new int[_state.centralAssig.length];
        System.arraycopy(_state.centralAssig, 0, centralAssig, 0, centralAssig.length) ;
        this.ganancia = _state.ganancia;
        this.potenciaSobrada = _state.potenciaSobrada;
    }
    
    // recorrido sobre la potencia que gasta todas la centrales, pero no lo usamos esta funcion
    double potenciaGastada(){
        double gasto = 0.0d;
        for (int i = 0; i < WGastadaCentrales.length; ++i)
            gasto += WGastadaCentrales[i];
        return gasto;
    }
    
    public double heuristic() { //maximizar ganancia $ y minimizar potencia
        return -(ganancia - potenciaSobrada); 
    }
    
    public double heuristicNSol() { //maximizar ganancia $ y minimizar potencia
        return -(ganancia - penalizacion - potenciaSobrada);
    }
    
    public void printBeneficio(){
        System.out.println("beneficio: " + ganancia);
    }
    
    public void pintNumAsignados(){
       int count = 0;
       for (int i = 0; i < centralAssig.length; ++i)
           if(centralAssig[i] != -1) 
               ++count;
       System.out.println("Numero clientes servidos: " + count);
    }
    
    public int printNumAssigCentralesC(){
        int count = 0;
        for(int i = 0; i < centralAssig.length; ++i){
            if(centralAssig[i] != -1 && centrales[centralAssig[i]].getTipo() == Central.CENTRALA){
              ++count;  
            }
        }
        return count;
    }

}
