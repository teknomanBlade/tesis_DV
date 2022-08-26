using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttackTrapState : IState
{
    private StateMachine _fsm;
    private GrayModel _enemy;

    public AttackTrapState(StateMachine fsm, GrayModel p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a Patrol");
    }
    public void OnUpdate()
    {
        _enemy.AttackTrap();
    }
    public void OnExit()
    {
        Debug.Log("Sali de Patrol");
    }
}