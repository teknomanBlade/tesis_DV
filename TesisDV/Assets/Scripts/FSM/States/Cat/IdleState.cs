using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class IdleState : IState
{
    private StateMachine _fsm;
    private Cat _cat;

    public IdleState(StateMachine fsm, Cat p)
    {
        _fsm = fsm;
        _cat = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a IdleCat");
        _cat.EnterIdleState();
    }

    public void OnUpdate()
    {
        _cat.EnterIdleState();
    }

    public void OnExit()
    {
        Debug.Log("Sali de IdleCat");
    }
}