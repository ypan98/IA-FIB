


import java.util.Comparator;
import java.util.ArrayList;
import aima.search.framework.HeuristicFunction;

public class Prac1HeuristicFunction implements HeuristicFunction{
    public double getHeuristicValue(Object n) {
        //double h = ((State) n).heuristic();
        double h = ((State) n).heuristicNSol();
        //System.out.println("heuristic: " + h);
        return h;
    }
}
