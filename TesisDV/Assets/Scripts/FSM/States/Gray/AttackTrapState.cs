using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttackTrapState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;

    public AttackTrapState(StateMachine fsm, Enemy p)
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
        if (Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.attackTrapThreshold)
        {
            _enemy.AttackTrap();
        }
        else
        {
            _enemy.RevertSpecialAttackBool();
            _fsm.ChangeState(EnemyStatesEnum.ChaseState);
        }
       
        
        if(!_enemy.foundTrapInPath)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de Patrol");
    }
}