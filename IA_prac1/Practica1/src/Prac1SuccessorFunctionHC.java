
import aima.search.framework.SuccessorFunction;
import aima.search.framework.Successor;
import java.util.ArrayList;
import java.util.List;
import IA.Energia.*;
import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;
public class Prac1SuccessorFunctionHC implements SuccessorFunction{

    public List getSuccessors(Object _state) {  
        ArrayList retval = new ArrayList();
        State state = (State) _state;
        State new_state = new State(state);
            for(int i = 0; i < state.clientes.length; ++i){     
                /*for(int j = i + 1; j < state.clientes.length; ++j){
                    if (new_state.intercambio(i, j)){
                        retval.add(new Successor(new String("Intercambio: " + i +" <-> " + j), new_state));
                        new_state = new State(state);
                    }
                }*/
                for (int c = -1; c < state.centrales.length; ++c){
                    try {
                        if(new_state.cambio(i, c)) {
                            retval.add(new Successor(new String("Cambio cliente " + i + " con central " + state.centralAssig[i] + " a central " + c), new_state));
                            new_state = new State(state);
                        }
                    } catch (Exception ex) {
                        Logger.getLogger(Prac1SuccessorFunctionHC.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
            }

        return retval;
    }
}

