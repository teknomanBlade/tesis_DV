using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChaseForceFieldState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;

    public ChaseForceFieldState(StateMachine fsm, Enemy p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a ChaseForceFieldState");
    }
    public void OnUpdate()
    { 
        Vector3 dir = _enemy._currentTrapObjective.transform.position - _enemy.transform.position;
        _enemy.transform.forward = dir;
        _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;

        if(!_enemy.foundTrapInPath)
        {
            _fsm.ChangeState(EnemyStatesEnum.PlayerState);
        }
        if(_enemy._currentTrapObjective.GetComponent<Trap>().active == false)
        {
            _fsm.ChangeState(EnemyStatesEnum.PlayerState);
            _enemy.foundTrapInPath = false;
        }
        if(Vector3.Distance(_enemy._currentTrapObjective.transform.position, _enemy.transform.position) < _enemy.attackThreshold)
        {
            _fsm.ChangeState(EnemyStatesEnum.AttackTrapState);
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de ChaseForceFieldState");
    }
}
