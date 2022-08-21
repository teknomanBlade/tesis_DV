using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttackPlayerState : IState
{
    private StateMachine _fsm;
    private GrayModel _enemy;

    public AttackPlayerState(StateMachine fsm, GrayModel p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entré a Patrol");
    }
    public void OnUpdate()
    {

    }
    public void OnExit()
    {
        Debug.Log("Sali de Patrol");
    }
}