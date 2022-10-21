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
        if (!_enemy.foundTrapInPath)
        {
            //_enemy.RevertSpecialAttackBool();
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
        else
        {
            _enemy.AttackTrap();
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de Patrol");
    }
}