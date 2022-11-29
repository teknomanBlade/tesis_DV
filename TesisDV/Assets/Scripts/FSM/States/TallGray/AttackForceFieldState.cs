using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttackForceFieldState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;

    public AttackForceFieldState(StateMachine fsm, Enemy p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a AttackForceFieldState");
    }
    public void OnUpdate()
    {
        if (!_enemy.foundTrapInPath)
        {
            //_enemy.RevertSpecialAttackBool();
            _fsm.ChangeState(EnemyStatesEnum.PlayerState);
        }
        else
        {
            _enemy.AttackTrap();
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de AttackForceFieldState");
    }
}