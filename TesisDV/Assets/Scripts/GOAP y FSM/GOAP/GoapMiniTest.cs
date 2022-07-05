using System.Collections.Generic;
using FSM;
using UnityEngine;

public class GoapMiniTest : MonoBehaviour 
{

    public DoorState        doorState;
    public TrapState        trapState;
    public StunState        stunState;
    public ChaseState       chaseState;
    public AttackState      attackState;
    public ChaseCatState    chaseCatState;
    public FleeingState     fleeingState;
    
    private FiniteStateMachine _fsm;
    
    
    void Start() {
        //OnlyPlan();
        PlanAndExecute();
    }

    private void OnlyPlan() {
        var actions = new List<GOAPAction>{
                                              new GOAPAction("ChaseCat")
                                                 .Effect("isPlayerInSight", true)
                                                 .Effect("hasCat", true),

                                              new GOAPAction("OpenDoor")
                                                 .Pre("foundDoorInPath", true)
                                                 .Effect("foundDoorInPath",    false),

                                              new GOAPAction("BreakTrap")
                                                 .Pre("foundTrapInPath",   true)
                                                 .Effect("foundTrapInPath", false),

                                              new GOAPAction("Chase")
                                                 .Pre("isPlayerInSight", true)
                                                 .Effect("isPlayerNear",    true),

                                              new GOAPAction("Attack")
                                                 .Pre("isPlayerNear",   true)
                                                 .Effect("isPlayerAlive", false),

                                              new GOAPAction("FleeingState")
                                                 .Pre("hasCat", true)
                                                 .Effect("alienIsGone", true),

                                              new GOAPAction("StunState")
                                                 .Pre("isStuned", true)
                                                 .Effect("isStuned", false)
                                          };
        var from = new GOAPState();
        from.values["isPlayerInSight"] = true;
        from.values["isPlayerNear"]    = true;
        from.values["isPlayerInRange"] = true;
        from.values["isPlayerAlive"]   = true;
        from.values["hasRangeWeapon"]  = true;
        from.values["hasMeleeWeapon"]  = false;

        var to = new GOAPState();
        to.values["isPlayerAlive"] = false;

        var planner = new GoapPlanner();
        //planner.OnPlanCompleted += OnPlanCompleted;
        //planner.OnCantPlan      += OnCantPlan;

        planner.Run(from, to, actions, StartCoroutine);
    }

    private void PlanAndExecute() {
        var actions = new List<GOAPAction>{
                                              new GOAPAction("ChaseCat")
                                                 .Pre("isStuned", false)
                                                 .Pre("isPlayerInSight", false)
                                                 .Pre("hasCat", false)
                                                 .Effect("hasCat", true)
                                                 .LinkedState(chaseCatState),

                                              new GOAPAction("OpenDoor")
                                                 .Pre("isStuned", false)
                                                 .Pre("foundDoorInPath", true)
                                                 .Effect("foundDoorInPath",    false)
                                                 .LinkedState(doorState),

                                              new GOAPAction("BreakTrap")
                                                 .Pre("isStuned", false)
                                                 .Pre("foundTrapInPath",   true)
                                                 .Effect("foundTrapInPath", false)
                                                 .LinkedState(trapState),

                                              new GOAPAction("Chase")
                                                 .Pre("isStuned", false)
                                                 .Pre("isPlayerInSight", true)
                                                 .Effect("isPlayerNear",    true)
                                                 .LinkedState(chaseState),

                                              new GOAPAction("Attack")
                                                 .Pre("isStuned", false)
                                                 .Pre("isPlayerNear",   true)
                                                 .Effect("isPlayerAlive", false)
                                                 .LinkedState(attackState),

                                              new GOAPAction("FleeingState")
                                                 .Pre("isStuned", false)
                                                 .Pre("hasCat", true)
                                                 .Effect("alienIsGone", true)
                                                 .LinkedState(fleeingState),

                                              new GOAPAction("StunState")
                                                 .Pre("isStuned", true)
                                                 .Effect("isStuned", false)
                                                 .LinkedState(stunState)
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

        var to = new GOAPState();
        //to.values["isPlayerAlive"]     = false; Testear.
        to.values["alienIsGone"]       = true;

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
    }

}
