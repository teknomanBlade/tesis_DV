using System.Security.Cryptography;
using System.Collections.Generic;
using FSM;
using UnityEngine;

public class GoapMiniTest : MonoBehaviour 
{
    public ChaseState       chaseState;
    public AttackState      attackState;
    public ChaseCatState    chaseCatState;
    public FleeingState     fleeingState;
    public CelebrationState celebrationState;

    private FiniteStateMachine _fsm;
    
    
    void Start() {
        //OnlyPlan();
        PlanAndExecute();
    }

    private void OnlyPlan() {
        var actions = new List<GOAPAction>{
                                              new GOAPAction("ChaseCat")
                                                 .Pre("isStuned", false)
                                                 .Pre("isPlayerInSight", false)
                                                 .Pre("hasCat", false)
                                                 .Effect("hasCat", true)
                                                 .Effect("isPlayerInSight", true)
                                                 ,

                                              new GOAPAction("OpenDoor")
                                                 .Pre("isStuned", false)
                                                 .Pre("foundDoorInPath", true)
                                                 .Effect("foundDoorInPath",    false)
                                                 ,

                                              new GOAPAction("BreakTrap")
                                                 .Pre("isStuned", false)
                                                 .Pre("foundTrapInPath",   true)
                                                 .Effect("foundTrapInPath", false)
                                                 ,

                                              new GOAPAction("ChaseState")
                                                 .Pre("isStuned", false)
                                                 .Pre("isPlayerInSight", true)
                                                 .Effect("isPlayerNear",    true)
                                                 ,

                                              new GOAPAction("Attack")

                                                 .Pre("isPlayerNear",   true)
                                                 .Effect("isPlayerAlive", false)
                                                 ,

                                              new GOAPAction("FleeingState")

                                                 .Pre("hasCat", true)

                                                 .Effect("alienIsGone", true)
                                                 ,

                                              new GOAPAction("StunState")
                                                 .Pre("isStuned", true)
                                                 .Effect("isStuned", false)
                                                 ,

                                              new GOAPAction("DieState")
                                                 .Pre("isAlive", false)
                                                 
                                          };
        var from = new GOAPState();
        from.values["isPlayerInSight"] = false;
        from.values["isPlayerAlive"]   = true;
        from.values["isPlayerNear"]    = false;
        from.values["hasCat"]          = false;
        from.values["foundDoorInPath"] = false;
        from.values["foundTrapInPath"] = false;
        from.values["alienIsGone"]     = false;
        from.values["isStuned"]        = false;
        from.values["isAlive"]         = true;

        var to = new GOAPState();
        to.values["alienIsGone"]       = true;

        var planner = new GoapPlanner();
        //planner.OnPlanCompleted += OnPlanCompleted;
        //planner.OnCantPlan      += OnCantPlan;

        planner.Run(from, to, actions, StartCoroutine);
    }

    private void PlanAndExecute() {
        var actions = new List<GOAPAction>{
                                              new GOAPAction("Escape")
                                                 .Pre("isAlienGoingToDie", false)
                                                 .Effect("catIsGone", true)
                                                 .LinkedState(chaseCatState),  

                                              new GOAPAction("Celebrate")
                                                 .Pre("isPlayerAlive", false)
                                                 .Effect("alienWins", true)
                                                 .LinkedState(chaseCatState),  

                                              new GOAPAction("ChaseCat")
                                                 .Pre("isPlayerInSight", false)
                                                 .Pre("hasCat", false)
                                                 .Effect("hasCat", true)
                                                 .LinkedState(chaseCatState),

                                              new GOAPAction("Chase")
                                                 .Pre("catIsGone", true)
                                                 .Effect("isPlayerNear", true)
                                                 .LinkedState(chaseState),

                                              new GOAPAction("Attack")
                                                 .Pre("isPlayerNear",   true)
                                                 .Effect("isPlayerAlive", false)
                                                 .LinkedState(attackState).
                                                 Cost(2),

                                              new GOAPAction("Fleeing")
                                                 .Pre("hasCat", true)
                                                 .Effect("catIsGone", true)
                                                 .LinkedState(fleeingState),
                                              
                                          };
        
        var from = new GOAPState();
        from.values["isPlayerInSight"]    = false;
        from.values["isPlayerAlive"]      = true;
        from.values["isPlayerNear"]       = false;
        from.values["hasCat"]             = false;
        from.values["foundDoorInPath"]    = false;
        from.values["foundTrapInPath"]    = false;
        from.values["alienIsGone"]        = false;
        from.values["isStuned"]           = false;
        from.values["isAlive"]            = true;
        from.values["alienWins"]          = false;
        from.values["isAlienGoingToDie"]  = false;

        var to = new GOAPState();
        //to.values["isPlayerAlive"]     = false;
        to.values["alienWins"]         = true;

        var planner = new GoapPlanner();
        planner.OnPlanCompleted += OnPlanCompleted;
        planner.OnCantPlan      += OnCantPlan;

        planner.Run(from, to, actions, StartCoroutine);
    }


    private void OnPlanCompleted(IEnumerable<GOAPAction> plan) {
        _fsm = GoapPlanner.ConfigureFSM(plan, StartCoroutine);
        _fsm.Active = true;
    }

    private void OnCantPlan() {
        //TODO: debuggeamos para ver por qué no pudo planear y encontrar como hacer para que no pase nunca mas
        Debug.Log("Cagaste pa");
    }

}
