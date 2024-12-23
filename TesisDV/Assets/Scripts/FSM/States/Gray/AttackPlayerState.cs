using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttackPlayerState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;

    public AttackPlayerState(StateMachine fsm, Enemy p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a AttackPlayer");
        //_enemy.SetObjective(_enemy._player.gameObject);
        //_enemy.ResetPathAndSetObjective(_enemy._player.transform.position); //Se va el navmesh
        //_enemy.ResetPathAndSetObjective();
        //_enemy.AttackPlayer();
    }

    public void OnUpdate() //Chequear que la animacion de ataque no se solape.
    {
        //_enemy.ResetPathAndSetObjective(_enemy._player.transform.position); //Se va el navmesh

        if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.attackThreshold && _enemy._player.isAlive)
        {
            _enemy.AttackPlayer();
        }
        else
        {
            _enemy.RevertAttackBool();
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
    }

    public void OnExit()
    {
        Debug.Log("Sali de AttackPlayer");
    }
}