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
        _enemy.AttackTrap();
        
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