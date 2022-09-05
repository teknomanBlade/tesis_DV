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
        Debug.Log("Entre a AttackPlayer");
        _enemy.SetObjective(_enemy._player.gameObject);
        //_enemy.ResetPathAndSetObjective(_enemy._player.transform.position);
        _enemy.ResetPathAndSetObjective();
        //_enemy.AttackPlayer();
    }

    public void OnUpdate() //Chequear que la animacion de ataque no se solape.
    {
        if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.attackThreshold)
        {
            _enemy.AttackPlayer();
        }
        else
        {
            _enemy.RevertAttackBool();
            _fsm.ChangeState(EnemyStatesEnum.ChaseState);
        }
    }

    public void OnExit()
    {
        Debug.Log("Sali de AttackPlayer");
    }
}