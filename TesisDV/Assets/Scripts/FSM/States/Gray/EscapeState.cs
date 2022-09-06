using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EscapeState : IState
{
    private StateMachine _fsm;
    private GrayModel _enemy;

    public EscapeState(StateMachine fsm, GrayModel p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a Escape");
        
        //_enemy.SetObjective(_enemy);
        //_enemy.ResetPathAndSetObjective(_enemy._exitPos);
        _enemy.ResetPathAndSetObjective();
    }
    public void OnUpdate()
    {
        _enemy.Move();

        if (Vector3.Distance(_enemy.transform.position, _enemy._exitPos) < 3f)
        {
            _enemy.GoBackToShip();
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de Escape");
    }
}