
import aima.search.framework.SuccessorFunction;
import aima.search.framework.Successor;
import java.util.ArrayList;
import java.util.List;
import IA.Energia.*;
import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;


public class Prac1SuccessorFunctionSA implements SuccessorFunction{

    public List getSuccessors(Object _state) {  
        ArrayList retval = new ArrayList();
        State state = (State) _state;
        State new_state = new State(state);
        
        int i = 0, c = 0;
        int times = 100;
        try {
            
            do{
                i = (int)  (Math.random() * state.clientes.length);
                c = (int) (Math.random() * (state.centrales.length + 1)) - 1;
            }while(!new_state.cambioNSol(i, c) && times-- > 0);
            
        } catch (Exception ex) {
            Logger.getLogger(Prac1SuccessorFunctionSA.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        retval.add(new Successor(new String("Cambio cliente " + i + " con central " + state.centralAssig[i] + " a central " + c), new_state));
        
        return retval;
    }
}

