using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HardcodeAttackState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;

    public HardcodeAttackState(StateMachine fsm, Enemy p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a AttackPlayer");
    }

    public void OnUpdate() //Chequear que la animacion de ataque no se solape.
    {
        if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.attackThreshold && _enemy._player.isAlive)
        {
            _enemy.AttackPlayer();
        }
        else
        {
            _enemy.RevertAttackBool();
            _fsm.ChangeState(EnemyStatesEnum.HardcodeCatState);
        }
    }

    public void OnExit()
    {
        Debug.Log("Sali de AttackPlayer");
    }
}