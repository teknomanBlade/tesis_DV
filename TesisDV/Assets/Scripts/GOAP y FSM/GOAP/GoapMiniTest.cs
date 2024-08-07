using System.Security.Cryptography;
using System.Collections.Generic;
using FSM;
using UnityEngine;

public class GoapMiniTest : MonoBehaviour
{
    public ChaseState chaseState;
    public AttackState attackState;
    public ChaseCatState chaseCatState;
    public FleeingState fleeingState;
    public EscapeState escapeState;
    public BreakObjectState breakObjectState;


    private FiniteStateMachine _fsm;


    void Start()
    {
        //OnlyPlan();
        PlanAndExecute();
    }

    //IA2-P3
    private void PlanAndExecute()
    {
        var actions = new List<GOAPAction>{
                                              new GOAPAction("Escape")
                                                 .Pre("isAlienGoingToDie", 2)
                                                 .Effect("isPlayerNear", true)
                                                 .LinkedState(escapeState),

                                              new GOAPAction("ChaseCat")
                                                 .Effect("hasCat", true)
                                                 .LinkedState(chaseCatState),

                                              //new GOAPAction("BreakObject")
                                              //   .Pre("isObjectBlocking", "HouseDoorBlack")
                                              //   .Effect("catIsGone", true)
                                              //   .LinkedState(breakObjectState),

                                              new GOAPAction("Chase")
                                                 .Pre("catIsGone", true)
                                                 .Effect("isPlayerNear", true)
                                                 .LinkedState(chaseState),

                                              new GOAPAction("Attack")
                                                 .Pre("isPlayerNear",   4.5f)
                                                 .Effect("isPlayerAlive", false)
                                                 .Effect("alienWins", true)
                                                 .LinkedState(attackState),
                                                 //.Cost(2),

                                              new GOAPAction("Fleeing")
                                                 .Pre("hasCat", true)
                                                 .Effect("catIsGone", true)
                                                 .LinkedState(fleeingState),

                                          };

        var from = new GOAPState();
        from.values["isPlayerInSight"] = false;
        from.values["isPlayerAlive"] = true;
        from.values["isPlayerNear"] = 4.5f;
        from.values["hasCat"] = false;
        from.values["catIsGone"] = false;
        from.values["alienIsGone"] = false;
        from.values["alienWins"] = false;
        from.values["isAlienGoingToDie"] = 2f;

        var to = new GOAPState();
        //to.values["isPlayerAlive"]     = false;
        to.values["alienWins"] = true;

        var planner = new GoapPlanner();
        planner.OnPlanCompleted += OnPlanCompleted;
        planner.OnCantPlan += OnCantPlan;

        planner.Run(from, to, actions, StartCoroutine);
    }


    private void OnPlanCompleted(IEnumerable<GOAPAction> plan)
    {
        _fsm = GoapPlanner.ConfigureFSM(plan, StartCoroutine);
        _fsm.Active = true;
    }

    private void OnCantPlan()
    {
        Debug.Log("No funciona");
    }

}
