using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CatState : IState
{
    private StateMachine _fsm;
    private GrayModel _enemy;

    public CatState(StateMachine fsm, GrayModel p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entré a CatState");

        _enemy.ResetPathAndSetObjective(_enemy._lm.objective.transform.position);
    }
    public void OnUpdate()
    {
       
    }
    public void OnExit()
    {
        Debug.Log("Sali de CatState");
    }
}

