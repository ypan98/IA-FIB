import IA.Energia.Centrales;
import IA.Energia.Clientes;
import aima.search.framework.GraphSearch;
import aima.search.framework.Problem;
import aima.search.framework.Search;
import aima.search.framework.SearchAgent;
import aima.search.framework.SuccessorFunction;
import aima.search.informed.AStarSearch;
import aima.search.informed.IterativeDeepeningAStarSearch;
import aima.search.informed.HillClimbingSearch;
import aima.search.informed.SimulatedAnnealingSearch;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Scanner;


public class Main {

    public static void main(String[] args) throws Exception{

        long initTime = System.currentTimeMillis();
        int numCentralesA = 5;
        int numCentralesB = 10;
        int numCentralesC = 25;
        int [] numCentrales = new int[]{numCentralesA, numCentralesB, numCentralesC}; 
        

        double propClientesXG = 0.25 ;
        double propClientesMG = 0.3 ;
        double propClientesG = 0.45 ;

        int numClientes = 1000;
        int steps = 10000;
        int k = 5;
        double lamb = 0.00001;
        double propG = 0.75d;
        String method = "SA";
        propG = 0.75d;
        int seed = 1234;
        Boolean verbose = true;
        Boolean debug = false;
        if (args.length == 0 &&  !debug){
            Scanner capt = new Scanner(System.in);
            do{
                System.out.println("Introduzca el metodo: [SA] / [HC]");
                method = capt.next();
                method = method.substring(0,2);
                if(method.equals("SA") || method.equals("HC")){
                    break;
                }else{
                    System.out.println("Metodo incorrecto");
                }
            }while(true);
            
             System.out.println("Introduzca el numero de centrales de tipo A");
            numCentralesA = capt.nextInt();
            
             System.out.println("Introduzca el numero de centrales de tipo B");
            numCentralesB = capt.nextInt();
            
            System.out.println("Introduzca el numero de centrales de tipo C");
            numCentralesC = capt.nextInt();

            System.out.println("Introduzca la proporcion de clientes de XG:");
            propClientesXG = capt.nextDouble();
            
            System.out.println("Introduzca la proporcion de clientes de MG:");
            propClientesMG = capt.nextDouble();
            
            System.out.println("Introduzca la proporcion de clientes de G:");
            propClientesG = capt.nextDouble();
            
            System.out.println("Introduzca la seed:");
            seed = capt.nextInt();
            
            if(method.equals("HC")){
                System.out.println("Introduzca la lambda:");
                lamb = capt.nextDouble();
                
                System.out.println("Introduzca la k:");
                k = capt.nextInt();
                
                System.out.println("Introduzca los pasos:");
                steps = capt.nextInt();
            }
            
        }
        else if(args.length >= 1){
            method = args[0];
            verbose = false;
            if (args.length >= 10){
                numCentralesA = Integer.parseInt(args[1]);
                numCentralesB = Integer.parseInt(args[2]);
                numCentralesC = Integer.parseInt(args[3]);
                propClientesXG = Double.parseDouble(args[4]);
                propClientesMG = Double.parseDouble(args[5]);
                propClientesG = Double.parseDouble(args[6]);
                numClientes = Integer.parseInt(args[7]);
                propG = Double.parseDouble(args[8]);
                seed = Integer.parseInt(args[9]);
            }
            if (args.length == 13){
                steps = Integer.parseInt(args[10]);   
                k = Integer.parseInt(args[11]);  
                lamb = Double.parseDouble(args[12]);
            }else if (args.length != 10){
                throw new java.lang.Error("Wrong arguments");
            }
        }
        if (verbose){
            System.out.println("Numero centrales A: " + numCentralesA + ", B: " + numCentralesB + ", C: " + numCentralesC);
            System.out.println("Proporcion clientes XG: " + propClientesXG + " ,MG " + propClientesMG + ", G " + propClientesG + ", suma: " + (propClientesG+propClientesXG+propClientesMG));
            System.out.println("Poroporcion clientes garantizados: " + propG + ", numero de clientes: " + numClientes);
        }
        
        
        double [] propClientes = new double[]{propClientesXG, propClientesMG, propClientesG};
        Centrales centrales = new Centrales(numCentrales, seed);
        Clientes clientes = new Clientes(numClientes, propClientes, propG, seed);
    
        State state = new State(clientes, centrales, seed);
        
        
        SuccessorFunction sf;
        Search alg;
        if(method.equals("HC")){
            alg = new HillClimbingSearch();
            sf = new Prac1SuccessorFunctionHC();
        }else if(method.equals("SA")){
            alg = new SimulatedAnnealingSearch(steps,100, k, lamb);
            sf = new Prac1SuccessorFunctionSA();
        }else{
            throw new java.lang.Error("Method defined can't be found");
        }
        
        // Create the Problem object
        Problem p = new  Problem(state,
                                sf,
                                new Prac1GoalTest(),
                                new Prac1HeuristicFunction());

        // Instantiate the search algorithm
	// AStarSearch(new GraphSearch()) or IterativeDeepeningAStarSearch()
        
        // Instantiate the SearchAgent object
        SearchAgent agent = new SearchAgent(p, alg);
        long endTime = System.currentTimeMillis();
	// We print the results of the search
        State goalState = (State) alg.getGoalState();
        if (verbose){
            //System.out.println(agent.getActions().get(0));
            //printActions(agent.getActions());
            printInstrumentation(agent.getInstrumentation());
            //printStates(agent.getActions());
//            System.out.println(Arrays.toString(agent.getActions().toArray()));
//            System.out.println(Arrays.toString(alg.getPathStates().toArray()));
            goalState.pintNumAsignados();
            goalState.printBeneficio();
            System.out.println("Tiempo de ejecucion: " + (endTime-initTime));
        }else{
            //printStates(alg.getPathStates());
            System.out.println((endTime-initTime) + " " + goalState.ganancia + " " + goalState.printNumAssigCentralesC());
        }
        // You can access also to the goal state using the
	// method getGoalState of class Search
    }

    private static void printInstrumentation(Properties properties) throws InstantiationException, IllegalAccessException {
        Iterator keys = properties.keySet().iterator();
        while (keys.hasNext()) {
            String key = (String) keys.next();
            String property = properties.getProperty(key);
            System.out.println(key + " : " + property);
        }
        
    }
    
    private static void printActions(List actions) {
        for (int i = 0; i < actions.size(); i++) {
            String action = (String) actions.get(i);
            System.out.println(action);
        }
    }
    private static void printStates(List states){
        for (int i = 0; i < states.size(); ++i){
            State state = (State) states.get(i);
            System.out.println(state.heuristic());
        }
    }
    
}
