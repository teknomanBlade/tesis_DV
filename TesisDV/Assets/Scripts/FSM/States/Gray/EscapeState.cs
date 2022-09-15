using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EscapeState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;

    public EscapeState(StateMachine fsm, Enemy p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a Escape");
        
        //_enemy.SetObjective(_enemy.currentExitUFO);
        //_enemy.ResetPathAndSetObjective(_enemy._exitPos);
        var dir = _enemy._exitPos - _enemy.transform.position;
        _enemy.transform.forward = dir;
        _enemy.ResetPathAndSetObjective(_enemy._exitPos);
    }
    public void OnUpdate()
    {
        _enemy.ResetPathAndSetObjective(_enemy._exitPos);
        _enemy.Move();
        if (_enemy.hasObjective) _enemy.EscapeWithCat();

        if (Vector3.Distance(_enemy.transform.position, _enemy._exitPos) < 1.5f)
        {
            _enemy.GoBackToShip();
        }
        else if (!_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de Escape");
    }
}